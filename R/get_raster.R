#' Base function to get raster from API and convert response to data frame
#'
#' @param spatial_resolution raster spatial resolution. Can be "low" = 0.1 degree or "high" = 0.01 degree
#' @param temporal_resolution raster temporal resolution. Can be 'daily','monthly','yearly'.
#' @param group_by parameter to group by. Can be 'vessel_id', 'flag', 'geartype', 'flagAndGearType'
#' @param date_range Start and end of date range for raster
#' @param region geojson or GFW region code, shape to filter raster
#' @param region_source source of the region ('eez','mpa', or 'user_json')
#' @param key Authorization token. Can be obtained with gfw_auth function
#' @importFrom magrittr `%>%`
#' @importFrom readr read_csv
#' @importFrom httr2 resp_body_raw
#' @importFrom httr2 req_body_raw
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_error
#' @importFrom httr2 req_perform
#' @importFrom utils unzip
#' @importFrom rjson toJSON
#'
#' @export
#'
#' @details
#' See examples at https://github.com/GlobalFishingWatch/gfwr

get_raster <- function(spatial_resolution = NULL,
                       temporal_resolution = NULL,
                       group_by = NULL,
                       date_range = NULL,
                       region = NULL,
                       region_source = NULL,
                       key = gfw_auth()) {

  # Endpoint
  endpoint <- get_endpoint(
    dataset_type = "raster",
    `spatial-resolution` = spatial_resolution,
    `temporal-resolution` = temporal_resolution,
    `group-by` = group_by,
    `date-range` = date_range,
    format = 'csv'
  )



  if (region_source == 'mpa' & is.numeric(region)) {
    region = rjson::toJSON(list(region = list(dataset = 'public-mpa-all',
                                             id = region)))

  } else if (region_source == 'eez' & is.numeric(region)) {
    region = rjson::toJSON(list(region = list(dataset = 'public-eez-areas',
                                             id = region)))
  } else if (region_source == 'user_json' & is.character(region)) {
    region
  } else {
    stop('region source and region format do not match')
  }

  # API call
  # TODO: Add exception handling
  # TODO: Handle paginated responses
  response <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer",
                                             key,
                                             sep = " "),
                       `Content-Type` = 'application/json') %>%
    httr2::req_body_raw(., body = region) %>%
    httr2::req_error(req = ., body = gist_error_body) %>%
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
