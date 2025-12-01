#' Get vessels insights data
#'
#' Retrieves insights data for specified vessels to obtain vessel-level
#' indicators such as:
#' - apparent fishing inside no-take MPAs (`FISHING`)
#' - AIS off / gap events (`GAP`)
#' - AIS coverage metric (`COVERAGE`)
#' - RFMO IUU list membership (`VESSEL-IDENTITY-IUU-VESSEL-LIST`)
#'
#' For detailed information about the Insights API, please refer to the official
#' Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api
#'
#' For more details on the Insights API data caveats, please refer to the official
#' Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api-fishing-detected-in-no-take-mpas
#' - https://globalfishingwatch.org/our-apis/documentation#what-does-it-mean-that-an-api-dataset-is-in-prototype-stage
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api-fishing-event-detected-outside-known-authorized-areas # nolint: line_length_linter.
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api-coverage
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api-rfmo-iuu-vessel-list
#'
#' @param includes Required. Character vector of insight types to include in
#' the response. Allowed values: `"FISHING"`, `"GAP"`, `"COVERAGE"`,
#' `"VESSEL-IDENTITY-IUU-VESSEL-LIST"`. Example: `c("FISHING", "GAP")`.
#' @param start_date Required. The start date for the insights period in
#' `"YYYY-MM-DD"` format or Date. Example: `"2020-01-01"`.
#' @param end_date Required. The end date for the insights period in
#' `"YYYY-MM-DD"` format or Date. Example: `"2025-03-03"`.
#' @param vessels Required. List of vessel identifiers to retrieve insights.
#' Example: `list(list("vessel_id" = "785101812-2127-e5d2-e8bf-7152c5259f5f",
#' "dataset_id" = "public-global-vessel-identity:latest"))`.
#' @param key Character, API token. Defaults to [gfw_auth()].
#' @return List of vessel insights result.
#' @examples
#' \dontrun{
#' library(gfwr)
#'
#' get_vessel_insights(
#'   includes = c("FISHING"),
#'   startDate = "2020-01-01",
#'   endDate = "2025-03-03",
#'   vessels = list(
#'     list(
#'       dataset_id = "public-global-vessel-identity:latest",
#'       vessel_id = "785101812-2127-e5d2-e8bf-7152c5259f5f"
#'     )
#'   )
#' )
#' }
#' @export
get_vessel_insights <- function(includes = NULL,
                                start_date = NULL,
                                end_date = NULL,
                                vessels = NULL,
                                key = NULL) {
  # Validate includes ---------------------------------------------------------

  allowed_includes <- c(
    "FISHING", "GAP", "COVERAGE", "VESSEL-IDENTITY-IUU-VESSEL-LIST"
  )

  if (missing(includes) || length(includes) == 0) {
    rlang::abort("`includes` is required and must be a non-empty character vector.")
  }
  includes <- toupper(as.character(includes))
  invalid_includes <- setdiff(includes, allowed_includes)
  if (length(invalid_includes) > 0) {
    invalid_includes_message <- glue::glue(
      "Invalid `includes` value(s): {paste(invalid_includes, collapse = ', ')}. ",
      "Allowed value(s): {paste(allowed_includes, collapse = ', ')}"
    )
    rlang::abort(invalid_includes_message)
  }

  # Validate dates ------------------------------------------------------------
  parse_date <- function(d) {
    if (inherits(d, "Date")) {
      return(d)
    }
    if (is.character(d)) {
      dt <- tryCatch(lubridate::ymd(d, quiet = TRUE), error = function(e) NA)
      return(dt)
    }
    return(NA) # fallback for unsupported types # nolint: return_linter.
  }

  start_date <- parse_date(start_date)
  end_date <- parse_date(end_date)
  if (is.na(start_date) || is.na(end_date)) {
    rlang::abort("`start_date` and `end_date` must be in YYYY-MM-DD format or Date objects.")
  }
  if (start_date > end_date) {
    rlang::abort("`start_date` must be <= `end_date`.")
  }

  # Validate vessels ----------------------------------------------------------

  if (missing(vessels) || !is.list(vessels) || length(vessels) == 0) {
    rlang::abort("`vessels` is required and must be a non-empty list of objects with `dataset_id` and `vessel_id`.")
  }
  validate_vessel <- function(v) {
    is.list(v) &&
      !is.null(v$dataset_id) && nzchar(as.character(v$dataset_id)) &&
      !is.null(v$vessel_id) && nzchar(as.character(v$vessel_id))
  }
  invalid_vessels <- purrr::discard(vessels, validate_vessel)
  if (length(invalid_vessels) > 0) {
    rlang::abort("Each element of `vessels` must be a list with non-empty `dataset_id` and `vessel_id`.")
  }

  # Validate key --------------------------------------------------------------
  key <- key %||% gfw_auth()
  if (is.null(key) || identical(key, "") || is.na(key)) {
    rlang::abort("No API token found. Set GFW_TOKEN or pass `key`.")
  }

  # Build API request body ----------------------------------------------------
  req_body <- list(
    includes = unname(as.list(includes)),
    startDate = format(start_date, "%Y-%m-%d"),
    endDate = format(end_date, "%Y-%m-%d"),
    vessels = purrr::map(vessels, function(v) {
      list(
        datasetId = as.character(v$dataset_id),
        vesselId = as.character(v$vessel_id)
      )
    })
  )

  # Build API request ---------------------------------------------------------
  req <- httr2::request(gfw_base_url()) |>
    httr2::req_url_path_append("insights/vessels") |>
    httr2::req_headers(
      Authorization = paste("Bearer", key),
      `Content-Type` = "application/json"
    ) |>
    httr2::req_user_agent(gfw_user_agent()) |>
    httr2::req_body_json(req_body)

  # Attach error parser
  req <- req |> httr2::req_error(body = function(r) parse_response_error(r)$formatted)

  #   Perform request
  resp <- req |> httr2::req_perform()

  # Parse and return API response ---------------------------------------------
  resp_body <- httr2::resp_body_json(resp, check_type = TRUE, simplifyVector = FALSE)
  return(resp_body)
}
