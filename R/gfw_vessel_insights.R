#' Retrieve vessel insights for one or several vessel IDs
#'
#' @description
#' The Global Fishing Watch (GFW) Insights API provides a set of vessel-level
#' analytical indicators ("vessel insights") that combine information on a
#' vessel's observed activity (primarily derived from AIS), vessel identity
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
#' Events API: https://globalfishingwatch.org/our-apis/documentation/docs/v3/events.
#'
#' @details
#' The following insight types are supported via the `includes` argument:
#' - Any apparent fishing events in no-take MPAs (`"FISHING"`)
#' - Any apparent fishing events detected in areas with no known RFMO authorization (`"FISHING"`)
#' - The vessel's AIS coverage metric (`"COVERAGE"`)
#' - Any AIS off/disabling events (`"GAP"`)
#' - If the vessel is present on an RFMO IUU vessel list (`"VESSEL-IDENTITY-IUU-VESSEL-LIST"`)
#' - The vessel's flag changes (`"VESSEL-IDENTITY-FLAG-CHANGES"`)
#' - The vessel's flag state presence under the Tokyo/Paris MOU black or grey lists (`"VESSEL-IDENTITY-MOU-LIST"`)
#' - Longline Set events (`"LONGLINE-SETS"`)
#'
#' The function returns a single-row tibble with one list-column per insight
#' type requested. Each list-column contains the data corresponding to that insight type.
#'
#' For detailed information about the Insights API, please refer to the official
#' Global Fishing Watch API documentation:
#' - [Vessel Insights API](https://globalfishingwatch.org/our-apis/documentation/docs/v3/insights)
#'
#' For more details on the Insights API data caveats, please refer to the official
#' Global Fishing Watch API documentation:
#' - [Fishing detected in no-take mpas](https://globalfishingwatch.org/our-apis/documentation/docs/v3/general-api-doc/data-caveats#insights-api-fishing-detected-in-no-take-mpas)
#' - [Fishing event detected outside known authorized areas](https://globalfishingwatch.org/our-apis/documentation/docs/v3/general-api-doc/data-caveats#insights-api-fishing-event-detected-outside-known-authorized-areas)
#' - [Coverage](https://globalfishingwatch.org/our-apis/documentation/docs/v3/general-api-doc/data-caveats#insights-api-coverage)
#' - [Longline Set events](https://globalfishingwatch.org/our-apis/documentation/docs/v3/general-api-doc/data-caveats#insights-api---longline-set-events)
#' - [RFMO IUU vessel list](https://globalfishingwatch.org/our-apis/documentation/docs/v3/general-api-doc/data-caveats#insights-api---rfmo-iuu-vessel-list)
#' - [What does it mean that an API dataset is in prototype stage?](https://globalfishingwatch.org/our-apis/documentation/docs/v3/general-api-doc/data-caveats#what-does-it-mean-that-an-api-dataset-is-in-prototype-stage)
#'
#' @param includes Required. Character vector of insight types to include in
#' the response. Allowed values: `"COVERAGE"`, `"FISHING"`, `"GAP"`, `"LONGLINE-SETS"`,
#' `"VESSEL-IDENTITY-FLAG-CHANGES"`, `"VESSEL-IDENTITY-IUU-VESSEL-LIST"`, `"VESSEL-IDENTITY-MOU-LIST"`.
#' Example: `c("FISHING", "GAP")`.
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
#' # Retrieve apparent fishing-related insights for a single vessel
#' fishing_insights <- gfw_vessel_insights(
#'   includes = c("FISHING"),
#'   start_date = "2020-01-01",
#'   end_date = "2025-03-03",
#'   vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f"),
#'   print_request = TRUE
#' )
#'
#' # Retrieve AIS gap (AIS-off) insights for a single vessel
#' gap_insights <- gfw_vessel_insights(
#'   includes = c("GAP"),
#'   start_date = "2020-01-01",
#'   end_date = "2025-03-03",
#'   vessels = c("2339c52c3-3a84-1603-f968-d8890f23e1ed")
#' )
#'
#' # Retrieve AIS coverage metrics insights for a single vessel
#' coverage_insights <- gfw_vessel_insights(
#'   includes = c("COVERAGE"),
#'   start_date = as.Date("2020-01-01"),
#'   end_date = as.Date("2025-03-03"),
#'   vessels = c("2339c52c3-3a84-1603-f968-d8890f23e1ed")
#' )
#'
#' # Retrieve longline set insights for a single vessel
#' longline_set_insights <- gfw_vessel_insights(
#'   includes = c("LONGLINE-SETS"),
#'   start_date = as.Date("2020-01-01"),
#'   end_date = as.Date("2025-03-03"),
#'   vessels = c("2339c52c3-3a84-1603-f968-d8890f23e1ed")
#' )
#'
#' # Retrieve being listed in IUU list insights for a single vessel
#' iuu_insights <- gfw_vessel_insights(
#'   includes = c("VESSEL-IDENTITY-IUU-VESSEL-LIST"),
#'   start_date = "2020-01-01",
#'   end_date = "2025-03-03",
#'   vessels = c("2d26aa452-2d4f-4cae-2ec4-377f85e88dcb")
#' )
#'
#' # Retrieve flag changes insights for a single vessel
#' flag_changes_insights <- gfw_vessel_insights(
#'   includes = c("VESSEL-IDENTITY-FLAG-CHANGES"),
#'   start_date = "2020-01-01",
#'   end_date = "2025-03-03",
#'   vessels = c("2d26aa452-2d4f-4cae-2ec4-377f85e88dcb")
#' )
#'
#' # Retrieve flag state presence under the Tokyo/Paris MOU black or grey lists
#' # insights for a single vessel
#' mou_insights <- gfw_vessel_insights(
#'   includes = c("VESSEL-IDENTITY-MOU-LIST"),
#'   start_date = "2020-01-01",
#'   end_date = "2025-03-03",
#'   vessels = c("2339c52c3-3a84-1603-f968-d8890f23e1ed")
#' )
#'
#' # Retrieve all available insights for multiple vessels
#' all_insights <- gfw_vessel_insights(
#'   includes = c(
#'     "COVERAGE",
#'     "FISHING",
#'     "GAP",
#'     "LONGLINE-SETS",
#'     "VESSEL-IDENTITY-FLAG-CHANGES",
#'     "VESSEL-IDENTITY-IUU-VESSEL-LIST",
#'     "VESSEL-IDENTITY-MOU-LIST"
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
gfw_vessel_insights <- function(includes = NULL,
                                start_date = NULL,
                                end_date = NULL,
                                vessels = NULL,
                                key = gfw_auth(),
                                print_request = FALSE) {
  # Validate includes ---------------------------------------------------------

  allowed_includes <- c(
    "COVERAGE",
    "FISHING",
    "GAP",
    "LONGLINE-SETS",
    "VESSEL-IDENTITY-FLAG-CHANGES",
    "VESSEL-IDENTITY-IUU-VESSEL-LIST",
    "VESSEL-IDENTITY-MOU-LIST"
  )

  if (!is.character(includes) || length(includes) == 0L) {
    cli::cli_abort("{.arg includes} is required and must be a non-empty character vector.")
  }

  includes <- trimws(toupper(includes))
  invalid_includes <- unique(setdiff(includes, allowed_includes))

  if (length(invalid_includes) > 0L) {
    cli::cli_abort(
      c(
        "Invalid {.arg includes} value(s).",
        "x" = "Unknown value(s): {.val {invalid_includes}}.",
        "i" = "Allowed values: {.or {.val {allowed_includes}}}."
      )
    )
  }

  includes <- unique(includes)

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

    cli::cli_abort(
      c(
        "Invalid {.arg {name}} value.",
        "x" = "Supplied value: {.val {x}}.",
        "i" = "{.arg {name}} must be in {.val YYYY-MM-DD} format or a {.cls Date} object."
      )
    )
  }

  start_date <- parse_date(start_date, "start_date")
  end_date <- parse_date(end_date, "end_date")

  if (start_date > end_date) {
    cli::cli_abort(
      c(
        "Invalid date range.",
        "x" = "{.arg start_date} must be less than or equal to {.arg end_date}.",
        "i" = "Supplied range: {.val {start_date}} to {.val {end_date}}."
      )
    )
  }

  # Validate vessels ----------------------------------------------------------

  if (!is.character(vessels) || length(vessels) == 0L) {
    cli::cli_abort("{.arg vessels} is required and must be a non-empty character vector.")
  }

  vessels <- trimws(vessels)
  invalid_vessels <- vessels[is.na(vessels) | vessels == ""]

  if (length(invalid_vessels) > 0L) {
    cli::cli_abort(
      c(
        "Invalid {.arg vessels} value(s).",
        "x" = "Invalid value(s): {.val {invalid_vessels}}.",
        "i" = "Each vessel ID must be a non-empty, non-NA character string."
      )
    )
  }

  vessels <- unique(vessels)

  # Validate key --------------------------------------------------------------
  if (is.null(key) || identical(key, "") || is.na(key)) {
    cli::cli_abort(
      c(
        "No API token found.",
        "i" = "Set {.envvar GFW_TOKEN} or pass a valid {.arg key}."
      )
    )
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
