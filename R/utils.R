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

#' Get the Global Fishing Watch API base URL
#'
#' Returns the `GFW_BASE_URL` environment variable if it is set and not empty
#' (ignoring leading/trailing whitespace). Otherwise, returns the default
#' production API base URL: `"https://gateway.api.globalfishingwatch.org/v3/"`.
#'
#' @name gfw_base_url
#' @export
gfw_base_url <- function() {
  url <- Sys.getenv("GFW_BASE_URL", unset = "")
  url <- trimws(url)

  if (identical(url, "") || is.na(url)) {
    url <- "https://gateway.api.globalfishingwatch.org/v3/"
  }

  return(url) # nolint: return_linter.
}

#'
#' Get user API token from .Renviron
#' @name gfw_auth
#' @export
gfw_auth <- function() {
  # Define authorization token
  key <- Sys.getenv("GFW_TOKEN")
  return(key)
}

#' Set user agent for gfwr API requests
#' @name gfw_user_agent
#' @export
#' @keywords internal
gfw_user_agent <- function() {
  # Define user agent version
  return("gfwr/3.0.0 (https://github.com/GlobalFishingWatch/gfwr)")
}

#' Basic function to make length 1 lists into characters
#' @name make_char
#' @keywords internal
make_char <- function(col) {
  ifelse(is.list(col) & lengths(col) == 1, as.character(col), col)
}

#' Helper function to convert datetime responses
#' @name make_datetime
#' @keywords internal
make_datetime <- function(x) {
  as.POSIXct(as.character(x), format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")
}

#' Parse a GFW API error response into a structured, user-friendly format
#'
#' This function extracts detailed, structured error information from an
#' `httr2` response object. It supports:
#' - JSON error bodies that follow the GFW API error schema
#' - HTML error bodies (e.g., "413 Request Entity Too Large")
#'
#' @details Taken from httr2 docs: https://httr2.r-lib.org/articles/wrapping-apis.html
#'
#' @param resp An `httr2` response object.
#'
#' @return A list with:
#'   - `status_code` – character string API/HTTP status code
#'   - `error`        – error name/description
#'   - `messages`     – list of `{title, detail}` entries
#'   - `formatted`    – pretty multi-line summary
#'
#' @examples
#' \dontrun{
#' req <- httr2::request("https://gateway.api.globalfishingwatch.org/v3/4wings/report") |>
#'   httr2::req_headers(Authorization = paste("Bearer", "...")) |>
#'   httr2::req_error(body = \(resp) parse_response_error(resp)$formatted)
#'
#' resp <- req |> httr2::req_perform()
#' }
#'
#' @keywords internal
#' @export
parse_response_error <- function(resp) {
  status_code <- httr2::resp_status(resp)
  error <- httr2::resp_status_desc(resp)
  messages <- list()

  resp_content_type <- httr2::resp_content_type(resp)
  zwsp <- "\u200B" # zero-width space for formatting

  # Handle transaction-id (unique request id)
  transaction_id <- trimws(httr2::resp_header(resp, "transaction-id", default = ""))
  if (is.na(transaction_id) || !nzchar(transaction_id)) {
    transaction_id <- "unknown"
  }

  # Handle JSON error response bodies
  is_json <- grepl("json", resp_content_type, ignore.case = TRUE)
  if (is_json) {
    resp_body_json <- tryCatch(
      httr2::resp_body_json(resp, check_type = FALSE),
      error = function(e) NULL
    )

    if (is.list(resp_body_json)) {
      status_code <- resp_body_json$statusCode %||% status_code
      error <- resp_body_json$error %||% error
      messages <- resp_body_json$messages %||% resp_body_json$message %||% list()
      messages <- purrr::map(messages, function(message) {
        if (is.list(message)) { # Handle list message with title and detail
          message
        } else { # Handle character vector message
          list(
            title  = "Unknown",
            detail = message
          )
        }
      })
    }
  }

  # Handle HTML error response bodies
  resp_body_string <- tryCatch(
    httr2::resp_body_string(resp, encoding = "UTF-8"),
    error = function(e) ""
  )

  # Handle HTML error response bodies
  is_html <- grepl("<(html|body|title|h1|h2)", resp_body_string, ignore.case = TRUE)
  if (is_html) {
    html_error <- NULL
    html_title <- NULL
    html_detail <- NULL
    try(
      {
        resp_body_html <- xml2::read_html(resp_body_string)
        html_error <- xml2::xml_text(xml2::xml_find_first(resp_body_html, "//title"))
        html_title <- xml2::xml_text(xml2::xml_find_first(resp_body_html, "//h1"))
        html_detail <- xml2::xml_text(xml2::xml_find_first(resp_body_html, "//h2"))
      },
      silent = TRUE
    )
    html_error <- html_error %||% html_title %||% error
    html_error_parts <- unlist(strsplit(html_error, " ", fixed = TRUE))

    status_code <- if (grepl("^\\d+$", html_error_parts[1])) html_error_parts[1] else status_code
    error <- paste(html_error_parts[-1], collapse = " ")

    messages <- list(
      list(
        title = html_title %||% error,
        detail = html_detail %||% html_title %||% html_error
      )
    )
  }

  # Normalize error status code and description
  status_code <- as.character(status_code)
  error <- as.character(error)

  # Normalize error response messages into list of lists with title and detail
  messages <- messages %||% list()
  messages <- purrr::map(messages, function(message) {
    list(
      title = as.character(message$title %||% NA_character_),
      detail = as.character(message$detail %||% NA_character_)
    )
  })

  # Format error response
  formatted <- glue::glue("GFW API error ({status_code}): {error}")
  formatted <- c(
    formatted,
    glue::glue("{zwsp}{zwsp}Transaction ID: {transaction_id}")
  )
  if (length(messages) > 0) {
    bullets <- purrr::map_chr(messages, function(message) {
      glue::glue("{zwsp}{zwsp}{zwsp}{zwsp}- {message$title}: {message$detail}")
    })

    formatted <- c(
      formatted,
      glue::glue("{zwsp}{zwsp}Errors:"),
      bullets
    )
  }

  # Return structured error object
  gfw_api_error <- list(
    transaction_id = transaction_id,
    status_code = status_code,
    error = error,
    messages = messages,
    formatted = formatted
  )

  return(gfw_api_error) # nolint: return_linter.
}

#' General function for GFW API requests, including handling of pagination.
#' @name gfw_api_request
#' @param endpoint the endpoint to make the request
#' @param key Authentication key
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_error
#' @importFrom httr2 req_perform
#' @importFrom httr2 resp_body_json
#' @importFrom httr2 req_user_agent
#' @keywords internal
# API request function
gfw_api_request <- function(endpoint, key) {
  # Make initial API request
  response <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer",
                                             key,
                                             sep = " "),
                       `Content-Type` = "application/json") %>%
    httr2::req_user_agent(gfw_user_agent()) %>%
    #httr2::req_error(body = parse_response_error) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json()

  # List to store responses
  responses <- list()
  responses[[1]] <- response

  # Current page values
  total <- response$total
  # print(paste("Downloading",total,"events from GFW"))

  # next_off <- ifelse(is.null(response$nextOffset), 0, response$nextOffset)
  next_off <- response$nextOffset

  # While nextOffset is less than total, pull additional response pages
  # if(next_off < total){
    while (!is.null(next_off)) {

      # # API call for next page
      next_response <- endpoint %>%
        httr2::req_url_query(offset = next_off) %>%
        httr2::req_headers(Authorization = paste("Bearer",
                                                 key,
                                                 sep = " "),
                           `Content-Type` = "application/json") %>%
        httr2::req_user_agent(gfw_user_agent()) %>%
        #httr2::req_error(body = parse_response_error) %>%
        httr2::req_perform() %>%
        httr2::resp_body_json()

      # Append response to list
      responses[[length(responses) + 1]] <- next_response

      # Pull out nextOffset of latest API response
      next_off <- response$nextOffset
      # next_off <- ifelse(is.null(response$nextOffset), total, response$nextOffset)
    # }
  }
  # Return list of response pages
  return(responses)
}


