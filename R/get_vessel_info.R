#' Base function to get vessel information from API and convert response to data frame
#'
#' @param search_type Type of vessel search to perform. Can be `"search"` or
#' `"id"`. `"advanced"` and `"basic"` are no longer in use as of gfwr 2.0.0.  check
#' parameters `query` and `where`
#' @param query Basic search terms to identify vessel.
#' @param where Optional. SQL syntax to perform advanced search. Incompatible
#' with query.
#' @param includes Enhances the response with new information.
#' \describe{
#' \item{`"MATCH_CRITERIA"`}{adds information about the reason why a vessel is returned}
#' \item{`"OWNERSHIP"`}{returns ownership information}
#' \item{`"AUTHORIZATIONS"`}{lists public authorizations for that vessel}
#' }
#' @param ids When `search_type = "id"`, a vector with identities of interest
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
#' @examples
#' library(gfwr)
#' # Simple searches, using includes
#' get_vessel_info(query = 224224000, search_type = "search", dataset =
#'  "fishing_vessel", key = key)
#' get_vessel_info(query = 224224000, search_type = "search", dataset =
#'  "fishing_vessel", key = key, includes = "OWNERSHIP")
#' get_vessel_info(query = 224224000, search_type = "search", dataset =
#'  "fishing_vessel", key = key, includes = c("OWNERSHIP", "AUTHORIZATIONS"))
#' # Advanced search with where instead of query:
#' get_vessel_info(where = "ssvid = '441618000' OR imo = '9047271',
#'  search_type = "search", dataset = "fishing_vessel", key = key,
#'   includes = c("OWNERSHIP", "AUTHORIZATIONS"))
#'  # Vessel id search
#'  get_vessel_info(search_type = "id",
#'  ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01",
#'  "6583c51e3-3626-5638-866a-f47c3bc7ef7c"))
#'  get_vessel_info(search_type = "id",
#'  ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"), registries_info_data = c("ALL"))
#' @export
get_vessel_info <- function(search_type = "search",
                            includes = NULL,
                            ids = NULL,
                            registries_info_data = NULL,
                            dataset = "all",
                            key = gfw_auth(),
                            ...) {

  if (search_type %in% c("advanced", "basic")) {
    # Signal the deprecation to the user
    warning("basic or advanced search are no longer in use as of gfwr 2.0.0. Options are 'search' or 'id'. Use `query` for simple queries and `where` for advanced SQL expressions")
    search_type <- "search"
  }

  #if (!missing(query) & !is.null(where)) warning("where is incompatible with query. for advanced search, use only where")

  #endpoint <<- get_identity_endpoint(
   # dataset_type = dataset,
    #search_type = search_type,
    #query = query,
    #where = where,
    #includes = includes,
    #limit = 99999,
    #offset = 0
  #)
  #
# gets endpoint here ---------

# API endpoint specific parameters from ...
args <- list(...)
for (i in seq_len(length(args))) {
  assign(names(args[i]), args[[i]])
message(paste("First",args))
}
if (dataset == "all") dataset <- c("support_vessel", "carrier_vessel", "fishing_vessel")

base <- httr2::request("https://gateway.api.globalfishingwatch.org/v3/")

# API datasets to pass to param list
api_datasets <- c(
  "support_vessel" = "public-global-vessel-identity\U003Alatest",
  "carrier_vessel" = "public-global-vessel-identity:latest",
  "fishing_vessel" = "public-global-vessel-identity:latest"
)

# Get dataset ID for selected API
dataset <- api_datasets[names(api_datasets) %in% dataset]
dataset <- vector_to_array(dataset, type = "datasets")
args <- c(args, dataset)

# swap name is searching by vessel id
if (search_type == "id") {
  #names(args)[names(args) == "query"] <- "ids"
  ids <- vector_to_array(ids, type = "ids")
  path_append <- "vessels"
  if (!is.null(registries_info_data)) {
    reg_info <- c(`registries-info-data` = registries_info_data)
    args <- c(args, reg_info)
  }
  args <- c(args,
            ids)
    args <- args[!names(args) %in% c('limit','offset')]
} else if (search_type == "search") {
  path_append <- "vessels/search"
#format includes
if (!is.null(includes)) {
  incl <- vector_to_array(includes, type = "includes")
  args <- c(args, incl)
}

}
message(print(args))
endpoint <- base %>%
  httr2::req_url_path_append(path_append) %>%
  httr2::req_url_query(!!!args)

print(endpoint)
  response <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
    #httr2::req_error(., body = gist_error_body) %>%
    httr2::req_user_agent(gfw_user_agent()) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json()
print(response)
  #output <- tibble::enframe(response$entries) %>%
  #  tidyr::unnest_wider(data = ., col = value)

  #return(output)
}
