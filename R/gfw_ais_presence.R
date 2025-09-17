#' Retrieve vessel presence from AIS data and convert response to tibble
#'
#' This function communicates with the `public-global-presence` latest dataset to
#' extract global vessel presence derived from AIS data. The presence is
#' determined by taking one position per hour per vessel from the positions
#' transmitted by the vessel's AIS. Unlike the apparent fishing effort dataset,
#' this includes all vessel types and focuses on presence rather than fishing
#' classification.
#'
#' @param spatial_resolution Raster spatial resolution. Can be `"LOW"` (0.1 degree)
#'  or `"HIGH"` (0.01 degree).
#' @param temporal_resolution Raster temporal resolution. Can be `"HOURLY"`,
#' `"DAILY"`, `"MONTHLY"`, `"YEARLY"`.
#' @param start_date Required. Start of date range to search events, in
#' YYYY-MM-DD format and including this date.
#' @param end_date Required. End of date range to search events, in
#' YYYY-MM-DD format and __excluding this date__.
#' @param region_source Required. Source of the region: `"EEZ"`, `"MPA"`,
#' `"RFMO"` or `"USER_SHAPEFILE"`.
#' @param region Required. If `region_source` is set to `"EEZ"`, `"MPA"` or
#' `"RFMO"`, GFW region code (see [gfw_region_id()]). If
#' `region_source = "USER_SHAPEFILE"`, `sf` shapefile with the area of interest.
#' @param group_by Optional. Parameter to group by. Can be `"VESSEL_ID"`, `"FLAG"`,
#' `"GEARTYPE"`, `"FLAGANDGEARTYPE"` or `"MMSI"`.
#' @param filter_by Fields to filter AIS-based vessel presence. Possible options
#' are `flag`, `vessel_type`, `speed`. See Details for more information
#'
#'
#' @details
#' The `filter_by` parameter accepts `flag`, `vessel_type`, `speed` options.
#' This parameter accepts SQL expressions like `filter_by = "flag IN ('ESP')"`,
#' `flag in ('ESP', 'USA')`, `vessel_type = 'cargo'`. Accepted vessel speed
#' ranges are the following:
#'  + `<2` – Less than 2 knots
#'  + `2-4` – 2 to 4 knots
#'  + `4-6` – 4 to 6 knots
#'  + `6-10` – 6 to 10 knots
#'  + `10-15` – 10 to 15 knots
#'  + `15-25` – 15 to 25 knots
#'  + `>25` – Greater than 25 knots
#'
#' @param key Character, API token. Defaults to [gfw_auth()].
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string.
#' @importFrom readr read_csv
#' @importFrom httr2 resp_body_raw
#' @importFrom httr2 req_body_raw
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_error
#' @importFrom httr2 req_perform
#' @importFrom lubridate interval
#' @importFrom lubridate date
#' @importFrom lubridate days
#' @importFrom utils unzip
#' @importFrom rjson toJSON
#' @importFrom methods is
#' @import class
#'
#' @export
#'
#' @references AIS vessel presence examples in the API documentation https://globalfishingwatch.org/our-apis/documentation#report-ais-vessel-presence-examples
#'
#' @examples
#' \dontrun{
#' library(gfwr)
#' # using region codes
#'
#' code_eez <- gfw_region_id(region_name = "CIV", region_source = "EEZ")
#' gfw_ais_presence(spatial_resolution = "LOW",
#'            temporal_resolution = "YEARLY",
#'            group_by = "FLAG",
#'            start_date = "2021-01-01",
#'            end_date = "2021-01-10",
#'            region = code_eez$id,
#'            region_source = "EEZ",
#'            key = gfw_auth(),
#'            print_request = TRUE)
#'
#' # Grouping by flag
#'
#' code_mpa <- gfw_region_id(region_name = "Galapagos", region_source = "MPA")
#' gfw_ais_presence(spatial_resolution = "LOW",
#'            temporal_resolution = "MONTHLY",
#'            group_by = "FLAG",
#'            start_date = "2022-01-01",
#'            end_date = "2022-02-01",
#'            region = code_mpa$id[3],
#'            region_source = "MPA")
#'
#' # Filter by flag but grouping by VESSEL_ID
#'
#' code_mpa <- gfw_region_id(region_name = "Galapagos", region_source = "MPA")
#' gfw_ais_presence(spatial_resolution = "LOW",
#'            temporal_resolution = "MONTHLY",
#'            group_by = "VESSEL_ID",
#'            filter_by = "flag in ('ECU')",
#'            start_date = "2022-01-01",
#'            end_date = "2022-02-01",
#'            region = code_mpa$id[3],
#'            region_source = "MPA")
#'
#' code_rfmo <- gfw_region_id(region_name = "GFCM", region_source = "RFMO")
#' gfw_ais_presence(spatial_resolution = "LOW",
#'            temporal_resolution = "YEARLY",
#'            start_date = "2022-01-01",
#'            end_date = "2023-01-01",
#'            region = code_rfmo$id[1],
#'            region_source = "RFMO")
#'
#' # Using a sf from disk /loading a test sf object
#' data(test_shape)
#' gfw_ais_presence(spatial_resolution = "LOW",
#'             temporal_resolution = "YEARLY",
#'             start_date = "2021-01-01",
#'             end_date = "2021-02-01",
#'             region = test_shape,
#'             region_source = "USER_SHAPEFILE",
#'             key = gfw_auth(),
#'             print_request = TRUE)
#' }
gfw_ais_presence <- function(spatial_resolution = NULL,
                             temporal_resolution = NULL,
                             start_date = NULL,
                             end_date = NULL,
                             region_source = NULL,
                             region = NULL,
                             group_by = NULL,
                             filter_by = NULL,
                             key = gfw_auth(),
                             print_request = FALSE) {

  ais_presence <- gfw_4wings(api_endpoint = "AISpres",
                             spatial_resolution = spatial_resolution,
                             temporal_resolution = temporal_resolution,
                             start_date = start_date,
                             end_date = end_date,
                             region_source = region_source,
                             region = region,
                             group_by = group_by,
                             filter_by = filter_by,
                             key = key,
                             print_request = print_request)

  return(ais_presence)
}

