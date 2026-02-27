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
#' `"RFMO"`, GFW region code (see [gfw_region_id()]). If
#' `region_source = "USER_SHAPEFILE"`, `sf` shapefile with the area of interest.
#' @param group_by Optional. Parameter to group by. Can be `"VESSEL_ID"`, `"FLAG"`,
#' `"GEARTYPE"`, `"FLAGANDGEARTYPE"` or `"MMSI"`.
#' @param filter_by Fields to filter SAR vessel detections. See Details for possible options.
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
#' @details
#' Possible filter options are:
#' - `matched` – Whether detection matched with AIS data Example: `"matched='true'"` or `"matched='false'"`
#' - flag – Vessel flag state (when matched with AIS). Example: `"flag in ('ESP', 'USA')"`
#' - `vessel_id` – Vessel identifier (when matched with AIS). See the identity vignette for details about Vessel ID.
#' - `geartype` – Fishing gear type (when matched with AIS) → View [supported gear types](https://globalfishingwatch.org/our-apis/documentation#gear-types-supported). Example: `"geartype in ('tuna_purse_seines', 'driftnets')"`
#' - `neural_vessel_type` – AI classification based on neural network model. Values: <= 0.1: "Likely non-fishing", >= 0.9: "Likely fishing", 0.1 - 0.9: "Other/Unknown"
#' - `shiptype` – Vessel type classification (when matched with AIS) → See [Vessel types](https://globalfishingwatch.org/our-apis/documentation#vessel-types)
#' @examples
#' \dontrun{
#' library(gfwr)
#' # using region codes
#' code_eez <- gfw_region_id(region = "Chile", region_source = "EEZ")
#' gfw_sar_vessel_detections(spatial_resolution = "LOW",
#'            temporal_resolution = "YEARLY",
#'            group_by = "FLAG",
#'            start_date = "2021-01-01",
#'            end_date = "2022-01-01",
#'            region = code_eez$id,
#'            region_source = "EEZ",
#'            key = gfw_auth())
#' # filter by matched
#' gfw_sar_vessel_detections(spatial_resolution = "LOW",
#'                           temporal_resolution = "YEARLY",
#'                           group_by = "VESSEL_ID",
#'                           filter_by = "matched = 'true'",
#'                           start_date = "2021-01-01",
#'                           end_date = "2022-01-01",
#'                           region = code_eez$id,
#'                           region_source = "EEZ",
#'                           key = gfw_auth())
#' ## Unmatched vessels will have no id information:
#' gfw_sar_vessel_detections(spatial_resolution = "LOW",
#'                           temporal_resolution = "YEARLY",
#'                           group_by = "VESSEL_ID",
#'                           filter_by = "matched = 'false'",
#'                           start_date = "2021-01-01",
#'                           end_date = "2022-01-01",
#'                           region = code_eez$id,
#'                           region_source = "EEZ",
#'                           key = gfw_auth())
#' # Filter by flag
#' gfw_sar_vessel_detections(spatial_resolution = "LOW",
#'                           temporal_resolution = "YEARLY",
#'                           group_by = "VESSEL_ID",
#'                           filter_by = "flag IN ('PER', 'ECU')",
#'                           start_date = "2021-01-01",
#'                           end_date = "2022-01-01",
#'                           region = code_eez$id,
#'                           region_source = "EEZ",
#'                           key = gfw_auth())
#' # Filter by vessel ID
#' gfw_sar_vessel_detections(spatial_resolution = "LOW",
#'                           temporal_resolution = "YEARLY",
#'                           filter_by = "vessel_id = '320335fcf-fbe5-54e0-9367-b36ae25b64b5'",
#'                           start_date = "2021-01-01",
#'                           end_date = "2022-01-01",
#'                           region = code_eez$id,
#'                           region_source = "EEZ",
#'                           key = gfw_auth())
#' # Filter by geartype
#' gfw_sar_vessel_detections(spatial_resolution = "LOW",
#'                           temporal_resolution = "YEARLY",
#'                           group_by = "VESSEL_ID",
#'                           filter_by = "geartype IN ('tuna_purse_seines',
#'                            'driftnets')",
#'                           start_date = "2021-01-01",
#'                           end_date = "2022-01-01",
#'                           region = code_eez$id,
#'                           region_source = "EEZ",
#'                           key = gfw_auth())
#' # Filter by neural_vessel_type
#' gfw_sar_vessel_detections(spatial_resolution = "LOW",
#'                           temporal_resolution = "YEARLY",
#'                           filter_by = "neural_vessel_type = '0.3'",
#'                           start_date = "2021-01-01",
#'                           end_date = "2022-01-01",
#'                           region = code_eez$id,
#'                           region_source = "EEZ",
#'                           key = gfw_auth())
#' # Filter by shiptype (vessel type)
#' gfw_sar_vessel_detections(spatial_resolution = "LOW",
#'                           temporal_resolution = "YEARLY",
#'                           filter_by = "shiptype = 'CARGO'",
#'                           start_date = "2021-01-01",
#'                           end_date = "2022-01-01",
#'                           region = code_eez$id,
#'                           region_source = "EEZ",
#'                           key = gfw_auth())
#'
#'
#' }
gfw_sar_vessel_detections <- function(spatial_resolution = NULL,
                                  temporal_resolution = NULL,
                                  start_date = NULL,
                                  end_date = NULL,
                                  region_source = NULL,
                                  region = NULL,
                                  group_by = NULL,
                                  filter_by = NULL,
                                  key = gfw_auth(),
                                  print_request = FALSE) {

   sar_presence <- gfw_4wings(api_endpoint = "SAR",
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
  return(sar_presence)
}
