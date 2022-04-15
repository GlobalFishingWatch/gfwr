#'
#' Base function to get event from API and convert response to data frame
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

get_event <- function(event_type='port_visit',
                      response_limit = 1000,
                      vessel = NULL,
                      include_regions = NULL,
                      start_date = NULL,
                      end_date = NULL,
                      key
                      ){


  # Event datasets to pass to param list
  endpoint <- get_endpoint(event_type,
                           limit = response_limit,
                           includeRegions = include_regions,
                           vessels = vessel,
                           startDate  = start_date,
                           endDate = end_date)


  # API call
  # TODO: Add exception handling
  # TODO: Handle paginated responses
  gfw_json <- httr::GET(endpoint,
                        config = httr::add_headers(Authorization = paste("Bearer", key, sep = " "))
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

  # Map function to each event to convert to data frame
  # and format non-list columns to character and datetime
  event_df <- purrr::map_dfr(gfw_list$entries, event_entry) %>%
    dplyr::mutate(dplyr::across(tidyselect::everything(), make_char)) %>%
    dplyr::mutate(dplyr::across(c(.data$start, .data$end), make_datetime))

  # Return final data frame
  return(event_df)
}
