#'Base function to get event from API and convert response to data frame
#'
#' @param event_type Type of event to get data of. It can be "port_visit" or "fishing"
#' @param response_limit Number of events to import. We need some documentation for the max.
#' @param vessel VesselID. How to get this?
#' @param include_regions Whether to include regions? Ask engineering if this can always be false
#' @param start_date Start of date range to search events
#' @param end_date End of date range to search events
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

get_raster <- function(spatialResolution = NULL,
                       temporalResolution = NULL,
                       groupBy = NULL,
                       start_date = NULL,
                       end_date = NULL,
                       format= NULL,
                       shape_json = NULL,
                       key
) {

  # Event datasets to pass to param list
  endpoint <- get_endpoint(dataset_type = 'raster',
                           spatialResolution = spatialResolution,
                           temporalResolution = temporalResolution,
                           groupBy = groupBy,
                           start_date = start_date,
                           end_date = end_date,
                           format= format)


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

  return(readr::read_csv(unz(temp,names[grepl('.csv',names)])))

}
