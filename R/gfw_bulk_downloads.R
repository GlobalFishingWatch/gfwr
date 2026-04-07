# gfw_create_bulk_report ------------------------------------------------------

#' Create a bulk report based on specified filters and spatial parameters
#'
#' @description
#' This is internal function to generate a bulk report based on specified
#' filters and spatial parameters.
#'
#' **Disclaimer:**
#' Depending on the complexity and size of your request (e.g., large geojson or region,
#' long date range etc), generating the bulk report can take several minutes to
#' several hours.
#'
#' @details
#' For detailed information about the Create a Bulk Report API endpoint, please refer to the
#' official Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#create-a-bulk-report
#' - https://globalfishingwatch.org/our-apis/documentation#bulk-download-api
#'
#' For more details on the Create a Bulk Report data caveats, please refer to the
#' official Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#sar-fixed-infrastructure-data-caveats
#'
#' @param name Required. Character. Human-readable name of the bulk report. Example:
#' `"sar-fixed-infrastructure-data-20240903"`.
#'
#' @param dataset Required. Character. Dataset that will be used to create the bulk report.
#' Allowed values: `"public-fixed-infrastructure-data:latest"`. Example: `"public-fixed-infrastructure-data:latest"`.
#'
#' @param format Required. Character. Bulk report result format.
#' Allowed values: `"JSON"`, `"CSV"`. Example: `"CSV"`.
#'
#' @param filters Optional. Character vector. Filters to apply when generating the bulk report.
#' Example: `["label = 'oil'"]`.
#'
#' @param key Character. API token. Defaults to [gfw_auth()].
#'
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string.
#'
#' @return
#' A single-row tibble with the created bulk report metadata and status.
#'
#' @examples
#' \dontrun{
#' library(gfwr)
#' }
#'
#' @keywords internal
#' @noRd
gfw_create_bulk_report <- function(name = NULL,
                                   dataset = NULL,
                                   format = NULL,
                                   filters = NULL,
                                   key = gfw_auth(),
                                   print_request = FALSE) {
  ## Validate report name -----------------------------------------------------
  if (!rlang::is_string(name) || !nzchar(name)) {
    rlang::abort("`name` is required and must be a non-empty character string.")
  }

  ## Validate dataset ---------------------------------------------------------

  allowed_datasets <- c(
    "public-fixed-infrastructure-data:latest"
  )

  if (!rlang::is_string(dataset) || !nzchar(dataset)) {
    rlang::abort("`dataset` is required and must be a non-empty character string.")
  }

  dataset <- trimws(dataset)

  if (!dataset %in% allowed_datasets) {
    invalid_dataset_message <- glue::glue(
      "Invalid `dataset` value: {dataset}. ",
      "Allowed value(s): {paste(allowed_datasets, collapse = ', ')}."
    )
    rlang::abort(invalid_dataset_message)
  }

  ## Validate format ----------------------------------------------------------

  allowed_formats <- c(
    "JSON",
    "CSV"
  )

  if (!rlang::is_string(format) || !nzchar(format)) {
    rlang::abort("`format` is required and must be a non-empty character string.")
  }

  format <- toupper(trimws(format))

  if (!format %in% allowed_formats) {
    invalid_format_message <- glue::glue(
      "Invalid `format` value: {format}. ",
      "Allowed value(s): {paste(allowed_formats, collapse = ', ')}."
    )
    rlang::abort(invalid_format_message)
  }

  ## Validate filters ---------------------------------------------------------

  if (!is.null(filters)) {
    if (!is.character(filters) || length(filters) == 0) {
      rlang::abort("`filters` must be a non-empty character vector.")
    }

    filters <- trimws(filters)
    invalid_filters <- filters[is.na(filters) | filters == ""]

    if (length(invalid_filters) > 0) {
      invalid_filters_message <- glue::glue(
        "Invalid `filters` value(s): {paste(invalid_filters, collapse = ', ')}. ",
        "Each filter must be a non-empty, non-NA character string."
      )
      rlang::abort(invalid_filters_message)
    }
  }

  ## Validate key -------------------------------------------------------------
  if (!rlang::is_string(key) || !nzchar(key)) {
    rlang::abort("No API token found. Set `GFW_TOKEN` or pass `key`.")
  }

  ## Build API request body ---------------------------------------------------
  req_body <- list(
    name = name,
    dataset = dataset,
    format = format,
    filters = if (!is.null(filters)) as.list(filters) else NULL
  ) |> purrr::discard(is.null)

  ## Build API request --------------------------------------------------------
  req <- httr2::request(gfw_base_url()) |>
    httr2::req_url_path_append("bulk-reports") |>
    httr2::req_auth_bearer_token(key) |>
    httr2::req_headers(
      `Content-Type` = "application/json"
    ) |>
    httr2::req_user_agent(gfw_user_agent()) |>
    httr2::req_body_json(req_body) |>
    httr2::req_error(body = \(x) parse_response_error(x)$formatted)

  if (print_request) {
    print(req)
  }

  # Perform request
  resp <- req |> httr2::req_perform()

  ## Build API response -------------------------------------------------------

  # Extract JSON response body
  resp_body <- httr2::resp_body_json(resp, check_type = TRUE, simplifyVector = FALSE)

  # Normalize response body
  resp_body <- resp_body |>
    purrr::map(\(x) list(x))

  # Transform response body to dataframe
  resp_df <- tibble::tibble(!!!resp_body)

  return(resp_df)
}

