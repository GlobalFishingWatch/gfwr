#'
#' Base function to get event from API and convert response to data frame
#'
#' @param event_type Type of event to get data of. It can be "port_visit" or "fishing"
#' @param vessel VesselID. How to get this?
#' @param include_regions Whether to include regions? Ask engineering if this can always be false
#' @param start_date Start of date range to search events
#' @param end_date End of date range to search events
#' @param key Authorization token. Can be obtained with gfw_auth function
#' @importFrom dplyr across
#' @importFrom dplyr mutate
#' @importFrom httr2 req_perform
#' @importFrom httr2 resp_body_json
#' @importFrom purrr map_dfr
#' @importFrom purrr flatten
#' @importFrom rlang .data
#' @importFrom tibble as_tibble
#' @importFrom tibble enframe
#' @importFrom tidyr pivot_wider
#' @importFrom tidyr unnest_wider
#' @importFrom tidyselect everything
#'
#' @export

get_event <- function(event_type='port_visit',
                      vessel = NULL,
                      include_regions = NULL,
                      start_date = NULL,
                      end_date = NULL,
                      key = gfw_auth()
                      ){


  # Event datasets to pass to param list
  endpoint <- get_endpoint(event_type,
                           `include-regions` = include_regions,
                           vessels = vessel,
                           `start-date` = start_date,
                           `end-date` = end_date
                           )

  # API call; will paginate if neccessary, otherwise return list with one response
  all_results <- paginate(endpoint, key)

  # Extract all entries from list of responses
  all_entries <- purrr::map(all_results, purrr::pluck, 'entries') %>% purrr::flatten(.)

  # Function to extract each entry to tibble
  event_entry <- function(x){
    tibble::enframe(x) %>%
      tibble::as_tibble() %>%
      tidyr::pivot_wider(names_from = .data$name, values_from = .data$value) %>%
      tidyr::unnest_wider(col = .data$position)
  }

  # Map function to each event to convert to data frame
  # and format non-list columns to character and datetime
  event_df <- purrr::map_dfr(all_entries, event_entry) %>%
    dplyr::mutate(dplyr::across(tidyselect::everything(), make_char)) %>%
    dplyr::mutate(dplyr::across(c(.data$start, .data$end), make_datetime))

  # Return final data frame
  return(event_df)
}
