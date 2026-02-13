#' @param name           Character. Nombre del reporte.
#' @param dataset        Character. Dataset del bulk report (ej: "public-fixed-infrastructure-data:v1.1").
#' @param format         Character. Output formar. For now it is set to "CSV".
#' @param region_dataset Character. Dataset's region (ej: "public-eez-areas").
#' @param region_id      Numeric/Character. Region ID (ej. 8466 for Argentina).
#' @param filters        Character vector. Filters (strings) for the backend.
#' @param base_url       Character. Base URL for API v3.
#' @param key            Character. Token Bearer. Default: gfwr::gfw_auth() if exist, if not Sys.getenv("GFW_TOKEN").
#' @param poll_interval_seconds Numeric. Polls interval.
#' @param max_wait_seconds Numeric. Maximun for total wait.
#' @param file           Character. "DATA", "README" or "GEOM". Default "DATA".
#' @param out_dir        Character. Folder for target output.
#' @param decompress     Logical. If TRUE, it will unzip .gz to .csv.
#' @param quiet          Logical. If TRUE, hide mensages.
#' @param print_request  Logical. If TRUE, it prints the call URLs (for support/debug).
#'
#' @return List with report_id, status, meta, paths, signed_url.
gfw_bulk_report <- function(
    name,
    dataset,
    format = "CSV",
    region_dataset,
    region_id,
    filters = character(),
    base_url = "https://gateway.api.globalfishingwatch.org/v3",
    key = NULL,
    poll_interval_seconds = 5,
    max_wait_seconds = 600,
    file = c("DATA", "README", "GEOM"),
    out_dir = tempdir(),
    decompress = TRUE,
    quiet = FALSE,
    print_request = FALSE
) {
  file <- match.arg(file)

  # ---- key (estilo gfwr) ----
  if (is.null(key)) {
    key <- tryCatch(
      gfwr::gfw_auth(),
      error = function(e) Sys.getenv("GFW_TOKEN", unset = NA_character_)
    )
  }
  if (!nzchar(key)) stop("No API token found. Set GFW_TOKEN or pass `key=`.", call. = FALSE)

  # ---- helpers ----
  `%||%` <- function(a, b) if (!is.null(a)) a else b
  ua <- "gfwr-style-bulk-reports/0.1"

  .msg <- function(...) if (!quiet) message(...)
  .maybe_print <- function(req) {
    if (!isTRUE(print_request)) return(invisible(NULL))
    url <- tryCatch(httr2::req_url(req), error = function(e) "<url-not-set>")
    .msg("Request: ", url)
  }

  .auth <- function(req) {
    req |>
      httr2::req_user_agent(ua) |>
      httr2::req_headers(
        Authorization = paste("Bearer", key),
        Accept = "application/json"
      )
  }

  .perform_checked <- function(req) {
    .maybe_print(req)
    resp <- httr2::req_perform(req)
    # It lest httr2 create the error with status; we added to the body if fails
    if (httr2::resp_status(resp) >= 400) {
      body <- tryCatch(httr2::resp_body_string(resp), error = function(e) "<no-body>")
      stop(
        sprintf(
          "HTTP %s %s\nURL: %s\nBody: %s",
          httr2::resp_status(resp),
          httr2::resp_status_desc(resp),
          httr2::req_url(req),
          body
        ),
        call. = FALSE
      )
    }
    resp
  }

  .get_signed_url <- function(report_id, file) {
    req <- httr2::request(paste0(base_url[1], "/bulk-reports/", report_id, "/download-file-url")) |>
      .auth() |>
      httr2::req_url_query(file = file) |>
      httr2::req_retry(max_tries = 6, backoff = ~ runif(1, 1, 3) * 2^(..try - 1))
    resp <- .perform_checked(req)
    out <- httr2::resp_body_json(resp, simplifyVector = TRUE)
    if (!is.list(out) || !nzchar(out$url)) stop("Signed URL response missing `url`.", call. = FALSE)
    out$url
  }

  .download_binary <- function(url, dest) {
    ok <- tryCatch({
      utils::download.file(url, dest, mode = "wb", quiet = TRUE)
      file.exists(dest) && file.info(dest)$size > 0
    }, warning = function(w) file.exists(dest) && file.info(dest)$size > 0,
    error   = function(e) FALSE)
    ok
  }

  .gunzip_to_csv <- function(gz_path, csv_path) {
    con_in  <- gzfile(gz_path, open = "rb")
    on.exit(close(con_in), add = TRUE)
    con_out <- file(csv_path, open = "wb")
    on.exit(close(con_out), add = TRUE)

    # stream (sin leer todo a memoria)
    while (TRUE) {
      chunk <- readBin(con_in, what = "raw", n = 1024 * 1024)
      if (length(chunk) == 0) break
      writeBin(chunk, con_out)
    }
    invisible(csv_path)
  }

  # Create the report
  .msg("Creating bulk report...")
  create_req <- httr2::request(paste0(base_url[1], "/bulk-reports")) |>
    .auth() |>
    httr2::req_retry(max_tries = 6, backoff = ~ runif(1, 1, 3) * 2^(..try - 1)) |>
    httr2::req_body_json(
      list(
        name = name,
        dataset = dataset,
        format = format,
        region = list(dataset = region_dataset, id = region_id),
        filters = filters
      ),
      auto_unbox = TRUE
    )

  create_resp <- .perform_checked(create_req)
  meta <- httr2::resp_body_json(create_resp, simplifyVector = TRUE)
  report_id <- meta$id
  if (!nzchar(report_id)) stop("Create response missing `id`.", call. = FALSE)
  .msg("Bulk report id: ", report_id)

  # Poll until done/failed
  status_req <- httr2::request(paste0(base_url[1], "/bulk-reports/", report_id)) |>
    .auth() |>
    httr2::req_retry(
      max_tries = 1000,
      max_seconds = max_wait_seconds,
      backoff = ~ pmin(30, 1.5^(..try - 1))
    )

  started <- Sys.time()
  repeat {
    status_resp <- .perform_checked(status_req)
    status_data <- httr2::resp_body_json(status_resp, simplifyVector = TRUE)

    st <- status_data$status %||% NA_character_
    created_at <- status_data$createdAt %||% status_data$created_at %||% NA
    updated_at <- status_data$updatedAt %||% status_data$updated_at %||% NA

    .msg(sprintf("Status: %s (created: %s, updated: %s)", st, created_at, updated_at))

    if (st %in% c("done", "failed")) break
    if (as.numeric(difftime(Sys.time(), started, units = "secs")) > max_wait_seconds) {
      stop("Timed out waiting for bulk report to finish.", call. = FALSE)
    }
    Sys.sleep(poll_interval_seconds)
  }

  if (!identical(status_data$status, "done")) {
    err_msg <- status_data$error %||% status_data$message %||% "Bulk report finished with status != 'done'."
    stop(err_msg, call. = FALSE)
  }

  # Signed URL
  .msg("Requesting signed download URL (", file, ") ...")
  signed_url <- .get_signed_url(report_id, file = file)

  # Download (+ optional decompress)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  gz_path  <- file.path(out_dir, paste0(report_id, ".csv.gz"))
  csv_path <- sub("\\.gz$", "", gz_path)

  .msg("Downloading: ", gz_path)
  ok <- .download_binary(signed_url, gz_path)
  if (!ok) {
    .msg("download.file failed; retrying with httr2...")
    dl_req <- httr2::request(signed_url) |>
      httr2::req_retry(max_tries = 5) |>
      httr2::req_error(is_error = ~ FALSE)
    .maybe_print(dl_req)
    dl_resp <- httr2::req_perform(dl_req)
    if (httr2::resp_status(dl_resp) >= 400) {
      stop("Download failed: ", httr2::resp_body_string(dl_resp), call. = FALSE)
    }
    writeBin(httr2::resp_body_raw(dl_resp), gz_path)
    ok <- file.exists(gz_path) && file.info(gz_path)$size > 0
  }
  if (!ok) stop("Download did not produce a valid .gz file.", call. = FALSE)

  if (isTRUE(decompress)) {
    .msg("Decompressing: ", csv_path)
    .gunzip_to_csv(gz_path, csv_path)
  } else {
    csv_path <- NA_character_
  }

  invisible(list(
    report_id = report_id,
    status = status_data$status,
    meta_create = meta,
    meta_status = status_data,
    signed_url = signed_url,
    paths = list(gz = gz_path, csv = csv_path)
  ))
}