# gfw_get_bulk_report_by_id ---------------------------------------------------

#' Get a bulk report by ID
#'
#' @description
#' This is internal function to retrieves metadata and status of the previously
#' created bulk report based on the provided bulk report ID.
#'
#' **Important:**
#' We recommend to use this method to poll the status of previously created
#' bulk report, if it takes several minutes or hours to generate until it status
#' is `"done"` or `"failed"`.
#'
#' @details
#' For detailed information about the Get Bulk Report by ID API endpoint, please refer to the
#' official Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#get-bulk-report-by-id
#' - https://globalfishingwatch.org/our-apis/documentation#bulk-download-api
#'
#' For more details on the Get Bulk Report by ID data caveats, please refer to the
#' official Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#sar-fixed-infrastructure-data-caveats
#'
#' @param id Required. Character. Unique identifier (ID) of the bulk report. Example:
#' `"adbb9b62-5c08-4142-82e0-b2b575f3e058"`.
#'
#' @param key Character. API token. Defaults to [gfw_auth()].
#'
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string.
#'
#' @return
#' A single-row tibble with the previously created bulk report metadata and status.
#'
#' @examples
#' \dontrun{
#' library(gfwr)
#' }
#'
#' @keywords internal
#' @noRd
gfw_get_bulk_report_by_id <- function(id = NULL,
                                      key = gfw_auth(),
                                      print_request = FALSE) {
  ## Validate report id -------------------------------------------------------
  if (!rlang::is_string(id) || !nzchar(id)) {
    rlang::abort("`id` is required and must be a non-empty character string.")
  }

  ## Validate key -------------------------------------------------------------
  if (!rlang::is_string(key) || !nzchar(key)) {
    rlang::abort("No API token found. Set `GFW_TOKEN` or pass `key`.")
  }

  ## Build API request --------------------------------------------------------
  req <- httr2::request(gfw_base_url()) |>
    httr2::req_url_path_append("bulk-reports", id) |>
    httr2::req_auth_bearer_token(key) |>
    httr2::req_headers(
      `Content-Type` = "application/json"
    ) |>
    httr2::req_user_agent(gfw_user_agent()) |>
    httr2::req_error(body = \(x) parse_response_error(x)$formatted)

  if (print_request) {
    print(req)
  }

  # Perform request
  resp <- req |> httr2::req_perform()

  ## Build API response -------------------------------------------------------

  # Extract JSON response body
  resp_body <- httr2::resp_body_json(resp, check_type = TRUE, simplifyVector = FALSE)

  # Normalize response body
  resp_body <- resp_body |>
    purrr::map(\(x) list(x))

  # Transform response body to dataframe
  resp_df <- tibble::tibble(!!!resp_body)

  return(resp_df)
}

