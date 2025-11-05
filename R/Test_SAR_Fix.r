
# ============================================
# Global Fishing Watch - Bulk Reports (v3)
# Flujo completo: crear -> esperar -> firmar -> descargar
# Requisitos: httr2, jsonlite
# ============================================

library(httr2)
library(jsonlite)


base_url <- httr2::request("https://gateway.api.globalfishingwatch.org/v3/")
token <- Sys.getenv("GFW_TOKEN", unset = NA_character_)
stopifnot(nzchar(token))

ua <- "gfw-bulk-reports-rstudio/0.1"
`%||%` <- function(a, b) if (!is.null(a)) a else b

# -----------------------------
# Helpers
# -----------------------------
auth_headers <- function(req) {
  req |>
    req_user_agent(ua) |>
    req_headers(
      Authorization = paste("Bearer", token),
      Accept = "application/json"
    )
}

# perform_checked: ejecuta, y si hay error HTTP muestra el cuerpo
perform_checked <- function(req) {
  tryCatch(
    {
      resp <- req_perform(req)
      resp_check_status(resp)
      resp
    },
    httr2_http = function(e) {
      if (!is.null(e$response)) {
        body   <- tryCatch(resp_body_string(e$response), error = function(...) "<no-body>")
        status <- tryCatch(resp_status(e$response),       error = function(...) NA)
        url    <- tryCatch(req_url(req),                  error = function(...) "<unknown-url>")
        stop(sprintf("HTTP error en %s\nStatus: %s\nBody: %s",
                     url, as.character(status), body),
             call. = FALSE)
      } else {
        url <- tryCatch(req_url(req), error = function(...) "<unknown-url>")
        stop(sprintf("Network error in request %s: %s", url, conditionMessage(e)),
             call. = FALSE)
      }
    },
    error = function(e) {
      url <- tryCatch(req_url(req), error = function(...) "<unknown-url>")
      stop(sprintf("Fail execution of request %s: %s", url, conditionMessage(e)),
           call. = FALSE)
    }
  )
}

# Obtiene URL firmada para un archivo del reporte (DATA, README, GEOM)
get_signed_download_url <- function(base_url,
                                    report_id,
                                    file = c("DATA","README","GEOM"),
                                    token,
                                    ua = "gfw-bulk-reports-rstudio/0.1") {
  file <- match.arg(file)
  req <- request(paste0(base_url, "/bulk-reports/", report_id, "/download-file-url")) |>
    req_user_agent(ua) |>
    req_headers(
      Authorization = paste("Bearer", token),
      Accept = "application/json"
    ) |>
    req_url_query(file = file)

  resp <- req |> req_error(is_error = ~ FALSE) |> req_perform()
  if (resp_status(resp) >= 400) {
    stop(sprintf("download-file-url %s -> %s %s\n%s",
                 file, resp_status(resp), resp_status_desc(resp), resp_body_string(resp)),
         call. = FALSE)
  }
  out <- resp_body_json(resp, simplifyVector = TRUE)
  stopifnot(is.list(out), nzchar(out$url))
  out$url
}

# Descarga binaria a un archivo
download_binary <- function(url, dest) {
  ok <- tryCatch({
    utils::download.file(url, dest, mode = "wb", quiet = TRUE)
    file.exists(dest) && file.info(dest)$size > 0
  }, warning = function(w) file.exists(dest) && file.info(dest)$size > 0,
  error   = function(e) FALSE)
  ok
}

# Descomprimir .gz a .csv
gunzip_to_csv <- function(gz_path, csv_path) {
  con_in  <- gzfile(gz_path, open = "rb")
  on.exit(close(con_in), add = TRUE)
  con_out <- file(csv_path, open = "wb")
  on.exit(close(con_out), add = TRUE)
  writeBin(readBin(con_in, what = "raw", n = file.info(gz_path)$size + 1e6), con_out)
  invisible(csv_path)
}

