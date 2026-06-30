#' List of available regions in Global Fishing Watch
#' platforms, EEZs, MPAs, and RFMOs
#'
#' @details
#' For detailed information about the Regions API, please refer to the official
#' Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#regions
#'
#' For more details on the Regions API data caveats, please refer to the official
#' Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#exclusive-economic-zone-boundaries-definitions
#' - https://globalfishingwatch.org/our-apis/documentation#marine-protected-area-boundaries-definition
#' - https://globalfishingwatch.org/our-apis/documentation#what-does-it-mean-if-an-event-is-within-a-specific-geographic-area-such-as-an-eez-mpa-or-rfmo
#' - https://globalfishingwatch.org/our-apis/documentation#how-does-gfw-calculate-that-an-event-has-a-publicly-listed-authorization
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api-rfmo-iuu-vessel-list
#'
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

      # Make data available
      utils::data("gfw_marine_regions", package = "gfwr", envir = environment())

      result <- gfw_marine_regions %>%
        dplyr::rename(id = MRGID,
                      label = name)
    }
    return(result)
  }
}

#' Function to pull region code using region name and viceversa
#'
#' @details
#' For detailed information about the Regions API, please refer to the official
#' Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#regions
#'
#' For more details on the Regions API data caveats, please refer to the official
#' Global Fishing Watch API documentation:
#' - https://globalfishingwatch.org/our-apis/documentation#exclusive-economic-zone-boundaries-definitions
#' - https://globalfishingwatch.org/our-apis/documentation#marine-protected-area-boundaries-definition
#' - https://globalfishingwatch.org/our-apis/documentation#what-does-it-mean-if-an-event-is-within-a-specific-geographic-area-such-as-an-eez-mpa-or-rfmo
#' - https://globalfishingwatch.org/our-apis/documentation#how-does-gfw-calculate-that-an-event-has-a-publicly-listed-authorization
#' - https://globalfishingwatch.org/our-apis/documentation#insights-api-rfmo-iuu-vessel-list
#'
#' @name gfw_region_id
#' @param region Character or numeric EEZ MPA or RFMO name or id.
#' @param region_source Character, source of region data, `"EEZ"`, `"MPA"` or `"RFMO"`.
#' @param region_name Deprecated, replaced by region.
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
#' @importFrom lifecycle deprecated
#' @importFrom lifecycle deprecate_warn
#' @seealso [gfw_regions()]
#' @export
#' @examples
#' \dontrun{
#' gfw_region_id(region = "COL", region_source = "EEZ")
#' gfw_region_id(region = "Colombia", region_source = "EEZ")
#' gfw_region_id(region = "Nazca", region_source = "MPA")
#' gfw_region_id(region = "IOTC", region_source = "RFMO")
#' gfw_region_id(region = 8456, region_source = "EEZ")
#' # Handling empty strings (high-seas)
#' gfw_region_id(region = "", region_source = "EEZ")
#' gfw_region_id(region = NA, region_source = "EEZ")
#' gfw_region_id(region = NA, region_source = "MPA")
#' }
gfw_region_id <- function(region = NULL,
                          region_source = "EEZ",
                          key = gfw_auth(),
                          region_name = deprecated()) {
  if (lifecycle::is_present(region_name)) {

    # Signal the deprecation to the user
    lifecycle::deprecate_warn("3.0", "gfwr::gfw_region_id(region_name = )", "gfwr::gfw_region_id(region = )")

    # Deal with the deprecated argument for compatibility
    region <- region_name
  }

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

    # Make data available
    utils::data("gfw_marine_regions", package = "gfwr", envir = environment())

    result <- gfw_marine_regions %>%
      dplyr::rename(id = MRGID,
                    label = name,
                    iso3 = iso)
  }

  if (is.na(region) | region == "")
    return(tidyr::tibble(id = NA, label = NA, iso3 = NA, GEONAME = NA, NAME = NA, RFB = NA, POL_TYPE = NA) %>%
             dplyr::select(tidyr::all_of(names(result))))


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
