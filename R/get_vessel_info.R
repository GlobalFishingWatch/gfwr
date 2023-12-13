#' Base function to get vessel information from API and convert response to data frame
#'
#' @param search_type Type of vessel search to perform. Can be `"search"` or
#' `"id"`. (Note:`"advanced"` and `"basic"` are no longer in use as of gfwr 2.0.0.)
#' @param match_fields Optional. Allows to filter by `matchFields` levels.
#' Possible values: `"SEVERAL_FIELDS"`, `"NO_MATCH"`, `"ALL"`. Incompatible with `where`
#' @param includes Enhances the response with new information.
#' \describe{
#' \item{`"OWNERSHIP"`}{returns ownership information}
#' \item{`"AUTHORIZATIONS"`}{lists public authorizations for that vessel}
#' \item{`"MATCH_CRITERIA"`}{adds information about the reason why a vessel is returned}
#' }
#' @param ids When `search_type = "id"`, a vector with identifiers of interest,
#' can be MMSIs, IMO, CALL SIGN, Ship name
#' @param registries_info_data when `search_type == "id"`, gets all the registry
#' objects, only the delta or the latest.
#' \describe{
#'  \item{`"NONE"`}{The API will return the most recent object only}
#'  \item{`"DELTA"`}{The API will return only the objects when the vessel
#'  changed one or more identity properties}
#'  \item{`"ALL"`}{The registryInfo array will return the same number of objects that rows we have in the vessel database}
#'  }
#' @param key Authorization token. Can be obtained with `gfw_auth()` function
#' @param ... Other parameters

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
#' @examples
#' library(gfwr)
#' # Simple searches, using includes
#' get_vessel_info(query = 224224000, search_type = "search",
#' key = gfw_auth())
#' get_vessel_info(query = 224224000, search_type = "search",
#'includes = "OWNERSHIP", key = gfw_auth())
#' get_vessel_info(query = 224224000, search_type = "search",
#'includes = c("OWNERSHIP", "AUTHORIZATIONS"), key = gfw_auth())
#' # Advanced search with where instead of query:
#' get_vessel_info(where = "ssvid = '441618000' OR imo = '9047271'",
#' search_type = "search",
#' includes = c("OWNERSHIP", "AUTHORIZATIONS"),
#' key = gfw_auth())
#'  # Vessel id search
#'  get_vessel_info(search_type = "id",
#'  ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01",
#'  "6583c51e3-3626-5638-866a-f47c3bc7ef7c"), key = gfw_auth())
#'  get_vessel_info(search_type = "id",
#'  ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
#'  registries_info_data = c("ALL"), key = gfw_auth())
#' @export
get_vessel_info <- function(ids = NULL,
                            #query = NULL,
                            #where = NULL,
                            includes = NULL,
                            match_fields = NULL,
                            registries_info_data = NULL,
                            search_type = "search",
                            key = gfw_auth(),
                            ...) {

  if (search_type %in% c("advanced", "basic")) {
    # Signal the deprecation to the user
    warning("basic or advanced search are no longer in use as of gfwr 2.0.0. Options are 'search' or 'id'. Use `query` for simple queries and `where` for advanced SQL expressions")
    search_type <- "search"
  }

  #endpoint <- get_identity_endpoint(
    #search_type = search_type,
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
}

base <- httr2::request("https://gateway.api.globalfishingwatch.org/v3/")

# Only one dataset ID for selected API
dataset <- "public-global-vessel-identity:latest"
dataset <- vector_to_array(dataset, type = "datasets")
args <- c(args, dataset)

# ID search now receives a vector
if (search_type == "id") {
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
endpoint <- base %>%
  httr2::req_url_path_append(path_append) %>%
  httr2::req_url_query(!!!args)

  response <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
    #httr2::req_error(., body = gist_error_body) %>%
    httr2::req_user_agent(gfw_user_agent()) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json(simplifyVector = TRUE)

  output <- list(
    dataset = purrr::pluck(response$entries, "dataset"),
    registryInfoTotalRecords = purrr::pluck(response$entries, "registryInfoTotalRecords"),
    registryInfo = bind_rows(purrr::map(response$entries$registryInfo, tibble::tibble)),
    registryOwners = purrr::map(response$entries$registryOwners, tibble::tibble),
    registryPublicAuthorizations = purrr::map(response$entries$registryPublicAuthorizations, tibble::tibble),
    selfReportedInfo = purrr::map(response$entries$registryselfReportedInfo, tibble::tibble)
    )

  return(output)
}
