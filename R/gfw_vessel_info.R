#' Base function to get vessel information from API and convert response to tibble
#'
#' @param search_type Type of vessel search to perform. Can be `"search"` (the
#' default) to search for identity markers or `"id"` to search per `vesselId`.
#' (Note:`"advanced"` and `"basic"` are no longer in use as of `gfwr 2.0.0.`).
#' @param query When `search_type = "search"`, a length-1 vector with the identity
#' variable of interest, MMSI, IMO, call sign or ship name. A search by vessel
#' name will return fuzzy results to account for variation in vessel names and
#' potential misspellings
#' @param where When `search_type = "search"`, an SQL expression to find the vessel of interest.
#' @param ids When `search_type = "id"`, a vector with one or more `vesselId`s
#' of interest.
#' @param includes Optional. Enhances the response with additional
#' information depending on the selected `search_type`. If not specified, all
#' supported values for the selected `search_type` will be returned. See
#' __Details__ below
#'
#' @param match_fields Optional. Allows to filter by `matchFields` levels.
#' Possible values: `"SEVERAL_FIELDS"`, `"NO_MATCH"`, `"ALL"`. Incompatible with `where`
#' @param registries_info_data when `search_type == "id"`, gets all the registry
#' objects, only the delta or the latest.
#' \describe{
#'  \item{`"NONE"`}{The API will return the most recent object only}
#'  \item{`"DELTA"`}{The API will return only the objects when the vessel
#'  changed one or more identity properties}
#'  \item{`"ALL"`}{The `registryInfo` array will return all objects we have in the vessel database}
#'  }
#' @param key Character, API token. Defaults to [gfw_auth()].
#' @param quiet Boolean. Whether to print the number of events returned by the
#' request and progress. Default is FALSE.
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string.
#' @param ... Other parameters, see API documentation.
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 req_user_agent
#' @importFrom httr2 req_error
#' @importFrom httr2 resp_body_json
#' @importFrom tidyr unnest_wider
#' @importFrom tibble enframe
#'
#' @details
#' - When `search_type = "search"` the search takes basic identity features like
#' MMSI, IMO, callsign, shipname as inputs, using parameter `"query"`. For more advanced
#' SQL searches, use parameter `"where"`. You can combine logic operators like `AND`,
#' `OR`, `=`, `>=` , <, `LIKE` (for fuzzy matching).
#'
#' - Parameter __`includes`__: When `search_type = "search"`, supported values are:
#' \describe{
#' \item{`"OWNERSHIP"`}{returns ownership information}
#' \item{`"AUTHORIZATIONS"`}{lists public authorizations for the vessel}
#' \item{`"MATCH_CRITERIA"`}{adds information about the reason why a vessel is
#' returned. This provides related `vesselId`s identified through
#' matching with vessel registry records and represents Global Fishing Watch's
#' best estimate for linking AIS (self-reported) vessel positions to Vessel
#' Identity information derived from public registries.}
#' }
#' When `search_type = "id"`, the supported value is
#' `"POTENTIAL_RELATED_SELF_REPORTED_INFO"` and will returns all potential
#' related self-reported vessel information mentioned above.
#'
#' @references Park, J., Van Osdel, J., Turner, J., Farthing, C.M., Miller, N.A.,
#' Linder, H.L., Ortuño Crespo, G., Carmine, G., Kroodsma, D.A., 2023. Tracking
#' elusive and shifting identities of the global fishing fleet. Science Advances
#' 9, eabp8200. [https://doi.org/10.1126/sciadv.abp8200](https://doi.org/10.1126/sciadv.abp8200)
#' @seealso
#' For more details check the [Vessel identity vignette](https://globalfishingwatch.github.io/gfwr/articles/identity.html)
#'
#' See also how the Vessel API is used in [Vessel Viewer](https://globalfishingwatch.org/our-apis/assets/2024_Vessel_Viewer_and_APIs_behind_It.pdf)
#'
#' @examples
#' \dontrun{
#' library(gfwr)
#'
#' # Simple search
#'
#' gfw_vessel_info(query = 224224000, search_type = "search")
#'
#' # Advanced search with where instead of query:
#' gfw_vessel_info(where = "ssvid = '441618000' OR imo = '9047271'",
#'                 search_type = "search")
#'
#'  # Vessel id search
#'
#'  gfw_vessel_info(search_type = "id",
#'  ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01",
#'  "6583c51e3-3626-5638-866a-f47c3bc7ef7c"))
#'  }
#' @export
gfw_vessel_info <- function(search_type = "search",
                            query = NULL,
                            where = NULL,
                            ids = NULL,
                            includes = NULL,
                            match_fields = NULL,
                            registries_info_data = c("ALL"),
                            key = gfw_auth(),
                            quiet = FALSE,
                            print_request = FALSE,
                            ...) {
  if (search_type %in% c("advanced", "basic")) {
    # Signal the deprecation to the user
    warning("basic or advanced search are no longer in use. Options are 'search' or 'id'")
    search_type <- "search"
  }

  # Validate includes ---------------------------------------------------------

  includes <- validate_gfw_vessel_info_includes(includes = includes, search_type = search_type)

  #endpoint <- gfw_identity_endpoint(
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


  base <- httr2::request(gfw_base_url())

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

  }

  # format includes
  if (!is.null(includes)) {
    incl <- vector_to_array(includes, type = "includes")
    args <- c(args, incl)
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
    # unnest geartypes if the column
    {
    if ("geartypes" %in% names(.))
      tidyr::unnest(., geartypes, names_sep = "_", keep_empty = TRUE)
    }
    }
  # 4/8 registryOwners #has all records with and without registry but may have a different
  #dimension than registryInfo due to lack of data
  if (any(purrr::map_lgl(all_entries, \(x) !is.null(x[['registryOwners']])))) {
  registryOwners <- purrr::map(all_entries, purrr::pluck, "registryOwners") %>%
    unlist(recursive = FALSE) %>%
    purrr::map(., tibble::tibble) %>%
    dplyr::bind_rows(.id = "index") %>%
    dplyr::mutate(index = as.numeric(index))
    # dplyr::select(-`<list>`)
}
  # 5/8 registryPublicAuthorizations
  if (any(purrr::map_lgl(all_entries, \(x) !is.null(x[['registryPublicAuthorizations']])))) {
  registryPublicAuthorizations <- purrr::map(all_entries, purrr::pluck, 'registryPublicAuthorizations') %>%
    unlist(recursive = F) %>%
    purrr::map(., tibble::tibble) %>%
    dplyr::bind_rows(.id = "index") %>%
    dplyr::mutate(index = as.numeric(index))
    #tidyr::unnest(sourceCode, keep_empty = TRUE)
    # dplyr::select(-`<list>`)
  }

  # matchCriteria
  if (any(purrr::map_lgl(all_entries, \(x) !is.null(x[['matchCriteria']])))) {
  matchCriteria <- purrr::map(all_entries, purrr::pluck, 'matchCriteria') %>%
    unlist(recursive = F) %>%
    purrr::map(., tibble::tibble) %>%
    dplyr::bind_rows(.id = "index") %>%
    dplyr::mutate(index = as.numeric(index)) %>%
    # dplyr::rename(vesselId = reference) %>%
    tidyr::unnest(., matches, names_sep = "_", keep_empty = TRUE)
  }
  # 6/8 combinedSourcesInfo joins vesselId, geartypes and shiptypes.
  combinedSourcesInfo <- purrr::map(all_entries, purrr::pluck, 'combinedSourcesInfo') %>%
    unlist(recursive = F) %>%
    purrr::map(., tibble::tibble) %>%
    dplyr::bind_rows(.id = "index") %>%
    dplyr::mutate(index = as.numeric(index)) %>% #after indexing we can unnest
    {
      if ("geartypes" %in% names(.))
        tidyr::unnest(., geartypes, names_sep = "_", keep_empty = TRUE)
    } %>%
    {
      if ("shiptypes" %in% names(.))
        tidyr::unnest(., shiptypes, names_sep = "_", keep_empty = TRUE)
    }


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
    selfReportedInfo = selfReportedInfo,
    registryInfo = registryInfo,
    registryOwners = get0("registryOwners"),
    registryPublicAuthorizations = get0("registryPublicAuthorizations"),
    matchCriteria = get0("matchCriteria"),
    combinedSourcesInfo = combinedSourcesInfo
    )

  return(output)
}

