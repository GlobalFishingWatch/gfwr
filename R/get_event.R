#'
#' Base function to get event from API and convert response to data frame
#'
#' @param event_type Type of event to get data of. One of "port_visit", "encounter", "loitering, or "fishing"
#' @param vessel VesselID. How to get this?
#' @param include_regions Whether to include regions? Ask engineering if this can always be false
#' @param start_date Start of date range to search events
#' @param end_date End of date range to search events
#' @param confidences Confidence levels (1-4) of events (port visits only).
#' @param key Authorization token. Can be obtained with gfw_auth function
#' @param quiet Boolean. Whether to print the number of events returned by the request.
#' @importFrom dplyr across
#' @importFrom dplyr mutate
#' @importFrom purrr map_chr
#' @importFrom purrr map_dbl
#' @importFrom purrr map
#' @importFrom purrr pluck
#' @importFrom purrr flatten
#' @importFrom rlang .data
#' @importFrom tibble tibble
#'
#' @details
#' There are currently four possible event types to request for a vessel. However, only likely vessels
#' can have fishing events (`event_type = 'fishing'`). An encounter event, which involves multiple vessels, will
#' be returned for each vessel involved in the encounter. For example, an encounter between a carrier vessel
#' and fishing vessel will be represented as two events, one for each vessel. These events will have identical `id`
#' values that are suffixed by a `.` and a number.
#'
#' @export

get_event <- function(event_type='port_visit',
                      vessel = NULL,
                      include_regions = NULL,
                      start_date = NULL,
                      end_date = NULL,
                      confidences = NULL,
                      key = gfw_auth(),
                      quiet = FALSE
                      ){


  # Event datasets to pass to param list
  endpoint <- get_endpoint(event_type,
                           `include-regions` = include_regions,
                           vessels = vessel,
                           `start-date` = start_date,
                           `end-date` = end_date,
                           confidences = confidences,
                           limit = 99999,
                           offset = 0
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
      lat = purrr::map_dbl(all_entries, purrr::pluck, 'position','lat'),
      lon = purrr::map_dbl(all_entries, purrr::pluck, 'position','lon'),
      regions = purrr::map(all_entries, 'regions'),
      boundingBox = purrr::map(all_entries, 'boundingBox'),
      distances = purrr::map(all_entries, 'distances'),
      vessel = purrr::map(all_entries, 'vessel'),
      event_info = purrr::map(all_entries, length(all_entries[[1]])) # the event_info is always the last element
    )

    # Map function to each event to convert to data frame
    event_df <- df_out %>%
      dplyr::mutate(dplyr::across(c(.data$start, .data$end), make_datetime))

    # Print out total events
    total <- nrow(event_df)

    if(quiet == FALSE){
      print(paste("Downloading",total,"events from GFW"))
    }

    } else {

      if(quiet == FALSE){
        print("Your request returned zero results")
      }

      return()
  }

  # Return results
  return(event_df)
}