# gfw_get_bulk_report_file_download_url ---------------------------------------

#' Get signed URL to download file of the previously created bulk report
#'
#' @description
#' This is internal function to Retrieves signed URL that points to a downloadable
#' file hosted on Global Fishing Watch's cloud infrastructure to download file(s)
#' (i.e., `"DATA"`, `"README"`, or `"GEOM"`) of the previously created bulk report.
#'
#' @details
#' For detailed information about the Download bulk Report (URL File) API endpoint,
#' please refer to the official Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#download-bulk-report-url-file
#' - https://globalfishingwatch.org/our-apis/documentation#bulk-download-api
#'
#' For more details on the Download bulk Report (URL File) data caveats, please refer to the
#' official Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#sar-fixed-infrastructure-data-caveats
#'
#' @param id Required. Character. Unique identifier (ID) of the bulk report. Example:
#' `"adbb9b62-5c08-4142-82e0-b2b575f3e058"`.
#'
#' @param file Required. Character. Type of bulk report file. Defaults to `"DATA"`.
#' Allowed values: `"DATA"`, `"README"`, `"GEOM"`. Example: `"DATA"`.
#'
#' @param key Character. API token. Defaults to [gfw_auth()].
#'
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string.
#'
#' @return
#' A single-row tibble with the signed URL to download bulk report file.
#'
#' @examples
#' \dontrun{
#' library(gfwr)
#' }
#'
#' @keywords internal
#' @noRd
gfw_get_bulk_report_file_download_url <- function(id = NULL,
                                                  file = NULL,
                                                  key = gfw_auth(),
                                                  print_request = FALSE) {
  ## Validate report id -------------------------------------------------------
  if (!rlang::is_string(id) || !nzchar(id)) {
    rlang::abort("`id` is required and must be a non-empty character string.")
  }

  ## Validate file ------------------------------------------------------------

  allowed_files <- c(
    "DATA",
    "README",
    "GEOM"
  )

  if (!rlang::is_string(file) || !nzchar(file)) {
    rlang::abort("`file` is required and must be a non-empty character string.")
  }

  file <- toupper(trimws(file))

  if (!file %in% allowed_files) {
    invalid_file_message <- glue::glue(
      "Invalid `file` value: {file}. ",
      "Allowed value(s): {paste(allowed_files, collapse = ', ')}."
    )
    rlang::abort(invalid_file_message)
  }

  ## Validate key -------------------------------------------------------------
  if (!rlang::is_string(key) || !nzchar(key)) {
    rlang::abort("No API token found. Set `GFW_TOKEN` or pass `key`.")
  }

  ## Build API request --------------------------------------------------------
  req <- httr2::request(gfw_base_url()) |>
    httr2::req_url_path_append("bulk-reports", id) |>
    httr2::req_url_query(file = file) |>
    httr2::req_auth_bearer_token(key) |>
    httr2::req_headers(
      `Content-Type` = "application/json"
    ) |>
    httr2::req_user_agent(gfw_user_agent()) |>
    httr2::req_error(body = \(x) parse_response_error(x)$formatted)

  if (print_request) {
    print(req)
  }

  # Perform request
  resp <- req |> httr2::req_perform()

  ## Build API response -------------------------------------------------------

  # Extract JSON response body
  resp_body <- httr2::resp_body_json(resp, check_type = TRUE, simplifyVector = FALSE)

  # Normalize response body
  resp_body <- resp_body |>
    purrr::map(\(x) list(x))

  # Transform response body to dataframe
  resp_df <- tibble::tibble(!!!resp_body)

  return(resp_df)
}

# gfw_get_all_bulk_reports ----------------------------------------------------

