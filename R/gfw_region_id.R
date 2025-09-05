#' List of available regions in Global Fishing Watch
#' platforms, EEZs, MPAs, and RFMOs
#' @param region_source string, source of region data ("EEZ", "MPA", "RFMO')
#' @param key Character, API token. Defaults to [gfw_auth()].
#' @export
#' @return A dataframe with all region ids and names for
#' specified region type
#'
#' @importFrom dplyr filter
#' @importFrom dplyr bind_rows
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 req_error
#' @importFrom httr2 req_user_agent
#' @importFrom httr2 resp_body_json
#' @seealso [gfw_region_id()]
#' @examples
#' \dontrun{
#' gfw_regions(region_source = "EEZ")
#' gfw_regions(region_source = "RFMO")
#' gfw_regions(region_source = "MPA")
#' }
gfw_regions <- function(region_source = "EEZ",
                        key = gfw_auth()) {

  if (!toupper(region_source) %in% c("EEZ", "MPA", "RFMO")) {
    stop('Enter a valid region source ("EEZ", "MPA", or "RFMO"')
  } else {
    result <- gfw_endpoint(dataset_type = region_source) %>%
      httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
      httr2::req_user_agent(gfw_user_agent()) %>%
      # httr2::req_error(body = parse_response_error) %>%
      httr2::req_perform(.) %>%
      httr2::resp_body_json(.) %>%
      dplyr::bind_rows()
    if (region_source == "EEZ") {
      result <- marine_regions %>%
        dplyr::rename(id = MRGID,
               label = name)
    }
    return(result)
  }
}

#' Function to pull region code using region name and viceversa
#' @name gfw_region_id
#' @param region_name Character or numeric EEZ MPA or RFMO name or id.
#' @param region_source Character, source of region data, `"EEZ"`, `"MPA"` or `"RFMO"`.
#' @param key Character, API token. Defaults to `gfw_auth()`.
#' @return For `gfw_region_id()`, the corresponding code, region names or iso code
#' for the EEZ, MPA or RFMO label
#' @importFrom dplyr filter
#' @importFrom dplyr bind_rows
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 req_error
#' @importFrom httr2 req_user_agent
#' @importFrom httr2 resp_body_json
#' @seealso [gfw_regions()]
#' @export
#' @examples
#' \dontrun{
#' gfw_region_id(region_name = "COL", region_source = "EEZ")
#' gfw_region_id(region_name = "Colombia", region_source = "EEZ")
#' gfw_region_id(region_name = "Nazca", region_source = "MPA")
#' gfw_region_id(region_name = "IOTC", region_source = "RFMO")
#' gfw_region_id(region_name = 8456, region_source = "EEZ")
#' # Handling empty strings (high-seas)
#' gfw_region_id(region_name = "", region_source = "EEZ")
#' gfw_region_id(region_name = NA, region_source = "EEZ")
#' gfw_region_id(region_name = NA, region_source = "MPA")
#' }
gfw_region_id <- function(region_name = NULL,
                          region_source = "EEZ",
                          key = gfw_auth()) {
  if (!region_source %in% c("EEZ", "MPA", "RFMO")) stop("Enter valid region source")

  result <- gfw_endpoint(dataset_type = region_source) %>%
    httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
    httr2::req_user_agent(gfw_user_agent()) %>%
    #httr2::req_error(body = parse_response_error) %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_json(.) %>%
    dplyr::bind_rows() %>%
    dplyr::relocate("id")
  if (region_source == "EEZ") {
    result <- marine_regions %>%
      dplyr::rename(id = MRGID,
                    label = name,
                    iso3 = iso)
  }

  if (is.na(region_name) | region_name == "")
    return(tidyr::tibble(id = NA, label = NA, iso3 = NA, GEONAME = NA, NAME = NA, RFB = NA, POL_TYPE = NA) %>%
             dplyr::select(tidyr::all_of(names(result))))


  # EEZ names
  if (region_source == "EEZ" & is.character(region_name)) {
    result %>%
      dplyr::filter(agrepl(region_name, .$label) |
                      agrepl(paste0("^",region_name), .$iso3))
  }
  # EEZ ids
  else if (region_source == "EEZ" & is.numeric(region_name)) {
    result %>%
      dplyr::filter(id == {{ region_name }})
  }
  # MPA names
  else if (region_source == "MPA" & is.character(region_name)) {
    result %>%
      dplyr::filter(agrepl(region_name, .$label))
  }
  # MPA ids
  else if (region_source == "MPA" & is.numeric(region_name)) {
    result %>%
      dplyr::filter(id == {{ region_name }})
  }
  # RFMO names
  else if (region_source == "RFMO" & is.character(region_name)) {
    result %>%
      dplyr::filter(agrepl(region_name, .$label))
  }
  # RFMO ids
  else if (region_source == "RFMO" & is.numeric(region_name)) {
    stop("RFMO codes are characters")
  }
}
