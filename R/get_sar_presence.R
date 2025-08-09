#' Retrieve vessel presence detected using SAR and convert response to tibble
#'
#' @param spatial_resolution Raster spatial resolution. Can be `"LOW"` (0.1 degree)
#'  or `"HIGH"` (0.01 degree).
#' @param temporal_resolution Raster temporal resolution. Can be `"HOURLY"`,
#' `"DAILY"`, `"MONTHLY"`, `"YEARLY"`.
#' @param start_date Required. Start of date range to search events, in
#' YYYY-MM-DD format and including this date.
#' @param end_date Required. End of date range to search events, in
#' YYYY-MM-DD format and excluding this date.
#' @param region_source Required. Source of the region: `"EEZ"`, `"MPA"`,
#' `"RFMO"` or `"USER_SHAPEFILE"`.
#' @param region Required. If `region_source` is set to `"EEZ"`, `"MPA"` or
#' `"RFMO"`, GFW region code (see [get_region_id()]). If
#' `region_source = "USER_SHAPEFILE"`, `sf` shapefile with the area of interest.
#' @param group_by Optional. Parameter to group by. Can be `"VESSEL_ID"`, `"FLAG"`,
#' `"GEARTYPE"`, `"FLAGANDGEARTYPE"` or `"MMSI"`.
#' @param filter_by Fields to filter AIS-based apparent fishing effort. Possible
#' options are `flag`, `shipname`, `geartype` and `id` (to filter for vessel ids). Receives SQL expressions like
#' `filter_by = "flag IN ('ESP')"`.
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
#' @examples
#' \dontrun{
#' library(gfwr)
#' # using region codes
#' code_eez <- get_region_id(region_name = "CIV", region_source = "EEZ")
#' get_sar_presence(spatial_resolution = "LOW",
#'            temporal_resolution = "YEARLY",
#'            group_by = "FLAG",
#'            start_date = "2021-01-01",
#'            end_date = "2022-01-01",
#'            region = code_eez$id,
#'            region_source = "EEZ",
#'            key = gfw_auth(),
#'            print_request = TRUE)
#' code_mpa <- get_region_id(region_name = "Galapagos", region_source = "MPA")
#' get_sar_presence(spatial_resolution = "LOW",
#'            temporal_resolution = "MONTHLY",
#'            group_by = "FLAG",
#'            start_date = "2022-01-01",
#'            end_date = "2023-01-01",
#'            region = code_mpa$id[3],
#'            region_source = "MPA")
#' code_rfmo <- get_region_id(region_name = "IATTC", region_source = "RFMO")
#' get_sar_presence(spatial_resolution = "LOW",
#'            temporal_resolution = "MONTHLY",
#'            start_date = "2022-01-01",
#'            end_date = "2023-01-01",
#'            region = code_rfmo$id[1],
#'            region_source = "RFMO")
#' #using a sf from disk /loading a test sf object
#' data(test_shape)
#' get_sar_presence(spatial_resolution = "LOW",
#'             temporal_resolution = "YEARLY",
#'             start_date = "2021-01-01",
#'             end_date = "2021-10-01",
#'             region = test_shape,
#'             region_source = "USER_SHAPEFILE",
#'             key = gfw_auth(),
#'             print_request = TRUE)
#' }
get_sar_presence <- function(
         spatial_resolution = NULL,
         temporal_resolution = NULL,
         start_date = NULL,
         end_date = NULL,
         region_source = NULL,
         region = NULL,
         group_by = NULL,
         filter_by = NULL,
         key = gfw_auth(),
         print_request = FALSE)
{
  sar_presence <- get_raster(
    api_data = "SAR",
    spatial_resolution = spatial_resolution,
    temporal_resolution = temporal_resolution,
    start_date = start_date,
    end_date = end_date,
    region_source = region_source,
    region = region,
    group_by = group_by,
    filter_by = filter_by,
    key = gfw_auth(),
    print_request = print_request)
  return(sar_presence)
}
