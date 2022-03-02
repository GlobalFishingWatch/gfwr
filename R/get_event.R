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
#' @importFrom purrr map_dfr
#' @importFrom rlang .data
#' @importFrom tibble as_tibble
#' @importFrom tibble enframe
#' @importFrom tidyr pivot_wider
#' @importFrom tidyr unnest_wider
#' @importFrom tidyselect everything

get_event <- function(event_type='port_visit',
                      limit = 10,
                      vessel = '6583c51e3-3626-5638-866a-f47c3bc7ef7c',
                      auth){

  # Set endpoint
  # TODO: Use lookup table to select endpoint based on event_type param
  endpoint <- get_endpoint(event_type, limit, vessel=vessel)

  # API call
  # TODO: Add exception handling
  gfw_json <- httr::GET(endpoint, auth)
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
