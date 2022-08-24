#'
#' Base function to get event from API and convert response to data frame
#'
#' @param event_type Type of event to get data of. It can be "port_visit" or "fishing"
#' @param vessel VesselID. How to get this?
#' @param include_regions Whether to include regions? Ask engineering if this can always be false
#' @param start_date Start of date range to search events
#' @param end_date End of date range to search events
#' @param confidences Confidence levels (1-4) of events (port visits only).
#' @param limit Limit of response size for each GFW API call.
#' @param offset Internal parameter to GFW pagination
#' @param key Authorization token. Can be obtained with gfw_auth function
#' @importFrom dplyr across
#' @importFrom dplyr mutate
#' @importFrom httr2 req_perform
#' @importFrom httr2 resp_body_json
#' @importFrom purrr map_dfr
#' @importFrom purrr flatten
#' @importFrom rlang .data
#' @importFrom tibble as_tibble
#' @importFrom progress progress_bar
#' @importFrom tidyselect everything
#'
#' @export

get_event <- function(event_type='port_visit',
                      vessel = NULL,
                      include_regions = NULL,
                      start_date = NULL,
                      end_date = NULL,
                      confidences = NULL,
                      limit = 99999,
                      offset = 0,
                      key = gfw_auth()
                      ){


  # Event datasets to pass to param list
  endpoint <- get_endpoint(event_type,
                           `include-regions` = include_regions,
                           vessels = vessel,
                           `start-date` = start_date,
                           `end-date` = end_date,
                           confidences = confidences,
                           limit = limit,
                           offset = offset
                           )

  # API call; will paginate if neccessary, otherwise return list with one response
  all_results <- paginate(endpoint, key)

  # Extract all entries from list of responses
  all_entries <- purrr::map(all_results, purrr::pluck, 'entries') %>% purrr::flatten(.)

  # Process results if they exist
  if(length(all_entries) > 0){

    # Convert list to dataframe
    df_out <- tibble::tibble(
      id = purrr::map_chr(all_entries, 'id'),
      type = purrr::map_chr(all_entries, 'type'),
      start = purrr::map_chr(all_entries, 'start'),
      end = purrr::map_chr(all_entries, 'end'),
      lat = purrr::map_dbl(purrr::map(all_entries, 'position'), 'lat'),
      lon = purrr::map_dbl(purrr::map(all_entries, 'position'), 'lon'),
      regions = purrr::map(all_entries, 'regions'),
      boundingBox = purrr::map(all_entries, 'boundingBox'),
      distances = purrr::map(all_entries, 'distances'),
      vessel = purrr::map(all_entries, 'vessel'),
      event_info = purrr::map(all_entries, length(all_entries[[1]])) # the event_info is always the last element
    )

    # Map function to each event to convert to data frame
    event_df <- df_out %>%
      dplyr::mutate(dplyr::across(c(.data$start, .data$end), make_datetime))

    } else {
    # Create empty dataframe to return when zero entries.
    event_df <- tibble::tibble(
      id = NA_character_,
      type = NA_character_,
      start = NA,
      end = NA,
      lat = NA_real_,
      lon = NA_real_,
      regions = NA,
      boundingBox = NA,
      distances = NA,
      vessel = NA,
      event_info = NA
    )
  }

  # Return results
  return(event_df)
}
