#' Retrieve vessel insights for one or several vessel IDs
#'
#' @description
#' The Global Fishing Watch (GFW) Insights API provides a set of vessel-level
#' analytical indicators ("vessel insights") that combine information on a
#' vessel’s observed activity (primarily derived from AIS), vessel identity
#' records, and publicly available authorizations.
#'
#' The primary objective of vessel insights is to support risk-based
#' decision-making, operational planning, and due diligence by helping users
#' identify vessel characteristics and behaviors that may indicate an increased
#' likelihood of involvement in Illegal, Unreported, or Unregulated (IUU)
#' fishing.
#'
#' This function retrieves vessel insights for one or more vessel identifiers (IDs)
#' over a specified time period. Users may specify which insight types to
#' include. The response summarizes detected events and indicators; detailed
#' event-level information can be retrieved separately using the
#' Events API: https://globalfishingwatch.org/our-apis/documentation#events-api.
#'
#' @details
#' The following insight types are supported via the `includes` argument:
#' - Any apparent fishing events in no-take MPAs (`"FISHING"`)
#' - Any apparent fishing events detected in areas with no known RFMO authorization (`"FISHING"`)
#' - The vessel's AIS coverage metric (`"COVERAGE"`)
#' - Any AIS off events (`"GAP"`)
#' - If the vessel is present on an RFMO IUU vessel list (`"VESSEL-IDENTITY-IUU-VESSEL-LIST"`)
#'
#' The function returns a single-row tibble with one list-column per insight
#' type requested. Each list-column contains the data corresponding to that insight type.
#'
#' For detailed information about the Insights API, please refer to the official
#' Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api
#'
#' For more details on the Insights API data caveats, please refer to the official
#' Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api-fishing-detected-in-no-take-mpas
#' - https://globalfishingwatch.org/our-apis/documentation#what-does-it-mean-that-an-api-dataset-is-in-prototype-stage
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api-fishing-event-detected-outside-known-authorized-areas
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api-coverage
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api-rfmo-iuu-vessel-listx
#'
#' @param includes Required. Character vector of insight types to include in
#' the response. Allowed values: `"FISHING"`, `"GAP"`, `"COVERAGE"`,
#' `"VESSEL-IDENTITY-IUU-VESSEL-LIST"`. Example: `c("FISHING", "GAP")`.
#'
#' @param start_date Required. The start date for the insights period in
#' `"YYYY-MM-DD"` format or Date. Example: `"2020-01-01"`.
#'
#' @param end_date Required. The end date for the insights period in
#' `"YYYY-MM-DD"` format or Date. Example: `"2025-03-03"`.
#'
#' @param vessels Required. Character vector of vessel IDs to retrieve insights for.
#' Each vessel ID must be a non-empty character string.
#' Example: `c("785101812-2127-e5d2-e8bf-7152c5259f5f", "2d26aa452-2d4f-4cae-2ec4-377f85e88dcb")`.
#'
#' @param key Character, API token. Defaults to [gfw_auth()].
#'
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string.
#'
#' @return
#' A single-row tibble where each column corresponds to a requested insight
#' type. Columns are list-columns containing the data returned by the Insights API.
#'
#' @examples
#' \dontrun{
#' library(gfwr)
#'
#' # Retrieve fishing-related insights for a single vessel
#' fishing_insights <- get_vessel_insights(
#'   includes = c("FISHING"),
#'   start_date = "2020-01-01",
#'   end_date = "2025-03-03",
#'   vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f"),
#'   print_request = TRUE
#' )
#'
#' # Retrieve AIS gap (AIS-off) insights for a single vessel
#' gap_insights <- get_vessel_insights(
#'   includes = c("GAP"),
#'   start_date = "2020-01-01",
#'   end_date = "2025-03-03",
#'   vessels = c("2339c52c3-3a84-1603-f968-d8890f23e1ed")
#' )
#'
#' # Retrieve AIS coverage metrics insights for a single vessel
#' coverage_insights <- get_vessel_insights(
#'   includes = c("COVERAGE"),
#'   start_date = as.Date("2020-01-01"),
#'   end_date = as.Date("2025-03-03"),
#'   vessels = c("2339c52c3-3a84-1603-f968-d8890f23e1ed")
#' )
#'
#' # Retrieve being listed in IUU list insights for a single vessel
#' iuu_insights <- get_vessel_insights(
#'   includes = c("VESSEL-IDENTITY-IUU-VESSEL-LIST"),
#'   start_date = "2020-01-01",
#'   end_date = "2025-03-03",
#'   vessels = c("2d26aa452-2d4f-4cae-2ec4-377f85e88dcb")
#' )
#'
#' # Retrieve all available insights for multiple vessels
#' all_insights <- get_vessel_insights(
#'   includes = c(
#'     "FISHING",
#'     "GAP",
#'     "COVERAGE",
#'     "VESSEL-IDENTITY-IUU-VESSEL-LIST"
#'   ),
#'   start_date = "2020-01-01",
#'   end_date = "2025-03-03",
#'   vessels = c(
#'     "785101812-2127-e5d2-e8bf-7152c5259f5f",
#'     "2339c52c3-3a84-1603-f968-d8890f23e1ed",
#'     "2d26aa452-2d4f-4cae-2ec4-377f85e88dcb"
#'   ),
#'   print_request = TRUE
#' )
#' }
#'
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
    vessels = purrr::map(vessels, \(x) list(datasetId = dataset_id, vesselId = x))
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
  req <- req |> httr2::req_error(body = \(x) parse_response_error(x)$formatted)

  # Perform request
  resp <- req |> httr2::req_perform()

  # Build API response --------------------------------------------------------

  # Extract JSON response body
  resp_body <- httr2::resp_body_json(resp, check_type = TRUE, simplifyVector = FALSE)

  # Normalize response body
  resp_body <- resp_body |>
    purrr::map(\(x) if (is.null(x) || identical(x, NA)) list() else x) |>
    purrr::map(\(x) list(x))

  # Transform response body to dataframe
  resp_df <- tibble::tibble(!!!resp_body)

  return(resp_df)
}