# -----------------------------
# 1) Crear el Bulk Report
# -----------------------------
create_req <-
  request(paste0(base_url, "/bulk-reports")) |>
  auth_headers() |>
  req_retry(max_tries = 6, backoff = ~ runif(1, 1, 3) * 2^(..try - 1)) |>
  req_body_json(list(
    name    = "fixed-infra-argentina-oil-2020-2025",
    dataset = "public-fixed-infrastructure-data:v1.1",
    format  = "CSV",
    region  = list(
      dataset = "public-eez-areas",
      id      = 8466   # Argentina EEZ
    ),
    filters = c(
      "label = 'oil'",
      "structure_start_date between '2020-01-01' and '2025-01-01'"
    )
  ), auto_unbox = TRUE)

cat("Creando bulk report...\n")
create_resp <- perform_checked(create_req)
report_meta <- resp_body_json(create_resp, simplifyVector = TRUE)
report_id <- report_meta$id
stopifnot(nzchar(report_id))
cat("Bulk report created with id:", report_id, "\n")

# -----------------------------
# 2) Polling del estado hasta 'done'
# -----------------------------
status_req <-
  request(paste0(base_url, "/bulk-reports/", report_id)) |>
  auth_headers() |>
  req_retry(
    max_tries   = 1000,
    max_seconds = 600,
    backoff     = ~ pmin(30, 1.5^(..try - 1))
  )

repeat {
  status_resp <- perform_checked(status_req)
  status_data <- resp_body_json(status_resp, simplifyVector = TRUE)

  st <- status_data$status
  created_at <- status_data$createdAt %||% status_data$created_at %||% NA
  updated_at <- status_data$updatedAt %||% status_data$updated_at %||% NA

  cat(sprintf("Status: %s (creation: %s, updated: %s)\n", st, created_at, updated_at))

  if (st %in% c("done", "failed")) break
  Sys.sleep(5)
}

if (!identical(status_data$status, "done")) {
  err_msg <- status_data$error %||% status_data$message %||% "The report does not arrived to 'done'."
  stop(err_msg)
}

# Verificación adicional por si el backend aún no ha materializado el archivo principal
cat("Report in 'done'. Verifing files availability...\n")
for (f in c("README","GEOM","DATA")) {
  resp <- request(paste0(base_url, "/bulk-reports/", report_id, "/download-file-url")) |>
    auth_headers() |>
    req_url_query(file = f) |>
    req_error(is_error = ~ FALSE) |>
    req_perform()
  cat(f, "->", resp_status(resp), resp_status_desc(resp), "\n")
  if (resp_status(resp) >= 400) {
    cat("Details:", resp_body_string(resp), "\n")
  }
}

# -----------------------------
# 3) Obtener URL firmada para DATA
# -----------------------------
cat("Requesting signed URL for DATA...\n")
signed_url <- get_signed_download_url(base_url, report_id, file = "DATA", token = token)
stopifnot(nzchar(signed_url))
cat("Signed URL obtained.\n")

# -----------------------------
# 4) Descargar el CSV (viene como .csv.gz) y descomprimir
# -----------------------------
gz_path  <- file.path(tempdir(), paste0(report_id, ".csv.gz"))
csv_path <- sub("\\.gz$", "", gz_path)

cat("Downloading DATA in .csv.gz ...\n")
ok <- download_binary(signed_url, gz_path)
if (!ok) {
  # Fallback con httr2 (por si download.file falla en tu entorno)
  cat("Retring download with httr2...\n")
  dl_req <- request(signed_url) |> req_retry(max_tries = 5)
  dl_resp <- perform_checked(dl_req)
  writeBin(resp_body_raw(dl_resp), gz_path)
  ok <- file.exists(gz_path) && file.info(gz_path)$size > 0
}
stopifnot(ok)

cat("Uncompressing to CSV...\n")
gunzip_to_csv(gz_path, csv_path)

cat("Ready.\n")
cat("File .csv.gz:", gz_path, "\n")
cat("File .csv   :", csv_path, "\n")

# --------------------------------
# Lectura opcional para verificar
# --------------------------------
cat("Reading first rown from CSV...\n")
df_head <- read.csv(csv_path, nrows = 5)
print(df_head)
