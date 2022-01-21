#'
#' Authenticate to GFW API
#'

gfw_auth <- function(){
  # Define authorization token
  auth <- httr::authenticate(Sys.getenv("GFW_TOKEN"), "")
  return(auth)
}
