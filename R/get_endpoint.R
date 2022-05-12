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

  base <- httr2::request("https://gateway.api.dev.globalfishingwatch.org/v2/")

  # Get dataset ID for selected API
  dataset <- api_datasets[[dataset_type]]

  # Modify base URL with query parameters
  # TODO: The "/events" will have to change if querying vessels/4Wings etc.

  if (dataset_type %in% c('port_visits','fishing')) {

    args <- c(datasets = dataset,  args)
    endpoint <- base %>%
      httr2::req_url_path_append('events') %>%
      httr2::req_url_query(!!!args)

  } else if (dataset_type == 'raster') {
    date_range <- paste0(start_date, ',', end_date)
    args <- c(`datasets[0]` = dataset,`date-range` = date_range,  args)
    endpoint <- base %>%
      httr2::req_url_path_append('4wings/report') %>%
      httr2::req_url_query(!!!args)
  } else {
    stop('Select valid dataset type')
  }

  return(endpoint)
}
