#' Base function to get vessel information from API and convert response to data frame
#'
#' @param query search terms to identify vessel
#' @param search_type type of search, may be 'basic','advanced', or 'id'
#' @param dataset identity datasets to search against, default = 'all'
#' @param limit max number of entries to return in each API response. All results will
#' be returned regardless of limit
#' @param offset Internal parameter to GFW pagination
#' @param key Authorization token. Can be obtained with gfw_auth function

#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 req_user_agent
#' @importFrom httr2 req_error
#' @importFrom httr2 resp_body_json
#' @importFrom tidyr unnest_wider
#' @importFrom tibble enframe
#'
#' @details
#' There are three search types. `basic` search takes features like MMSI,
#' IMO, callsign, shipname as inputs and identifies all vessels in the specified
#' dataset that match. `advanced` search allows for the use of fuzzy matching with
#' terms such as LIKE. The `id` search allows the user to search using a GFW vessel
#' id.
#' There are three identity databases available, `"carrier_vessel"`, `"support_vessel"`,
#' and `"fishing_vessel"`. The user can also specify `"all"` and search again all databases
#' at once. This is generally recommended.
#'
#'@export

get_vessel_info <- function(query = NULL,
                            search_type = NULL,
                            dataset = "all",
                            limit = 99999,
                            offset = 0,
                            key = gfw_auth()) {

  if (!search_type %in% c("basic", "advanced", "id")) {
    stop("Please specify 'basic', 'advanced' or 'id' for the argument `search_type`.")
  }

  endpoint <- get_identity_endpoint(
    dataset_type = dataset,
    search_type = search_type,
    query = query,
    limit = limit,
    offset = offset
  )

  response <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
    httr2::req_error(., body = gist_error_body) %>%
    httr2::req_user_agent("gfwr/1.0.0 (https://github.com/GlobalFishingWatch/gfwr)") %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_json()

  output <- enframe(response$entries) %>%
    tidyr::unnest_wider(data = ., col = value)

  return(output)
}
