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
#' @param quiet Boolean. Whether to print the number of events returned by the
#' request and progress
#' @param key Authorization token. Can be obtained with `gfw_auth()` function
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string
#' @param ... Other parameters, see API documentation
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
#'  registries_info_data = c("DELTA"),
#'  key = gfw_auth())
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
                            quiet = FALSE,
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
  # Search id - ID search now receives a vector
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
  # search search
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


  endpoint <- base %>%
    httr2::req_url_path_append(path_append) %>%
    httr2::req_url_query(!!!args)


  request <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer", key, sep = " ")) %>%
    #httr2::req_error(., body = gist_error_body) %>%
    httr2::req_user_agent(gfw_user_agent())

  # pagination in search
  if (search_type == "search") {
    limit <- 50
    request <- request %>%
      httr2::req_url_query(`limit` = limit)

  }
  
  # performs request
  if (print_request) print(request)
  response <- request %>%
    httr2::req_perform() %>%
    httr2::resp_body_json(simplifyVector = TRUE, check_type = TRUE)
  # stop if not found
  if (response$total == 0) return(message("No vessel was found with that identifier"))

  # List to store responses
  responses <- list()
  responses[[1]] <- response

  # Current page values
  total <- response$total
  if (quiet == FALSE) message(paste( total, "total vessels"))
  n_entries <- length(response$entries)
  next_since <- response$since

  # Pagination
  while (!is.null(next_since)) {
      # # API call for next page
      next_response <- request %>%
        httr2::req_url_query(`since` = next_since) %>%
        httr2::req_perform()  %>%
        httr2::resp_body_json(simplifyVector = TRUE, check_type = TRUE)

    # Append response to list
    responses[[length(responses) + 1]] <- next_response

    # Pull out next_since of latest API response
    next_since <- next_response$since
    n_entries <- length(next_response$entries)
    if (quiet == FALSE) {
      total_requests <- ceiling(total/limit)
      current_request <- length(responses)
      cat("\rDownloading", floor(current_request*100/total_requests), "%" )
      }
  }
  # format tibbles
  all_entries <- purrr::map(responses, purrr::pluck, 'entries')

  # 1/8 dataset
  dataset <- purrr::map(all_entries, purrr::pluck, 'dataset') %>%
    unlist(recursive = F) %>%
    tibble::tibble(dataset = .)

  # 2/8 registryinfototalrecords
  # one row per vessel. Those who have registry info will show up with 1,
  # those are the ones that have their vesselRecord id available under registryInfo$id
  # most vessels with registry will show up first but sometimes there are vessels with registry down the list
  registryInfoTotalRecords <-
    purrr::map(all_entries, purrr::pluck, 'registryInfoTotalRecords') %>%
    unlist(recursive = F) %>%
    tibble::tibble(registryInfoTotalRecords = .)

  # 3/8 registryInfo -only for those who have it
  registryInfo <- purrr::map(all_entries, purrr::pluck, 'registryInfo') %>%
    unlist(recursive = FALSE) %>%
    purrr::map(., tibble::tibble) %>%
    dplyr::bind_rows(.id = "index")
  # format if non-empty
  if (any(registryInfoTotalRecords$registryInfoTotalRecords != 0)) {
  lookup <- c(recordId = "id")
    registryInfo <- registryInfo %>%
    dplyr::mutate(index = as.numeric(index)) %>%
    dplyr::rename(dplyr::any_of(lookup)) %>%
    #  dplyr::select(-`<list>`) %>%
    # unnest geartypes
    tidyr::unnest(geartypes, keep_empty = TRUE)
    }
  # 4/8 registryOwners #has all records with and without registry but may have a different
  #dimension than registryInfo due to lack of data
  registryOwners <- purrr::map(all_entries, purrr::pluck, "registryOwners") %>%
    unlist(recursive= FALSE) %>%
    purrr::map(., tibble::tibble) %>%
    dplyr::bind_rows(.id = "index") %>%
    dplyr::mutate(index = as.numeric(index))
    # dplyr::select(-`<list>`)

  # 5/8 registryPublicAuthorizations
  registryPublicAuthorizations <- purrr::map(all_entries, purrr::pluck, 'registryPublicAuthorizations') %>%
    unlist(recursive = F) %>%
    purrr::map(., tibble::tibble) %>%
    dplyr::bind_rows(.id = "index") %>%
    dplyr::mutate(index = as.numeric(index))
    #tidyr::unnest(sourceCode, keep_empty = TRUE)
    # dplyr::select(-`<list>`)

  # 6/8 combinedSourcesInfo joins vesselId, geartypes and shiptypes.
  combinedSourcesInfo <- purrr::map(all_entries, purrr::pluck, 'combinedSourcesInfo') %>%
    unlist(recursive = F) %>%
    purrr::map(., tibble::tibble) %>%
    dplyr::bind_rows(.id = "index") %>%
    dplyr::mutate(index = as.numeric(index)) %>% #after indexing we can unnest
    tidyr::unnest(geartypes, names_sep = "_", keep_empty = TRUE) %>%
    tidyr::unnest(shiptypes, names_sep = "_", keep_empty = TRUE)

  # 7/8 selfReportedInfo this is AIS
  selfReportedInfo <- purrr::map(all_entries, purrr::pluck, 'selfReportedInfo') %>%
    unlist(recursive = F) %>%
    purrr::map(., tibble::tibble) %>%
    dplyr::bind_rows(.id = "index") %>%
    dplyr::mutate(index = as.numeric(index)) %>%
    dplyr::rename(vesselId = id)

  # build output list
  output <- list(
    dataset = dataset,
    registryInfoTotalRecords = registryInfoTotalRecords,
    registryInfo = registryInfo,
    registryOwners = registryOwners,
    registryPublicAuthorizations = registryPublicAuthorizations,
    combinedSourcesInfo = combinedSourcesInfo,
    selfReportedInfo = selfReportedInfo)

  output$selfReportedInfo <- output$selfReportedInfo
  return(output)
}
