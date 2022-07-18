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
#' @importFrom progress progress_bar
#' @importFrom tidyselect everything
#'
#' @export

get_event <- function(event_type='port_visit',
                      vessel = NULL,
                      include_regions = NULL,
                      start_date = NULL,
                      end_date = NULL,
                      limit = 10000,
                      offset = 0,
                      key = gfw_auth()
                      ){


  # Event datasets to pass to param list
  endpoint <- get_endpoint(event_type,
                           `include-regions` = include_regions,
                           vessels = vessel,
                           `start-date` = start_date,
                           `end-date` = end_date,
                           limit = limit,
                           offset = offset
                           )

  # API call; will paginate if neccessary, otherwise return list with one response
  all_results <- paginate(endpoint, key)

  # Extract all entries from list of responses
  all_entries <- purrr::map(all_results, purrr::pluck, 'entries') %>% purrr::flatten(.)

  # Create progress bar
  pb <- progress::progress_bar$new(
    format = "Processing events: [:bar] :current/:total (:percent)",
    total = length(all_entries)
    )

  # Function to extract each entry to tibble
  event_entry <- function(x){
    df_out <- tibble::tibble(
      id = x$id,
      type = x$type,
      start = x$start,
      end = x$end,
      lat = x$position$lat,
      lon = x$position$lon,
      regions = list(x$regions),
      boundingBox = list(x$boundingBox),
      distances = list(x$distances),
      vessel = list(x$vessel),
      event_info = list(x[length(x)])
    )
    # Iterate progress bar
    pb$tick()
    Sys.sleep(0.01)
    # return data
    return(df_out)
  }

  # Map function to each event to convert to data frame
  event_df <- purrr::map_dfr(all_entries, event_entry) %>%
    dplyr::mutate(dplyr::across(c(.data$start, .data$end), make_datetime))

  # Return final data frame
  return(event_df)
}
