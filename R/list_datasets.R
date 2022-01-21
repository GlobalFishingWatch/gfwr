#'
#' Get the list of available GFW API datasets
#'

list_datasets <- function(api_token){
  endpoint <- "https://gateway.api.dev.globalfishingwatch.org/datasets"
  datasets_json <- httr::GET(endpoint, api_token)
  datasets_list <- httr::content(datasets_json)
  return(datasets_list)
}
