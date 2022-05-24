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
#' @export
#' @return
make_char <- function(col) {
  ifelse(is.list(col) & lengths(col) == 1, as.character(col), col)
}

#' Helper function to convert datetime responses
#' @name make_datetime
#' @keywords internal
#' @export
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
#' @export
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
#' @export
#' @return
# pagination function
paginate <- function(endpoint, key){

  # Make initial API request
  response <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer",
                                             key,
                                             sep = " "),
                       `Content-Type` = 'application/json') %>%
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
