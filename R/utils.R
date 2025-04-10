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

#' Set user agent for gfwr API requests
#' @name gfw_user_agent
#' @export
#' @keywords internal
gfw_user_agent <- function(){
  # Define user agent version
  return("gfwr/2.0.0 (https://github.com/GlobalFishingWatch/gfwr)")
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

#' Helper function to parse error message data
#' and display appropriately to user
#' @name parse_response_error
#' @keywords internal
#' @importFrom httr2 resp_body_json
#' @importFrom purrr map_chr
#' @importFrom purrr pluck
#' @keywords internal
#' @details Taken from httr2 docs: https://httr2.r-lib.org/articles/wrapping-apis.html#sending-data
parse_response_error <- function(resp) {
  body <- httr2::resp_body_raw(resp)
  messages <- body$messages
  if (length(messages[[1]]) > 1) {
    messages <- purrr::map_chr(messages, purrr::pluck, "detail")
  }
  messages
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


#' List of available regions
#' @name get_regions
#' @param region_source string, source of region data ("EEZ", "MPA", "RFMO')
#' @param key string, API token
#' @export
#' @return dataframe, all region ids and names for specified region type
#'
#' @importFrom dplyr filter
#' @importFrom dplyr bind_rows
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 req_error
#' @importFrom httr2 req_user_agent
#' @importFrom httr2 resp_body_json
#' @examples
#' get_regions(region_source = "EEZ")
#' get_regions(region_source = "RFMO")
#' get_regions(region_source = "MPA")
get_regions <- function(region_source = "EEZ",
                        key = gfw_auth()) {

  if (!toupper(region_source) %in% c("EEZ", "MPA", "RFMO")) {
    stop('Enter a valid region source ("EEZ", "MPA", or "RFMO"')
  } else {
    result <- get_endpoint(dataset_type = region_source) %>%
      httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
      httr2::req_user_agent(gfw_user_agent()) %>%
     # httr2::req_error(body = parse_response_error) %>%
      httr2::req_perform(.) %>%
      httr2::resp_body_json(.) %>%
      dplyr::bind_rows()

    return(result)
  }
}

#' Function to pull region code using region name and viceversa
#' @name get_region_id
#' @param region Character or numeric EEZ MPA or RFMO name or id.
#' @param region_source Character, source of region data, "EEZ", "MPA" or "RFMO".
#' @param key Character, API token. Defaults to gfw_auth().
#' @return The corresponding code, region names or iso code for the EEZ, MPA or
#' RFMO label
#' @importFrom dplyr filter
#' @importFrom dplyr bind_rows
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 req_error
#' @importFrom httr2 req_user_agent
#' @importFrom httr2 resp_body_json
#'
#' @export
#' @examples
#' \dontrun{
#' get_region_id(region = "COL", region_source = "EEZ")
#' get_region_id(region = "Colombia", region_source = "EEZ")
#' get_region_id(region = "Nazca", region_source = "MPA")
#' get_region_id(region = "IOTC", region_source = "RFMO")
#' get_region_id(region = 8456, region_source = "EEZ")
#' get_region_id(region = "", region_source = "EEZ")
#' get_region_id(region = NA, region_source = "EEZ")
#' get_region_id(region = NA, region_source = "MPA")
#' }
get_region_id <- function(region = NULL,
                          region_source = "EEZ",
                          key = gfw_auth()) {
  if (!region_source %in% c("EEZ", "MPA", "RFMO")) stop("Enter valid region source")

  result <- get_endpoint(dataset_type = region_source) %>%
    httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
    httr2::req_user_agent(gfw_user_agent()) %>%
    #httr2::req_error(body = parse_response_error) %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_json(.) %>%
    dplyr::bind_rows() %>%
    dplyr::relocate("id")

  if (is.na(region) | region == "")
    return(tidyr::tibble(id = NA, label = NA, iso3 = NA, NAME = NA, RFB = NA) %>% dplyr::select(tidyr::all_of(names(result))))


  # EEZ names
  if (region_source == "EEZ" & is.character(region)) {
    result %>%
    dplyr::filter(agrepl(region, .$label) |
                    agrepl(paste0("^",region), .$iso3))
  }
  # EEZ ids
  else if (region_source == "EEZ" & is.numeric(region)) {
    result %>%
      dplyr::filter(id == {{ region }})
  }
  # MPA names
  else if (region_source == "MPA" & is.character(region)) {
    result %>%
      dplyr::filter(agrepl(region, .$label))
  }
  # MPA ids
  else if (region_source == "MPA" & is.numeric(region)) {
    result %>%
      dplyr::filter(id == {{ region }})
  }
  # RFMO names
  else if (region_source == "RFMO" & is.character(region)) {
    result %>%
      dplyr::filter(agrepl(region, .$label))
  }
  # RFMO ids
  else if (region_source == "RFMO" & is.numeric(region)) {
    stop("RFMO codes are characters")
  }
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
#' @returns A correctly-formatted geojson to be used in `get_raster()` or `get_event()`
#' @importFrom geojsonsf sf_geojson
#' @examples
#' library(gfwr)
#' data(test_shape)
#' substr(sf_to_geojson(test_shape), 1, 20)
#' substr(sf_to_geojson(test_shape, endpoint = "event"), 1, 20)
#' @export
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

globalVariables(c("."))
globalVariables(c("<list>"))
globalVariables(c("geartypes"))
globalVariables(c("id"))
globalVariables(c("includes"))
globalVariables(c("index"))
globalVariables(c("shiptypes"))
globalVariables(c("sourceCode"))
globalVariables(c("value"))
globalVariables(c("vessel"))
globalVariables(c("vessel_id"))
globalVariables(c("registries_info_data"))
