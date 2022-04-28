#'
#' Function to get API dataset name for given event type
#'
#' @param dataset_type Type of dataset to get API dataset name for. It can be "port_visit" or "fishing"
#' @param ... Other arguments that would depend on the dataset type.

get_endpoint <- function(dataset_type,...){

  # API endpoint specific parameters from ...
  args <- list(...)
  for (i in seq_len(length(args))) {
    assign(names(args[i]), args[[i]])
  }

  # API datasets to pass to param list
  api_datasets <- c(
    'port_visit' = "public-global-port-visits-c2-events:v20201001",
    'fishing' = "public-global-fishing-events:v20201001",
    'raster' = "public-global-fishing-effort:v20201001"
  )

  # Get dataset ID for selected API
  dataset <- api_datasets[[dataset_type]]

  # Add datasets ID to params list
  args <- c(datasets = dataset, args)

  # Modify base URL with query parameters
  # TODO: The "/events" will have to change if querying vessels/4Wings etc.

  if (dataset_type %in% c('port_visits','fishing')) {
    base <- "https://gateway.api.globalfishingwatch.org/v1/events"
  } else {
    base <- "https://gateway.api.globalfishingwatch.org/v1/4wings/report"
  }

  endpoint <- httr::modify_url(base,
                               query = args)

  return(endpoint)
}