#' Validate `includes` for vessel info queries
#'
#' @param includes Character vector of includes requested.
#' @param search_type Type of vessel search to performed by [gfw_vessel_info()].
#'
#' @return A normalized character vector of validated include values.
#'
#' @name validate_gfw_vessel_info_includes
#' @keywords internal
#' @noRd
validate_gfw_vessel_info_includes <- function(includes = NULL, search_type = "search") {
  search_includes <- c(
    "AUTHORIZATIONS",
    "OWNERSHIP",
    "MATCH_CRITERIA"
  )

  id_includes <- c(
    "POTENTIAL_RELATED_SELF_REPORTED_INFO"
  )

  allowed_includes <- switch(search_type,
    search = search_includes,
    id = id_includes
  )

  if (is.null(includes)) {
    includes <- allowed_includes
  }

  includes <- trimws(toupper(includes))

  invalid_includes <- setdiff(includes, allowed_includes)

  if (length(invalid_includes) > 0) {
    rlang::abort(
      c(
        "Invalid `includes` value(s).",
        x = glue::glue_collapse(invalid_includes, sep = ", "),
        i = glue::glue(
          "`search_type = '{search_type}'` only supports: {glue::glue_collapse(allowed_includes, sep = ', ')}"
        )
      ),
      class = "gfw_vessel_info_invalid_includes"
    )
  }

  includes
}
