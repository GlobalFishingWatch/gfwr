#'
#' Function to get API dataset name for given event type
#'
#' @param event_type Type of dataset to get API dataset name for. It can be "port_visit" or "fishing"

get_endpoint <- function(dataset_type,...){

  # API endpoint specific parameters from ...
  args <- list(...)
  for (i in seq_len(length(args))) {
    assign(names(args[i]), args[[i]])
  }

  # API datasets to pass to param list
  api_datasets <- c(
    'port_visit' = "public-global-port-visits-c2-events:v20201001",
    'fishing' = "public-global-fishing-events:v20201001"
  )

  # Get dataset ID for selected API
  dataset <- api_datasets[[dataset_type]]

  # Add datasets ID to params list
  args <- c(datasets = dataset, args)

  # Modify base URL with query parameters
  # TODO: The "/events" will have to change if querying vessels/4Wings etc.
  endpoint <- httr::modify_url("https://gateway.api.globalfishingwatch.org/v1/events",
                               query = args)

  return(endpoint)
}
