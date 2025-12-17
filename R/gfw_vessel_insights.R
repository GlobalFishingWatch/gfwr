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
#' @param vessels Required. Character vector of vessel IDs to retrieve insights for.
#' Each vessel ID must be a non-empty character string.
#' Example: `c("785101812-2127-e5d2-e8bf-7152c5259f5f", "2339c52c3-3a84-1603-f968-d8890f23e1ed")`.
#' @param key Character, API token. Defaults to [gfw_auth()].
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string.
#' @return List of vessel insights result.
#' @examples
#' \dontrun{
#' library(gfwr)
#'
#' get_vessel_insights(
#'   includes = c("FISHING"),
#'   start_date = "2020-01-01",
#'   end_date = "2025-03-03",
#'   vessels = c(
#'     "785101812-2127-e5d2-e8bf-7152c5259f5f",
#'     "2339c52c3-3a84-1603-f968-d8890f23e1ed"
#'   ),
#'   print_request = TRUE
#' )
#' }
#' @export
get_vessel_insights <- function(includes = NULL,
                                start_date = NULL,
                                end_date = NULL,
                                vessels = NULL,
                                key = gfw_auth(),
                                print_request = FALSE) {
  # Validate includes ---------------------------------------------------------

  allowed_includes <- c(
    "FISHING", "GAP", "COVERAGE", "VESSEL-IDENTITY-IUU-VESSEL-LIST"
  )

  if (!is.character(includes) || length(includes) == 0) {
    rlang::abort("`includes` is required and must be a non-empty character vector.")
  }

  includes <- trimws(toupper(includes))
  invalid_includes <- setdiff(includes, allowed_includes)

  if (length(invalid_includes) > 0) {
    invalid_includes_message <- glue::glue(
      "Invalid `includes` value(s): {paste(invalid_includes, collapse = ', ')}. ",
      "Allowed value(s): {paste(allowed_includes, collapse = ', ')}."
    )
    rlang::abort(invalid_includes_message)
  }

  # Validate dates ------------------------------------------------------------

  parse_date <- function(x, name) {
    if (inherits(x, "Date")) {
      return(x)
    }
    if (is.character(x)) {
      parsed <- suppressWarnings(lubridate::ymd(x))
      if (!is.na(parsed)) {
        return(parsed)
      }
    }
    invalid_date_message <- glue::glue(
      "Invalid `{name}`: {x}. ",
      "`{name}` must be in YYYY-MM-DD format or Date object."
    )
    rlang::abort(invalid_date_message)
  }

  start_date <- parse_date(start_date, "start_date")
  end_date <- parse_date(end_date, "end_date")

  if (start_date > end_date) {
    rlang::abort("`start_date` must be less than or equal to `end_date`.")
  }

  # Validate vessels ----------------------------------------------------------

  if (!is.character(vessels) || length(vessels) == 0) {
    rlang::abort("`vessels` is required and must be a non-empty character vector.")
  }

  vessels <- trimws(vessels)
  invalid_vessels <- vessels[is.na(vessels) | vessels == ""]

  if (length(invalid_vessels) > 0) {
    invalid_vessels_message <- glue::glue(
      "Invalid `vessels` value(s): {paste(invalid_vessels, collapse = ', ')}. ",
      "Each vessel ID must be a non-empty, non-NA character string."
    )
    rlang::abort(invalid_vessels_message)
  }

  # Validate key --------------------------------------------------------------
  if (is.null(key) || identical(key, "") || is.na(key)) {
    rlang::abort("No API token found. Set `GFW_TOKEN` or pass `key`.")
  }

  # Build API request body ----------------------------------------------------
  dataset_id <- "public-global-vessel-identity:latest"
  req_body <- list(
    includes = as.list(includes),
    startDate = format(start_date, "%Y-%m-%d"),
    endDate = format(end_date, "%Y-%m-%d"),
    vessels = purrr::map(vessels, function(vessel_id) {
      list(
        datasetId = dataset_id,
        vesselId = vessel_id
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

  if (print_request) {
    print(req)
  }

  # Attach error parser
  req <- req |> httr2::req_error(body = function(r) parse_response_error(r)$formatted)

  #   Perform request
  resp <- req |> httr2::req_perform()

  # Parse and return API response ---------------------------------------------
  resp_body <- httr2::resp_body_json(resp, check_type = TRUE, simplifyVector = FALSE)
  return(resp_body)
}
