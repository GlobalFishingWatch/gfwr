#' Base function to get vessel information from API and convert response to data frame
#'
#' @param query search terms to identify vessel
#' @param search_type type of search, may be 'basic','advanced', or 'id'
#' @param dataset identity datasets to search against, default = 'all'

#' @importFrom httr2 req_headers
#' @importFrom httr2 req_perform
#' @importFrom httr2 resp_body_json
#' @importFrom tidyr unnest_wider
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
#' @examples
#' get_vessel_info(query = 224224000, search_type = 'basic')
#' get_vessel_info(query = "shipname LIKE '%GABU REEFE%' OR imo = '8300949'", search_type = 'advanced')
#' get_vessel_info(query = "8c7304226-6c71-edbe-0b63-c246734b3c01", search_type = 'id')

get_vessel_info <- function(query = NULL,
                            search_type = NULL,
                            dataset = "all") {

  endpoint <- get_identity_endpoint(
    dataset_type = dataset,
    search_type = search_type,
    query = query
  )

  response <- endpoint %>%
    httr2::req_headers(Authorization = paste("Bearer", Sys.getenv("GFW_V2_TOKEN"), sep = " ")) %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_json()

  output <- enframe(response$entries) %>%
    tidyr::unnest_wider(data = ., col = value)

  return(output)
}
