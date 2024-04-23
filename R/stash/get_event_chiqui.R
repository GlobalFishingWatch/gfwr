#'
#' Base function to get event from API and convert response to data frame
#'
#' @param event_type Type of event to get data of. One of "ENCOUNTER",  "FISHING",
#' "LOITERING", "GAP", "GAP_START", "PORT_VISIT"
#' @param encounter_types "CARRIER-FISHING", "FISHING-CARRIER", "FISHING-SUPPORT",
#' "SUPPORT-FISHING"
#' @param vessels A vector of VesselIDs, obtained via the get_vessel_info() function.
#' @param vessel_types A vector of vessel types, any combinatino of: "FISHING",
#' "CARRIER", "SUPPORT", "PASSENGER", "OTHER_NON_FISHING", "SEISMIC_VESSEL",
#'"BUNKER_OR_TANKER", "CARGO"
#'@param timeseriesInterval (body)
#' @param include_regions Whether to include regions? Ask engineering if this can always be false
#' @param start_date Start of date range to search events
#' @param end_date End of date range to search events
#' @param confidences Confidence levels (1-4) of events (port visits only).
#' @param key Authorization token. Can be obtained with gfw_auth() function
#' @param quiet Boolean. Whether to print the number of events returned by the request
#'
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
#' There are currently four available event types and these events are provided for three
#' vessel types - fishing, carrier, and support vessels.
#' Fishing events (`event_type = "FISHING"`) are specific to fishing vessels and loitering
#' events (`event_type = "LOITERING"`) are specific to carrier vessels. Port visits
#' (`event_type = "PORT_VISIT"`) and encounters (`event_type = "ENCOUNTER"`) are available
#' for all vessel types. For more details about the various event types, see the [GFW API documentation](https://globalfishingwatch.org/our-apis/documentation#data-caveat).
#'
#' Encounter events involve multiple vessels and one row is returned for each
#' vessel involved in an encounter.
#' For example, an encounter between a carrier and fishing vessel
#' (`CARRIER-FISHING`) will have one row for the fishing vessel and one for the
#' carrier vessel. The `id` field for encounter events has two components
#' separated by a `.`. The first component is the unique id for the encounter
#' event and will be the same for all vessels involved in the encounter. The
#' second component is an integer used to distinguish between different vessels
#' in the encounter.
#'
#' @export

get_event <- function(event_type = 'PORT_VISIT',
                      vessels = NULL,
                      include_regions = NULL,
                      start_date = NULL,
                      end_date = NULL,
                      confidences = NULL,
                      key = gfw_auth(),
                      quiet = FALSE
                      ) {
  #datasets array
  if (!is.null(event_type)) {
    types <- vector_to_array(event_type, type = "types")
  }
  if (!is.null(vessels)) {
  vessels <- vector_to_array(vessels, type = "vessels")
}
  # Event datasets to pass to param list
  endpoint <- get_endpoint(event_type,
                           `include-regions` = include_regions,
                           #`vessels[0]` = vessel,#add vessels here
                           `start-date` = start_date,
                           `end-date` = end_date,
                           `confidences[0]` = confidences,
                           limit = 99999,
                           offset = 0
                           )

  # API call; will paginate if neccessary, otherwise return list with one response
  all_results <- gfw_api_request(endpoint, key)

  # Extract all entries from list of responses
  all_entries <- purrr::map(all_results, purrr::pluck, 'entries') %>% purrr::flatten(.)

  # Process results if they exist
  if (length(all_entries) > 0) {

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
    if (quiet == FALSE){
      print(paste("Downloading", total, "events from GFW"))
    }
    } else {
      if (quiet == FALSE) {
        print("Your request returned zero results")
      }
      return()
  }

  # Return results
  return(event_df)
}
