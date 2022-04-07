#'
#' Function to get endpoint for given event type
#'
#' @param event_type Type of event to get data of. It can be "port_visit" or "fishing"

get_endpoint <- function(event_type){

  # Event datasets to pass to param list
  event_datasets <- c(
    'port_visit' = "public-global-port-visits-c2-events:v20201001",
    'fishing' = "public-global-fishing-events:v20201001"
  )

  # Get dataset for selected event
  event_dataset <- event_datasets[event_type]

  return(event_dataset)
}
