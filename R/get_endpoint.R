#'
#' Function to get API dataset name for given event type
#'
#' @param dataset_type Type of dataset to get API dataset name for. It can be "port_visit", "fishing", "encounter", "loitering", "eez" or "mpa""
#' @param ... Other arguments that would depend on the dataset type.
#' @importFrom httr2 request
#' @importFrom httr2 req_url_path_append
#' @importFrom httr2 req_url_query
#'

get_endpoint <- function(dataset_type,...){

  # API endpoint specific parameters from ...
  args <- list(...)
  for (i in seq_len(length(args))) {
    assign(names(args[i]), args[[i]])
  }

  # API datasets to pass to param list
  api_datasets <- c(
    'port_visit' = "public-global-port-visits-c2-events:latest",
    'encounter' = "public-global-encounters-events:latest",
    'loitering' = "public-global-loitering-events-carriers:latest",
    'fishing' = "public-global-fishing-events:latest",
    'raster' = "public-global-fishing-effort:latest"
  )

  base <- httr2::request("https://gateway.api.globalfishingwatch.org/v3/")

  # Get dataset ID for selected API
  if (!dataset_type %in% c('EEZ', 'MPA', 'RFMO')) {
    dataset <- api_datasets[[dataset_type]]
  }

  # Modify base URL with query parameters
  if (dataset_type %in% c('port_visit','fishing','encounter','loitering')) {

    args <- c(datasets = dataset,  args)
    endpoint <- base %>%
      httr2::req_url_path_append('events') %>%
      httr2::req_url_query(!!!args)

  } else if (dataset_type == 'raster') {

    args <- c(`datasets[0]` = dataset, args)
    endpoint <- base %>%
      httr2::req_url_path_append('4wings/report') %>%
      httr2::req_url_query(!!!args)

  } else if (dataset_type == "EEZ") {

    endpoint <- base %>%
      httr2::req_url_path_append("datasets/public-eez-areas/context-layers")

  } else if (dataset_type == "MPA") {

    endpoint <- base %>%
      httr2::req_url_path_append("datasets/public-mpa-all/context-layers")

  } else if (dataset_type == "RFMO") {

    endpoint <- base %>%
      httr2::req_url_path_append("datasets/public-rfmo/context-layers")

  } else {
    stop("Select valid dataset type")
  }

  return(endpoint)
}


#' Function to get API endpoint name for identity search
#'
#' @param dataset_type Type of identity dataset to get API dataset name for. It can be a vector with any combination of "support_vessel", "carrier_vessel" or "fishing_vessel"
#' @param search_type Type of vessel search to perform. Can be "search" or "id". "advanced" is no longer in use as of gfwr 2.0.0 and basic and advanced options can be accessed with parameters query and where
#' @param ids optional, a vector with vessel ids
#' @param ... Other arguments that would depend on the dataset type.

get_identity_endpoint <- function(dataset_type,
                                  search_type,
                                  ids,
                                  ...) {

 #this is unnecessary if the function is called from within get vessel info
   if (search_type %in% c("advanced", "basic")) {
    # Signal the deprecation to the user
    warning("basic or advanced search are no longer in use as of gfwr 2.0.0. Options are 'search' or 'id'. Use `query` for simple queries and `where` for advanced SQL expressions")
    search_type <- "search"
  }
  # API endpoint specific parameters from ...
  args <- list(...)
  for (i in seq_len(length(args))) {
    assign(names(args[i]), args[[i]])
  }

if (dataset_type == "all") dataset_type <- c("support_vessel", "carrier_vessel", "fishing_vessel")

  base <- httr2::request("https://gateway.api.globalfishingwatch.org/v3/")

  # API datasets to pass to param list
  api_datasets <- c(
    "support_vessel" = "public-global-support-vessels:latest",
    "carrier_vessel" = "public-global-carrier-vessels:latest",
    "fishing_vessel" = "public-global-fishing-vessels:latest"
    )

  # Get dataset ID for selected API
  dataset <- api_datasets[names(api_datasets) %in% dataset_type]
  dataset <- vector_to_array(dataset, type = "dataset")

  # swap name is searching by vessel id
  if (search_type == "id") {
    #names(args)[names(args) == "query"] <- "ids"
    args <- vector_to_array(ids, type = "ids")
    args <- args[!names(args) %in% c('limit','offset')]
    path_append <- "vessels"
  } else if (search_type == "search") {
    path_append <- "vessels/search"
  }
  #where <- vector_to_array(query, type = "where")
    args <- c(dataset,
              #query,
              #where,
              args)

  endpoint <- base %>%
    httr2::req_url_path_append(path_append) %>%
    httr2::req_url_query(!!!args)

  return(endpoint)
}
