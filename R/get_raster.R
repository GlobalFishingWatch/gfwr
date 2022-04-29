#'Base function to get raster from API and convert response to data frame
#'
#' @param spatial_resolution raster spatial resolution. Can be "low" = 0.1 degree or "high" = 0.01 degree
#' @param temporal_resolution raster temporal resolution. Can be 'daily','monthly','yearly'.
#' @param group_by parameter to group by. Can be 'vessel_id', 'flag', 'geartype', 'flagAndGearType'
#' @param start_date Start of date range for raster
#' @param end_date End of date range for raster
#' @param format output format. Current support for 'csv'.
#' @param shape_json geojson, shape to filter raster
#' @param key Authorization token. Can be obtained with gfw_auth function
#'
#' @importFrom dplyr across
#' @importFrom dplyr mutate
#' @importFrom httr content
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom purrr map_dfr
#' @importFrom rlang .data
#' @importFrom tibble as_tibble
#' @importFrom tibble enframe
#' @importFrom tidyr pivot_wider
#' @importFrom tidyr unnest_wider
#' @importFrom tidyselect everything

get_raster <- function(spatial_resolution = NULL,
                       temporal_resolution = NULL,
                       group_by = NULL,
                       start_date = NULL,
                       end_date = NULL,
                       format= 'csv',
                       shape_json = NULL,
                       key
) {

  # Event datasets to pass to param list
  endpoint <- get_endpoint(dataset_type = 'raster',
                           `spatial-resolution` = spatial_resolution,
                           `temporal-resolution` = temporal_resolution,
                           `group-by` = group_by,
                           start_date = start_date,
                           end_date = end_date,
                           format = format)

  # API call
  # TODO: Add exception handling
  # TODO: Handle paginated responses
  gfw_json <- httr::POST(endpoint,
                        config = httr::add_headers(Authorization = paste("Bearer", key, sep = " ")),
                        body = shape_json,
                        content_type = 'application/json'
  )

  # Make request
  gfw_list <- httr::content(gfw_json)

  # unzip download and read as
  temp <- tempfile()
  writeBin(gfw_list, temp)
  names <- utils::unzip(temp,list = TRUE)$Name

  # OPTION: could incorporate `format` to process .tif as well
  file = unz(temp,names[grepl('.csv$',names)])
  return(readr::read_csv(file))
}
