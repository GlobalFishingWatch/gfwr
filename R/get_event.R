#'
#' Base function to get event from API and convert response to data frame
#'
#' @param event_type Type of event to get data of. It can be "port_visit" or "fishing"
#' @param limit Number of events to import. We need some documentation for the max.
#' @param vessel VesselID. How to get this?
#' @param auth Authorization token. Can be obtained with gfw_auth function
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

get_event <- function(event_type='port_visit',
                      response_limit = 1000,
                      vessel_list = NULL,
                      include_regions = NULL,
                      start_date = NULL,
                      end_date = NULL
                      ){


  # Event datasets to pass to param list
  event_datasets <- c(
    'port_visit' = "public-global-port-visits-c2-events:v20201001",
    'fishing' = "public-global-fishing-events:v20201001"
  )

  # Get dataset for selected event
  event_dataset <- event_datasets[event_type]

  # List of query params to pass to modify_url
  params <- list(
    dataset =  I(event_dataset),
    limit = response_limit,
    includeRegions = include_regions,
    vessels = vessel_list,
    startDate  = start_date,
    endDate = end_date
  )

  endpoint <- modify_url("https://gateway.api.globalfishingwatch.org//v1/events", query = params)

  # Get API key
  key <- Sys.getenv("GFW_TOKEN")

  # API call
  # TODO: Add exception handling
  # TODO: Handle paginated responses
  gfw_json <- httr::GET(endpoint,
                        config = list(httr::add_headers(Authorization = paste("Bearer", key, sep = " ")))
                      )

  # Make request
  gfw_list <- httr::content(gfw_json)

  # Function to extract each entry to tibble
  event_entry <- function(x){
    tibble::enframe(x) %>%
      tibble::as_tibble() %>%
      tidyr::pivot_wider(names_from = .data$name, values_from = .data$value) %>%
      tidyr::unnest_wider(.data$position)
  }

  # basic function to make length 1 lists into characters
  make_char <- function(col) {
    if(is.list(col) & lengths(col) == 1) {
      as.character(col)
    } else {
      col
    }
  }

  # If we know we will always have start and end as datetime we could also add this
  make_datetime <- function(x) {
    as.POSIXct(as.character(x), format = '%Y-%m-%dT%H:%M:%S', tz = 'UTC')
  }

  # Map function to each event to convert to data frame
  # and format non-list columns to character and datetime
  event_df <- purrr::map_dfr(gfw_list$entries, event_entry) %>%
    dplyr::mutate(dplyr::across(tidyselect::everything(), make_char)) %>%
    dplyr::mutate(dplyr::across(c(.data$start, .data$end), make_datetime))

  # Return final data frame
  return(event_df)
}
