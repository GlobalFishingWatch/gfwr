#' Base function to get vessel information from API and convert response to data frame
#'
#' @param search_type Type of vessel search to perform. Can be `"search"` or
#' `"id"`. `"advanced"` and `"basic"` are no longer in use as of gfwr 2.0.0 check
#' parameters `query` and `where`
#' @param query search terms to identify vessel
#' @param where optional. SQL syntax to perform advanced search
#' @param includes enhances the response with new information.
#' `"MATCH_CRITERIA"`: adds information about the reason why a vessel is returned
#' `"OWNERSHIP"` returns owners information, `"AUTHORIZATIONS"` lists public
#' authorizations list for that vessel
#' @param registries_info_data when `search_type == "id"`, gets all the registry
#' objects, only the delta or the latest. Possible values: `"NONE"`, `"DELTA"`,
#' `"ALL"`
#' @param dataset identity datasets to search against, default  `'all'`
#' @param key Authorization token. Can be obtained with `gfw_auth()` function

#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 req_user_agent
#' @importFrom httr2 req_error
#' @importFrom httr2 resp_body_json
#' @importFrom tidyr unnest_wider
#' @importFrom tibble enframe
#'
#' @details
#' The search takes basic features like MMSI, IMO, callsign, shipname as inputs
#' and identifies all vessels in the specified
#  dataset that match, and more advanced input like fuzzy matching with
#' terms such as LIKE. The `id` search allows the user to search using a GFW
#' vessel id.
#' There are three identity databases available, `"carrier_vessel"`,
#' `"support_vessel"`, and `"fishing_vessel"`. The user can specify a vector with
#' any combination of those or `"all"` and search again all databases at once.
#' This is generally recommended.
#'
#' @export
get_vessel_info <- function(search_type = "search",
                            query = 224224000,
                            where = NULL,
                            includes = c("MATCH_CRITERIA","OWNERSHIP", "AUTHORIZATIONS")
                            registries_info_data = c("NONE"),
                            dataset = "all",
                            key = gfw_auth()) {

  if (search_type %in% c("advanced", "basic")) {
    # Signal the deprecation to the user
    warning("basic or advanced search are no longer in use as of gfwr 2.0.0. Options are 'search' or 'id'. Use `query` for simple queries and `where` for advanced SQL expressions")
    search_type <- "search"
  }

  endpoint <<- get_identity_endpoint(
    dataset_type = dataset,
    search_type = search_type,
    query = query,
    where = where,
    includes = includes,
    limit = 99999,
    offset = 0
  )

  response <<- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
    #httr2::req_error(., body = gist_error_body) %>%
    httr2::req_user_agent(gfw_user_agent()) %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_json()

  output <- tibble::enframe(response$entries) %>%
    tidyr::unnest_wider(data = ., col = value)

  return(output)
}
