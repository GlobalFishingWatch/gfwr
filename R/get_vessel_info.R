#' Base function to get vessel information from API and convert response to data frame
#'
#' @param query When `search_type = "search"`, a length-1 vector with the identity
#' variable of interest, MMSI, IMO, call sign or ship name.
#' @param where When `search_type = "search"`, an SQL expression to find the vessel of interest
#' @param ids When `search_type = "id"`, a vector with the vesselId of interest
#' @param search_type Type of vessel search to perform. Can be `"search"` or
#' `"id"`. (Note:`"advanced"` and `"basic"` are no longer in use as of gfwr 2.0.0.)
#' @param match_fields Optional. Allows to filter by `matchFields` levels.
#' Possible values: `"SEVERAL_FIELDS"`, `"NO_MATCH"`, `"ALL"`. Incompatible with `where`
#' @param includes Enhances the response with new information, defaults to include all.
#' \describe{
#' \item{`"OWNERSHIP"`}{returns ownership information}
#' \item{`"AUTHORIZATIONS"`}{lists public authorizations for that vessel}
#' \item{`"MATCH_CRITERIA"`}{adds information about the reason why a vessel is returned}
#' }
#' @param registries_info_data when `search_type == "id"`, gets all the registry
#' objects, only the delta or the latest.
#' \describe{
#'  \item{`"NONE"`}{The API will return the most recent object only}
#'  \item{`"DELTA"`}{The API will return only the objects when the vessel
#'  changed one or more identity properties}
#'  \item{`"ALL"`}{The registryInfo array will return the same number of objects that rows we have in the vessel database}
#'  }
#' @param key Authorization token. Can be obtained with `gfw_auth()` function
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string
#' @param ... Other parameters, such as limit and offset

#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 req_user_agent
#' @importFrom httr2 req_error
#' @importFrom httr2 resp_body_json
#' @importFrom tidyr unnest_wider
#' @importFrom tibble enframe
#'
#' @details
#' When `search_type = "search"` the search takes basic identity features like
#' MMSI, IMO, callsign, shipname as inputs, using parameter `"query"`. For more advanced
#' SQL searches, use parameter `"where"`. You can combine logic operators like `AND`,
#' `OR`, `=`, `>=` , <, `LIKE` (for fuzzy matching). The `id` search allows the user
#' to search using a GFW vessel id.
#'
#' @examples
#' \dontrun{
#' library(gfwr)
#' # Simple searches, using includes
#' get_vessel_info(query = 224224000, search_type = "search",
#' key = gfw_auth())
#' # Advanced search with where instead of query:
#' get_vessel_info(where = "ssvid = '441618000' OR imo = '9047271'",
#' search_type = "search", key = gfw_auth())
#'  # Vessel id search
#'  get_vessel_info(search_type = "id",
#'  ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01",
#'  "6583c51e3-3626-5638-866a-f47c3bc7ef7c"), key = gfw_auth())
#'  all <- get_vessel_info(search_type = "id",
#'  ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
#'  registries_info_data = c("ALL"), key = gfw_auth())
#'  none <- get_vessel_info(search_type = "id",
#'  ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
#'  registries_info_data = c("NONE"), key = gfw_auth())
#'  delta <- get_vessel_info(search_type = "id",
#'  ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
#'  registries_info_data = c("DELTA"), key = gfw_auth())
#'  }
#' @export
get_vessel_info <- function(query = NULL,
                            where = NULL,
                            ids = NULL,
                            includes = c("AUTHORIZATIONS", "OWNERSHIP", "MATCH_CRITERIA"),
                            match_fields = NULL,
                            registries_info_data = c("ALL"),
                            search_type = "search",
                            key = gfw_auth(),
                            print_request = FALSE,
                            ...) {

  if (search_type %in% c("advanced", "basic")) {
    # Signal the deprecation to the user
    warning("basic or advanced search are no longer in use. Options are 'search' or 'id'")
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

#Default is search
    if (search_type == "search") {
    if (is.null(query) & is.null(where)) stop("either 'query' or 'where' must be specified when search_type = 'search'")
    if (!is.null(query) & !is.null(where)) stop("specify either 'query' or 'where', but not both when search_type = 'search'")
    if (!is.null(query))  {
      query <- c(`query` = query)
      args <- c(args, query)
    }
    if (!is.null(where))  {
      where <- c(`where` = where)
      args <- c(args, where)
    }
    path_append <- "vessels/search"

    #format includes
    if (!is.null(includes)) {
      incl <- vector_to_array(includes, type = "includes")
      args <- c(args, incl)
      }
    }
# ID search now receives a vector
if (search_type == "id" & is.null(ids)) stop("parameter 'ids' must be specified when search_type = 'id'")
if (!is.null("ids") & is.null(where) & is.null(query) & search_type == "search") stop("search_type must be 'id' when ids are specified")
if (!is.null("ids") & search_type == "id") {
  path_append <- "vessels"
  ids <- vector_to_array(ids, type = "ids")
  args <- c(args, ids)
  if (!is.null(registries_info_data)) {
    reg_info <- c(`registries-info-data` = registries_info_data)
    args <- c(args, reg_info)
  }
}

endpoint <- base %>%
  httr2::req_url_path_append(path_append) %>%
  httr2::req_url_query(!!!args)

if (print_request) print(endpoint)

   response <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
    #httr2::req_error(., body = gist_error_body) %>%
    httr2::req_user_agent(gfw_user_agent()) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json(simplifyVector = TRUE)
# stop if not found
   if (response$total == 0) return(message("No vessel was found with that identifier"))

  # format tibbles
  combinedSourcesInfo <- dplyr::bind_rows(purrr::map(response$entries$combinedSourcesInfo, tibble::tibble))

  if (!is.null(combinedSourcesInfo$geartypes))
    combinedSourcesInfo <- combinedSourcesInfo %>%
    tidyr::unnest(.data$geartypes, names_sep = "_geartype_", keep_empty = TRUE)

  if (!is.null(combinedSourcesInfo$shiptypes))
    combinedSourcesInfo <- combinedSourcesInfo %>%
    tidyr::unnest(.data$shiptypes, names_sep = "_shiptype_", keep_empty = TRUE)

  # build output list
  output <- list(
    dataset = tibble::tibble(dataset = response$entries$dataset),
    registryInfoTotalRecords = tibble::tibble(registryInfoTotalRecords = response$entries$registryInfoTotalRecords),
    registryInfo = dplyr::bind_rows(purrr::map(response$entries$registryInfo, tibble::tibble)),
    registryOwners = dplyr::bind_rows(purrr::map(response$entries$registryOwners, tibble::tibble)),
    registryPublicAuthorizations = dplyr::bind_rows(purrr::map(response$entries$registryPublicAuthorizations, tibble::tibble)),
    combinedSourcesInfo = combinedSourcesInfo,
    selfReportedInfo = dplyr::bind_rows(purrr::map(response$entries$selfReportedInfo, tibble::tibble))
    )

  output$selfReportedInfo <- output$selfReportedInfo %>% dplyr::rename(vesselId = id)
  return(output)
}
