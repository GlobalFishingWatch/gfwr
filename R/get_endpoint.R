#'
#' Function to get endpoint for given event type
#'

get_endpoint <- function(event_type = 'port_visit',
                         limit = 10,
                         vessel){

  if(event_type == 'port_visit'){

    endpoint <- glue::glue("https://gateway.api.globalfishingwatch.org//v1/",
                           "events?datasets=public-global-port-visits-c2-events:v20201001",
                           "&limit={limit}&vessels={vessel}")

  } else if(event_type == 'fishing'){

    endpoint <- glue::glue("https://gateway.api.globalfishingwatch.org//v1/",
                           "events?datasets=public-global-fishing-events:v20201001",
                           "&limit={limit}&vessels={vessel}")
  }

  return(endpoint)
}
