#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL

#'
#' Get user API token from .Renviron
#' @name gfw_auth
#' @export
gfw_auth <- function(){
  # Define authorization token
  key <- Sys.getenv("GFW_TOKEN")
  return(key)
}

#' Basic function to make length 1 lists into characters
#' @name make_char
#' @keywords internal
#' @return
make_char <- function(col) {
  ifelse(is.list(col) & lengths(col) == 1, as.character(col), col)
}

#' Helper function to convert datetime responses
#' @name make_datetime
#' @keywords internal
#' @return
make_datetime <- function(x) {
  as.POSIXct(as.character(x), format = '%Y-%m-%dT%H:%M:%S', tz = 'UTC')
}

#' Helper function to parse error message data
#' and display appropriately to user
#' Taken from httr2 docs: https://httr2.r-lib.org/articles/wrapping-apis.html#sending-data
#' @name gist_error_body
#' @keywords internal
#' @importFrom httr2 resp_body_json
#' @importFrom purrr map_chr
#' @importFrom purrr pluck
#' @return
gist_error_body <- function(resp) {
  body <- httr2::resp_body_json(resp)
  message <- body$message
  if(length(message) > 1){
    message <- purrr::map_chr(message, purrr::pluck, 'detail')
  }
  message
}

#' Pagination function for GFW API calls
#' @name paginate
#' @keywords internal
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_error
#' @importFrom httr2 req_perform
#' @importFrom httr2 resp_body_json
#' @return
# pagination function
paginate <- function(endpoint, key){

  # Make initial API request
  response <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer",
                                             key,
                                             sep = " "),
                       `Content-Type` = 'application/json') %>%
    req_user_agent("gfwr/0.0.1 (https://github.com/GlobalFishingWatch/gfwr)") %>%
    httr2::req_error(body = gist_error_body) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json()

  # List to store responses
  responses <- list()
  responses[[1]] <- response

  # Current page values
  total <- response$total
  next_off <- response$nextOffset

  # While nextOffset is less than total, pull additional response pages
  if(!is.null(next_off)){
    while(next_off < total){

      # # API call for next page
      next_response <- endpoint %>%
        httr2::req_url_query(offset = next_off)

      # Append response to list
      responses[[length(responses)+1]] <- next_response

      # Pull out nextOffset of latest API response
      next_off <- next_response$nextOffset
    }
  }
  # Return list of response pages
  return(responses)
}


#' Function to pull numeric EEZ code using EEZ name
#' @name get_region_id
#' @param region_name string, EEZ/MPA name
#' @param region_source string, source of region data ('eez' or 'mpa')
#' @param key string, API token
#' @export
#' @return dataframe, eez code and EEZ name for matching EEZs
#'
#' @importFrom dplyr filter
#' @importFrom dplyr bind_rows
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 resp_body_json
#'

get_region_id <- function(region_name, region_source = 'eez', key) {

  result <- get_endpoint(dataset_type = region_source) %>%
    httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_json(.) %>%
    dplyr::bind_rows()

  if (region_source == 'eez') {
    result %>%
      dplyr::filter(agrepl(region_name, .$label) | agrepl(paste0('^',region_name), .$iso3)) %>%
      dplyr::mutate(id = as.numeric(id))
  } else if (region_source == 'mpa') {
    result %>%
      dplyr::filter(agrepl(region_name, .$label)) %>%
      dplyr::mutate(id = as.numeric(id))
  } else {
    stop('Enter a valid region source')
  }
}
