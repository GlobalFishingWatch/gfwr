#'
#' Function to get API dataset name for given event type
#'
#' @param dataset_type Type of dataset to get API dataset name for. It can be "raster",
#'   "ENCOUNTER", "LOITERING", "FISHING", "PORT_VISIT", "GAP", "EEZ", "RFMO" or "MPA"
#' @param ... Other arguments that would depend on the dataset type.
#' @importFrom httr2 request
#' @importFrom httr2 req_url_path_append
#' @importFrom httr2 req_url_query
#' @keywords internal

gfw_endpoint <- function(dataset_type,
                         ...) {


  # API endpoint specific parameters from ...
  args <- list(...)
  for (i in seq_len(length(args))) {
    assign(names(args[i]), args[[i]])
  }


  #vessels array
  if (exists("vessels") && !is.null(vessels)) {
  vessels <- vector_to_array(vessels, type = "vessels")
  args <- c(args, vessels)
  }
  if (exists("confidences") && !is.null(confidences)) {
    confidences <- vector_to_array(confidences, type = "confidences")
    args <- c(args, confidences)
  }


  # API datasets to pass to param list
  api_datasets <- c(
    'PORT_VISIT' = "public-global-port-visits-c2-events:latest",
    'ENCOUNTER' = "public-global-encounters-events:latest",
    'LOITERING' = "public-global-loitering-events:latest",
    'FISHING' = "public-global-fishing-events:latest",
    'GAP' = "public-global-gaps-events:latest",
    'raster' = "public-global-fishing-effort:latest",
    'raster-pres' = "public-global-presence:latest", ## New
    'sar-presence' = "public-global-sar-presence:latest",
    'sar-infra' = "public-fixed-infrastructure-filtered:latest"
  )

  base <- httr2::request("https://gateway.api.globalfishingwatch.org/v3/")
  # Get dataset ID for selected API
  if (!dataset_type %in% c('EEZ', 'MPA', 'RFMO')) {
    dataset <- api_datasets[[dataset_type]]
  }


  # Modify base URL with query parameters
  if (dataset_type %in% c("PORT_VISIT", 'FISHING', 'ENCOUNTER','LOITERING', "GAP")) {
    #datasets array
    dataset <- vector_to_array(dataset, type = "datasets")
    args <- c(dataset,  args)
    endpoint <- base %>%
      httr2::req_url_path_append('events') %>%
      httr2::req_url_query(!!!args)

  } else if (dataset_type %in% c('raster', 'raster-pres', 'sar-presence')) {

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
#' @keywords internal
#' @param ... Other arguments that would depend on the dataset type.

gfw_identity_endpoint <- function(dataset_type,
                                  search_type,
                                  ids,
                                  ...) {

  # API endpoint specific parameters from ...
  args <- list(...)
  for (i in seq_len(length(args))) {
    assign(names(args[i]), args[[i]])
  }

  base <- httr2::request("https://gateway.api.globalfishingwatch.org/v3/")

  # Only one dataset ID for selected API
  dataset <- "public-global-vessel-identity:latest"
  dataset <- vector_to_array(dataset, type = "datasets")
  args <- c(args, dataset)

  # ID search now receives a vector
  if (search_type == "id") {
    ids <- vector_to_array(ids, type = "ids")

    path_append <- "vessels"
    if (!is.null(registries_info_data)) {
      reg_info <- c(`registries-info-data` = registries_info_data)
      args <- c(args, reg_info)
    }
    args <- c(args,
              ids)
    args <- args[!names(args) %in% c('limit','offset')]
  } else if (search_type == "search") {
    path_append <- "vessels/search"
    #format includes
    if (!is.null(includes)) {
      incl <- vector_to_array(includes, type = "includes")
      args <- c(args, incl)
    }
  }
  endpoint <- base %>%
    httr2::req_url_path_append(path_append) %>%
    httr2::req_url_query(!!!args)

  return(endpoint)
}
