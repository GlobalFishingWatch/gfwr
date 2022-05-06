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
  if(is.list(col) & lengths(col) == 1) {
    as.character(col)
  } else {
    col
  }
}

#' Helper function to convert datetime responses
#' @name make_datetime
#' @keywords internal
#' @export
#' @return
make_datetime <- function(x) {
  as.POSIXct(as.character(x), format = '%Y-%m-%dT%H:%M:%S', tz = 'UTC')
}

#' Pagination function for GFW API calls
#' @name paginate
#' @keywords internal
#' @export
#' @return
# pagination function
paginate <- function(response, endpoint, key){

  # List to store responses
  responses <- list()
  responses[[1]] <- response
  # Current page values
  total <- response$total
  next_off <- response$nextOffset

  # While nextOffset is less than total, pull additional response pages
  while(next_off < total){

    # Event datasets to pass to param list
    next_endpoint <- httr::modify_url(endpoint, query = list(offset = next_off))
    # API call for next page
    next_response <- httr::GET(next_endpoint,
                               config = httr::add_headers(Authorization = paste("Bearer", key, sep = " "))) %>%
      httr::content()

    # Append response to list
    responses[[length(responses)+1]] <- next_response

    # Pull out nextOffset of latest API response
    next_off <- next_response$nextOffset
  }
  # Return list of response pages
  return(responses)
}
