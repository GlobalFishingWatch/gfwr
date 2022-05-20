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



#'
#' Function to get API dataset name for given event type
#'
#' @param dataset_type Type of identity dataset to get API dataset name for. It can be "support_vessel", "carrier_vessel" or "fishing_vessel"
#' @param search_type Type of vessel search to perform. Can be "basic", "advanced", or "id"
#' @param ... Other arguments that would depend on the dataset type.

get_identity_endpoint <- function(dataset_type, search_type, ...) {

  # API endpoint specific parameters from ...
  args <- list(...)
  for (i in seq_len(length(args))) {
    assign(names(args[i]), args[[i]])
  }

  base <- httr2::request("https://gateway.api.dev.globalfishingwatch.org/v2/")

  # API datasets to pass to param list
  api_datasets <- c(
    "support_vessel" = "public-global-support-vessels:latest",
    "carrier_vessel" = "public-global-carrier-vessels:latest",
    "fishing_vessel" = "public-global-fishing-vessels:latest",
    "all" = "public-global-support-vessels:latest,public-global-carrier-vessels:latest,public-global-fishing-vessels:latest"
  )

  # Get dataset ID for selected API
  dataset <- api_datasets[[dataset_type]]

  # swap name is searching by vessel id
  if (search_type == 'id') {
    names(args)[names(args) == "query"] <- "ids"
  }

  # different search options
  # basic = using MMSI, IMO, shipname, etc
  # advanced = %LIKE%
  # id = using vessel id
  if (search_type == 'basic') {
    path_append = 'vessels/search'
  } else if (search_type == 'advanced') {
    path_append = 'vessels/advanced-search'
  } else if (search_type == 'id') {
    path_append = 'vessels'
  } else {
    cat('Specify appropriate search format')
  }
  args <- c(datasets = dataset, args)

  endpoint <- base %>%
    httr2::req_url_path_append(path_append) %>%
    httr2::req_url_query(!!!args)

  return(endpoint)
}