#' Transforms a vector to a named vector for httr2
#'
#' @param x The vector to transform
#' @param type The type of data to paste, will be "events", "datasets", or "vessel" depending on the context
#' @return A named vector in the format required by the API, with names followed
#' by a zero-indexed suffix (ex. datasets\\[0\\])
#' @keywords internal
#' @export
#' @examples
#' vector_to_array(x = 1, type = "vessel")
#' vector_to_array(x = "a", type = "vessel")
#' vector_to_array(x = c(1, 2), type = "dataset")
#' vector_to_array(x = c(1, 2, 3), type = "dataset")
#' vector_to_array(x = "fishing", type = "dataset")
#' vector_to_array(x = c("fishing", "port-visits"), type = "event")

vector_to_array <- function(x, type = "vessel") {
  index <- seq_along(1:length(x)) - 1
  array_name <- paste0(type, "[", index, "]")
  names(x) <- array_name
  return(x)
}

#' Formats an sf shapefile to a formatted geojson
#'
#' @param sf_shape The sf shapefile to transform
#' @param endpoint The GFW endpoint destination for the geojson ("raster" or "event")
#' @returns A correctly-formatted geojson to be used in [gfw_ais_fishing_hours()] or [gfw_event()]
#' @importFrom geojsonsf sf_geojson
#' @keywords internal

sf_to_geojson <- function(sf_shape, endpoint = "raster") {
  geoj <- geojsonsf::sf_geojson(sf_shape)
  if (endpoint == "raster") {
    geoj_tagged <- paste0('{"geojson":', geoj,'}')
  } else if (endpoint == "event") {
    geoj_tagged <- paste0('"geometry":', geoj)
  } else {
    stop('Incorrect endpoint argument')
  }
  return(geoj_tagged)
}


utils::globalVariables(c("."))
utils::globalVariables(c("<list>"))
utils::globalVariables(c("data"))
utils::globalVariables(c("geartypes"))
utils::globalVariables(c("gfw_marine_regions"))
utils::globalVariables(c("id"))
utils::globalVariables(c("includes"))
utils::globalVariables(c("index"))
utils::globalVariables(c("iso"))
utils::globalVariables(c("matches"))
utils::globalVariables(c("MRGID"))
utils::globalVariables(c("name"))
utils::globalVariables(c("shiptypes"))
utils::globalVariables(c("sourceCode"))
utils::globalVariables(c("value"))
utils::globalVariables(c("vessel"))
utils::globalVariables(c("vessel_id"))
utils::globalVariables(c("registries_info_data"))
