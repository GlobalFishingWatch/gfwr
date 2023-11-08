#' Base function to get vessel insights from API and convert response to data frame
#'
#' @param includes COVERAGE, FISHING, GAP
#' @param startDate Character string with start date "YYYY-MM-DD"
#' @param endDate Character string with end date "YYYY-MM-DD"
#' @param vessels Vector of vessel ids
#' @param confidences description
#' @param key Authorization token. Can be obtained with `gfw_auth()` function
#' @param ... Other arguments

#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 req_user_agent
#' @importFrom httr2 req_error
#' @importFrom httr2 req_body_json
#' @importFrom httr2 resp_body_json
#' @importFrom jsonlite unbox
#' @importFrom tidyr unnest_wider
#' @importFrom tibble enframe
#'
#' @examples
#' library(gfwr)
#' # Gap
#' # Coverage
#' # Fishing events
#' # All

#' @export
get_insights <- function(includes = "GAP",
                         startDate = NULL,
                         endDate = NULL,
                         vessels = NULL,
                         confidences = NULL,
                         key = gfw_auth(),
                            ...) {
  # gets endpoint here ---------

  # API endpoint specific parameters from ...
  #args <- list(...)
  #for (i in seq_len(length(args))) {
  #  assign(names(args[i]), args[[i]])
  #}
endpoint <- "https://gateway.api.globalfishingwatch.org/v3/insights/vessels"
  base <- httr2::request(endpoint)

  # Get dataset ID for selected API
  dataset <- "public-global-vessel-identity:latest"


request <- base %>%
    httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
    #httr2::req_headers(`Content-Type` = "application/json") %>%
    httr2::req_headers(Origin = "https://globalfishingwatch.org",
                       Referer = "https://globalfishingwatch.org") %>%
    #httr2::req_error(., body = gist_error_body) %>%
    httr2::req_user_agent(gfw_user_agent()) %>%
    httr2::req_body_json(list(includes = includes,
                              startDate = jsonlite::unbox(startDate),
                              endDate = jsonlite::unbox(endDate),
                              vessels = data.frame(datasetId = dataset,
                                                   vesselId = vessels)))

response <- httr2::req_perform(request)
    #httr2::resp_body_json()

  #output <- response
  #tibble::enframe(response$entries) %>%
    #tidyr::unnest_wider(data = ., col = value)

  return(response)
}
