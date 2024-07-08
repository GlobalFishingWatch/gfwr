#' Base function to get raster from API and convert response to data frame
#'
#' @param spatial_resolution raster spatial resolution. Can be "LOW" = 0.1 degree
#'  or "HIGH" = 0.01 degree
#' @param temporal_resolution raster temporal resolution. Can be 'HOURLY',
#' 'DAILY', 'MONTHLY', 'YEARLY'
#' @param group_by parameter to group by. Can be 'VESSEL_ID', 'FLAG', 'GEARTYPE',
#'  'FLAGANDGEARTYPE' or 'MMSI'. Optional.
#' @param filter_by parameter to filter by.
#' @param start_date Start of date range to search events, in YYYY-MM-DD format and including this date
#' @param end_date End of date range to search events, in YYYY-MM-DD format and excluding this date
#' @param region sf shape to filter raster or GFW region code (such as a
#' Marine Regions Geographic Identifier or EEZ code).
#' @param region_source source of the region ('EEZ','MPA', 'RFMO' or 'USER_JSON')
#' @param key Authorization token. Can be obtained with `gfw_auth()` function
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string
#' @importFrom readr read_csv
#' @importFrom httr2 resp_body_raw
#' @importFrom httr2 req_body_raw
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_error
#' @importFrom httr2 req_perform
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
#' code_eez <- get_region_id(region_name = 'CIV', region_source = 'EEZ',
#' key = gfw_auth())
#' get_raster(spatial_resolution = 'LOW',
#'            temporal_resolution = 'YEARLY',
#'            group_by = 'FLAG',
#'            start_date = "2021-01-01",
#'            end_date = "2021-10-01",
#'            region = code_eez$id,
#'            region_source = 'EEZ',
#'            key = gfw_auth(),
#'            print_request = TRUE)
#' #using a sf from disk /loading a test sf object
#' data(test_shape)
#' get_raster(spatial_resolution = 'LOW',
#'             temporal_resolution = 'YEARLY',
#'             start_date = '2021-01-01',
#'             end_date = '2021-10-01',
#'             region = test_shape,
#'             region_source = 'USER_JSON',
#'             key = gfw_auth(),
#'             print_request = TRUE)
#' }
get_raster <- function(spatial_resolution = NULL,
                       temporal_resolution = NULL,
                       group_by = NULL,
                       filter_by = NULL,
                       start_date = NULL,
                       end_date = NULL,
                       region = NULL,
                       region_source = NULL,
                       key = gfw_auth(),
                       print_request = FALSE) {
  date_range <- paste(start_date, end_date, sep = ",")
  # Endpoint
  endpoint <- get_endpoint(
    dataset_type = "raster",
    `spatial-resolution` = spatial_resolution,
    `temporal-resolution` = temporal_resolution,
    `filters[0]` = filter_by,
    `group-by` = group_by,
    `date-range` = date_range,
    format = 'CSV'
  )

if (is.null(region_source)) stop("region_source and region params are required")
  region_source <- toupper(region_source) ## Fix capital and lower case differences
  if (region_source == 'MPA' & is.numeric(region)) {
    if (length(region) > 1) stop("only 1 MPA region must be provided")
    region <- rjson::toJSON(list(region = list(dataset = 'public-mpa-all',
                                             id = region)))
  } else if (region_source == 'EEZ' & is.numeric(region)) {
    if (length(region) > 1) stop("only 1 EEZ region must be provided")
    region <- rjson::toJSON(list(region = list(dataset = 'public-eez-areas',
                                             id = region)))
  } else if (region_source == 'RFMO' & is.character(region)) {
    if (length(region) > 1) stop("only 1 RFMO region must be provided")
    region <- rjson::toJSON(list(region = list(dataset = 'public-rfmo',
                                              id = region)))
  } else if (region_source == 'USER_JSON') {
    if (methods::is(region, 'sf') & base::class(region$geometry)[1] %in% c("sfc_POLYGON","sfc_MULTIPOLYGON")
        ) {
      region <- sf_to_geojson(region, endpoint = 'raster')
    } else {
      stop('custom region is not an sf polygon')
    }
  } else {
    stop('region source and region format do not match')
  }

  # API call
  # TODO: Handle paginated responses
  request <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer",
                                             key,
                                             sep = " "),
                       `Content-Type` = 'application/json') %>%
    httr2::req_body_raw(., body = region) #%>%
    #httr2::req_error(req = ., body = parse_response_error)
  if (print_request) print(request)
  response <- request %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_raw(.)

  # save zip and get .csv file name
  temp <- tempfile()
  writeBin(response, temp)
  names <- utils::unzip(temp, list = TRUE)$Name

  # unzip zip file and extract .csv
  file <- unz(temp, names[grepl(".csv$", names)])
  return(readr::read_csv(file))
}