#' Get all bulk reports created by user or application
#'
#' @description
#' This is internal function to retrieve a list of metadata and status of the
#' previously created bulk reports based on specified pagination, sorting, and
#' filtering criteria.
#'
#' @details
#' For detailed information about the Get All Bulk Reports API endpoint, please refer to the
#' official Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#get-all-bulk-reports-by-user
#' - https://globalfishingwatch.org/our-apis/documentation#bulk-download-api
#'
#' For more details on the Get All Bulk Reports data caveats, please refer to the
#' official Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#sar-fixed-infrastructure-data-caveats
#'
#' @param limit Optional. Integer. Maximum number of bulk reports to return.
#' Defaults to `99999`. Example: `99999`.
#'
#' @param offset Optional. Integer. Number of bulk reports to skip before returning results.
#' Defaults to `0`. Example: `0`.
#'
#' @param sort Optional. Character. Property to sort the bulk reports by.
#' Defaults to `"-createdAt"`. Example: `"-createdAt"`.
#'
#' @param status Optional. Character. Current status of the bulk report generation process.
#' Defaults to `NULL`. Allowed values: `"pending"`, `"processing"`, `"done"`, `"failed"`.
#' Example: `"done"`.
#'
#' @param key Character. API token. Defaults to [gfw_auth()].
#'
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string.
#'
#' @return
#' A tibble with the previously created bulk reports metadata and status.
#'
#' @examples
#' \dontrun{
#' library(gfwr)
#' }
#'
#' @keywords internal
#' @noRd
gfw_get_all_bulk_reports <- function(limit = 99999L,
                                     offset = 0L,
                                     sort = "-createdAt",
                                     status = NULL,
                                     key = gfw_auth(),
                                     print_request = FALSE) {
  ## Validate limit -----------------------------------------------------------
  if (!rlang::is_integerish(limit, n = 1, finite = TRUE) || limit < 0) {
    rlang::abort("`limit` must be a non-negative integer value.")
  }
  limit <- as.integer(limit)

  ## Validate offset ----------------------------------------------------------
  if (!rlang::is_integerish(offset, n = 1, finite = TRUE) || offset < 0) {
    rlang::abort("`offset` must be a non-negative integer value.")
  }
  offset <- as.integer(offset)

  ## Validate sort ------------------------------------------------------------
  if (!is.null(sort)) {
    if (!rlang::is_string(sort) || !nzchar(sort)) {
      rlang::abort("`sort` must be a non-empty character string.")
    }
  }

  ## Validate status ----------------------------------------------------------
  if (!is.null(status)) {
    status <- rlang::arg_match0(
      arg = tolower(trimws(as.character(status))),
      values = c("pending", "processing", "done", "failed"),
      arg_nm = "status"
    )
  }

  ## Validate key -------------------------------------------------------------
  if (!rlang::is_string(key) || !nzchar(key)) {
    rlang::abort("No API token found. Set `GFW_TOKEN` or pass `key`.")
  }

  ## Build API request parameters ---------------------------------------------
  req_params <- list(
    limit = limit,
    offset = offset,
    sort = sort,
    status = status
  ) |> purrr::discard(is.null)

  ## Build API request --------------------------------------------------------
  req <- httr2::request(gfw_base_url()) |>
    httr2::req_url_path_append("bulk-reports") |>
    httr2::req_url_query(!!!req_params) |>
    httr2::req_auth_bearer_token(key) |>
    httr2::req_headers(
      `Content-Type` = "application/json"
    ) |>
    httr2::req_user_agent(gfw_user_agent()) |>
    httr2::req_error(body = \(x) parse_response_error(x)$formatted)

  if (print_request) {
    print(req)
  }

  # Perform request
  resp <- req |> httr2::req_perform()

  ## Build API response -------------------------------------------------------

  # Extract JSON response body
  resp_body <- httr2::resp_body_json(resp, check_type = TRUE, simplifyVector = FALSE)

  # Extract, filter and normalize response entries
  resp_entries <- purrr::pluck(resp_body, "entries", .default = list()) |>
    purrr::keep(\(entry) rlang::is_named(entry) && !rlang::is_empty(entry))

  # Return empty tibble for invalid or empty entries
  if (rlang::is_empty(resp_entries)) {
    return(tibble::tibble())
  }

  # Transform response entries to dataframe
  resp_df <- resp_entries |>
    purrr::map(\(entry) {
      entry |>
        purrr::map(\(val) if (is.list(val) || length(val) > 1) list(val) else val) |>
        tibble::as_tibble_row()
    }) |>
    purrr::list_rbind()

  return(resp_df)
}
