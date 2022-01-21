#'
#' Get vessel track
#'

get_vessel_track <- function(auth){

  # API endpoint
  endpoint <- glue::glue("https://gateway.api.globalfishingwatch.org//v1/",
                         "vessels/8c7304226-6c71-edbe-0b63-c246734b3c01/tracks",
                         "?datasets=public-global-carriers-tracks:v20201001",
                         "&distanceFishing=500&bearingValFishing=1&format=lines&wrapLongitudes=false&binary=false&changeSpeedFishing=200&fields=lonlat,timestamp,speed")

  # API request
  #TODO: add exception handling for API request
  gfw_json <- httr::GET(endpoint, auth)

  # Extract content of request to list
  gfw_list <- httr::content(gfw_json)

  #TODO: convert list object to tibble
  #TODO: determine set of column names
  # ... return list containing 2) version/API response info and 2) tibble with data
  return(gfw_list)
}
