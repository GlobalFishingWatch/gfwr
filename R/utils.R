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
