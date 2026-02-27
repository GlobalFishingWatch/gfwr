#' Retrieve datasets from the 4 wings API
#'
#' This is the basic internal function to retrieve 4wings datasets.
#' It is used under the hood by `gfw_ais_` and `gfw_sar_` functions, which are
#' split because the source data (AIS vs SAR) their documentation and parameters
#' differ
#'
#' @param api_endpoint API endpoint
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
#' @param filter_by Fields to filter, variable depending on data source.
#' @param key Character, API token. Defaults to [gfw_auth()].
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string.
#'
#' @keywords internal
#'
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
#'
#'
gfw_4wings <- function(api_endpoint = "AIS",
                       spatial_resolution = NULL,
                       temporal_resolution = NULL,
                       start_date = "2023-01-01",
                       end_date = "2023-12-31",
                       region_source = NULL,
                       region = NULL,
                       group_by = NULL,
                       filter_by = NULL,
                       key = gfw_auth(),
                       print_request = FALSE) {
  date_range <- paste(start_date, end_date, sep = ",")
  data <- api_endpoint
  if (lubridate::interval(
    start = lubridate::date(start_date),
    end = lubridate::date(end_date))/lubridate::days() > 366)
    stop("the start and end dates should be apart 366 days or less")


  if (data == "AIS") dataset_type = "raster"
  if (data == "AISpres") dataset_type = "raster-pres"
  if (data == "SAR") dataset_type = "sar-presence"
  if (data == "INFRA") dataset_type = "public-fixed-infrastructure-filtered"
  #if (data == "SARinfra") dataset_type = "sar-infra"

  # Endpoint
  endpoint <- gfw_endpoint(
    dataset_type = dataset_type,
    `spatial-resolution` = spatial_resolution,
    `temporal-resolution` = temporal_resolution,
    `filters[0]` = filter_by,
    `group-by` = group_by,
    `date-range` = date_range,
    format = "CSV"
  )

if (is.null(region_source)) stop("region_source and region params are required")
  region_source <- toupper(region_source) ## Fix capital and lower case differences
  if (region_source == "MPA" ) {
    if (length(region) > 1) stop("only 1 MPA region must be provided")
    region <- rjson::toJSON(list(region = list(dataset = "public-mpa-all",
                                             id = region)))
  } else if (region_source == "EEZ") {
    if (length(region) > 1) stop("only 1 EEZ region must be provided")
    region <- rjson::toJSON(list(region = list(dataset = "public-eez-areas",
                                             id = region)))
  } else if (region_source == "RFMO" & is.character(region)) {
    if (length(region) > 1) stop("only 1 RFMO region must be provided")
    region <- rjson::toJSON(list(region = list(dataset = "public-rfmo",
                                              id = region)))
  } else if (region_source == "USER_SHAPEFILE") {
    if (methods::is(region, "sf") & any(base::class(sf::st_geometry(region)) %in% c("sfc_POLYGON","sfc_MULTIPOLYGON"))
                 ) {
      region <- sf_to_geojson(region, endpoint = "raster")
    } else {
      stop("custom region is not an sf polygon")
    }
  } else {
    stop("region source and region format do not match")
  }

  # API call
  # TODO: Handle paginated responses
  request <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer",
                                             key,
                                             sep = " "),
                       `Content-Type` = "application/json") %>%
    httr2::req_body_raw(., body = region) #%>%
    #httr2::req_error(req = ., body = parse_response_error)
  if (print_request) print(request)
  response <- request %>%
    httr2::req_user_agent(gfw_user_agent()) %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_raw(.)

  # save zip and get .csv file name
  temp <- tempfile()
  writeBin(response, temp)
  names <- utils::unzip(temp, list = TRUE)$Name

  # unzip zip file and extract .csv
  file <- unz(temp, names[grepl(".csv$", names)])
  return(readr::read_csv(file, show_col_types = FALSE))
}
