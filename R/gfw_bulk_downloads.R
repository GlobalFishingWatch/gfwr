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
