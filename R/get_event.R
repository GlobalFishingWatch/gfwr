#'
#' Base function to get event from API and convert response to data frame
#'
#' @param event_type

get_event <- function(event_type='port_visit',
                      limit = 10,
                      vessel = '6583c51e3-3626-5638-866a-f47c3bc7ef7c',
                      auth){

  # Set endpoint
  # TODO: Use lookup table to select endpoint based on event_type param
  endpoint <- get_endpoint(event_type, limit, vessel=vessel)

  # API call
  # TODO: Add exception handling
  gfw_json <- httr::GET(endpoint, auth)
  gfw_list <- httr::content(gfw_json)

  # Function to extract each entry to tibble
  event_entry <- function(x){
    enframe(x) %>%
      as_tibble() %>%
      pivot_wider(., names_from = name, values_from = value) %>%
      unnest_wider(position)
  }

  # basic function to make length 1 lists into characters
  make_char <- function(col) {
    if(is.list(col) & lengths(col) == 1) {
      as.character(col)
    } else {
      col
    }
  }

  # If we know we will always have start and end as datetime we could also add this
  make_datetime <- function(x) {
    as.POSIXct(as.character(x), format = '%Y-%m-%dT%H:%M:%S', tz = 'UTC')
  }

  # Map function to each event to convert to data frame
  # and format non-list columns to character and datetime
  event_df <- map_dfr(gfw_list$entries, event_entry) %>%
    mutate(across(everything(), make_char)) %>%
    mutate(across(c(start, end), make_datetime))

  # Return final data frame
  return(event_df)
}
