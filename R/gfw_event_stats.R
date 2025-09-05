#' Get events stats from API and convert response to tibble
#'
#' @param event_type Type of event to get data of. A vector with any combination
#' of "ENCOUNTER", "FISHING", "GAP", "LOITERING", "PORT_VISIT"
#' @param start_date Start of date range to search events, in YYYY-MM-DD format
#' and including this date
#' @param end_date End of date range to search events, in YYYY-MM-DD format and
#' __excluding this date__
#' @param interval Time series granularity. Must be a string. Possible values: 'HOUR', 'DAY', 'MONTH', 'YEAR'.
#' @param vessels A vector of vesselIds, obtained via [gfw_vessel_info()]
#' @param flags ISO3 code for the flag of the vessels. Null by default.
#' @param vessel_types A vector of vessel types, any combination of: `"FISHING"`,
#' `"CARRIER"`, `"SUPPORT"`, `"PASSENGER"`, `"OTHER_NON_FISHING"`, `"SEISMIC_VESSEL"`,
#' `"BUNKER_OR_TANKER"`, `"CARGO"`
#' @param region_source Optional. Source of the region ('EEZ','MPA', 'RFMO' or
#' 'USER_SHAPEFILE').
#' @param region Optional but required if a value for `region_source` is specified.
#' If `region_source` is set to "EEZ", "MPA" or "RFMO", GFW region
#' code (see [gfw_region_id()]). If `region_source = "USER_SHAPEFILE"`, `sf`
#' shapefile with the area of interest.
#' @param duration minimum duration of the event in minutes. The default value is 1.
#' @param encounter_types Only useful when `event_type = "ENCOUNTER"`. Filters for
#' types of vessels during the encounter. A
#' vector with any combination of: `"CARRIER-FISHING"`, `"FISHING-CARRIER"`,
#' `"FISHING-SUPPORT"`, `"SUPPORT-FISHING"`.
#' @param confidences Only useful when event_type = "PORT_VISIT". Confidence
#' levels (2-4) of events.
#' @param key Character, API token. Defaults to [gfw_auth()].
#' @param quiet Boolean. Whether to print the number of events returned by the
#' request
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string
#' @param ... Other arguments
#'
#' @importFrom dplyr mutate
#' @importFrom purrr map_chr
#' @importFrom purrr map_dbl
#' @importFrom purrr map
#' @importFrom purrr pluck
#' @importFrom rlang .data
#' @importFrom tibble tibble
#' @importFrom jsonlite fromJSON
#' @importFrom jsonlite unbox
#' @importFrom rjson toJSON
#'
#' @details
#' There are currently four available event types and these events are provided
#' for three vessel types - fishing, carrier, and support vessels.
#' Fishing events (`event_type = "FISHING"`) are specific to fishing vessels and
#' loitering events (`event_type = "LOITERING"`) are specific to carrier vessels.
#' Port visits (`event_type = "PORT_VISIT"`) and encounters
#' (`event_type = "ENCOUNTER"`) are available for all vessel types. For more
#' details about the various event types, see the
#' [GFW API documentation](https://globalfishingwatch.org/our-apis/documentation#data-caveat).
#'
#' @examples
#' \dontrun{
#' library(gfwr)
#'  # stats for encounters involving Russian carriers in given time range
#' gfw_event_stats(event_type = 'ENCOUNTER',
#' encounter_types = c("CARRIER-FISHING","FISHING-CARRIER"),
#' vessel_types = 'CARRIER',
#' start_date = "2018-01-01",
#' end_date = "2023-01-31",
#' flags = 'RUS',
#' duration = 60,
#' interval = "YEAR")
#'  # port visits stats in a region (Senegal)
#'  gfw_event_stats(event_type = 'PORT_VISIT',
#' start_date = "2018-01-01",
#' end_date = "2019-01-31",
#' confidences = c('3','4'),
#' region = 8371,
#' region_source = 'EEZ',
#' interval = "YEAR")
#' }
#' @export

gfw_event_stats <- function(event_type,
                            start_date = "2012-01-01",
                            end_date = "2024-12-31",
                            interval = NULL,
                            vessels = NULL,
                            flags = NULL,
                            vessel_types = NULL,
                            region_source = NULL,
                            region = NULL,
                            duration = 1,
                            encounter_types = NULL,
                            confidences = c(2, 3, 4),
                            key = gfw_auth(),
                            quiet = FALSE,
                            print_request = FALSE,
                            ...) {
  # API endpoint specific parameters from ...
  args <- list(...)
  for (i in seq_len(length(args))) {
    assign(names(args[i]), args[[i]])
  }

  body_args <- c(args)
  if (!is.null(start_date)) start <- c("startDate" = start_date)
  if (!is.null(end_date)) end <- c('endDate' = end_date)
  duration <- c('duration' = duration)
  interval <- c('timeseriesInterval' = interval)

  #vessels array
  if (!is.null(vessels)) {
    vessels <- list("vessels" = vessels)
    body_args <- c(body_args, vessels)
  }
  # confidences
  if (event_type != "PORT_VISIT") confidences <- NULL
  if (!is.null(confidences)) {
    confidences <- list("confidences" = as.character(confidences))
    body_args <- c(body_args, confidences)
  }
  # vessel_types
  if (!is.null(vessel_types)) {
    vessel_types <- list('vesselTypes' = vessel_types)
    body_args <- c(body_args, vessel_types)
  }
  # encounter_types
  if (!is.null(encounter_types)) {
    encounter_types <- list("encounterTypes" = encounter_types)
    body_args <- c(body_args, encounter_types)
  }
  # flags
  if (!is.null(flags)) {
    flags <- list("flags" = flags)
    body_args <- c(body_args, flags)
  }
  # duration
  if (!is.null(duration)) {
    duration <- list(duration = jsonlite::unbox(duration))
    body_args <- c(body_args, duration)
  }

  base <- httr2::request("https://gateway.api.globalfishingwatch.org/v3/")

  api_datasets <- c(
    'ENCOUNTER' = "public-global-encounters-events:latest",
    'FISHING' = "public-global-fishing-events:latest",
    'GAP' = "public-global-gaps-events:latest",
    'LOITERING' = "public-global-loitering-events:latest",
    'PORT_VISIT' = "public-global-port-visits-c2-events:latest"
  )

  # Modify base URL with query parameters
  #datasets array
  dataset <- api_datasets[[event_type]]
  datasets <- list('datasets' = dataset)
  body_args <- c(datasets,  body_args)

  if (!is.null(region)) {
    if (region_source == 'MPA' & is.numeric(region)) {
      region = rjson::toJSON(list(region = list(dataset = 'public-mpa-all',
                                                id = region)))

    } else if (region_source == 'EEZ' & is.numeric(region)) {
      region = rjson::toJSON(list(region = list(dataset = 'public-eez-areas',
                                                id = region)))
    } else if (region_source == 'RFMO' & is.character(region)) {
      region = rjson::toJSON(list(region = list(dataset = 'public-rfmo',
                                                id = region)))
    } else if (region_source == 'USER_SHAPEFILE') {
      if (methods::is(region, 'sf') & base::class(region$geometry)[1] %in% c("sfc_POLYGON","sfc_MULTIPOLYGON")) {
        region <- sf_to_geojson(region, endpoint = 'event')
      } else {
        stop('custom region is not an sf polygon')
      }
    } else {
      stop('region source and region format do not match')
    }
  }

  if (is.null(region_source)) {

    body_args <- jsonlite::toJSON(c(body_args,
                                    list(startDate = jsonlite::unbox(start)),
                                    list(endDate = jsonlite::unbox(end)),
                                    list(timeseriesInterval = jsonlite::unbox(interval))
    ))
  } else if (region_source == 'USER_SHAPEFILE') {

    body_args <- jsonlite::toJSON(c(body_args,
                                    list(startDate = jsonlite::unbox(start)), # removes from array
                                    list(endDate = jsonlite::unbox(end)),
                                    list(timeseriesInterval = jsonlite::unbox(interval))
    ))
    # user json is just concatenated onto other body arguments
    body_args <- gsub('}$', '', body_args)
    body_args <- paste0(body_args,',', region,'}')

  } else {

    body_args <- jsonlite::toJSON(c(body_args,
                                    jsonlite::fromJSON(region),
                                    list(startDate = jsonlite::unbox(start)),
                                    list(endDate = jsonlite::unbox(end)),
                                    list(timeseriesInterval = jsonlite::unbox(interval))
    ))
  }

  endpoint <- base %>%
    httr2::req_url_path_append('events/stats') %>%
    httr2::req_body_raw(body = body_args) %>%
    httr2::req_user_agent(gfw_user_agent())
  if (print_request) print(endpoint)

  # API call; will paginate if necessary, otherwise return list with one response
  all_results <- gfw_api_request(endpoint, key)

  # Process results if they exist
  if (length(all_results) > 0) {
    #
    #     # Convert list to dataframe
    df_out <- tibble::tibble(
      numEvents = purrr::map_dbl(all_results, purrr::pluck, 'numEvents'),
      numFlags = purrr::map_dbl(all_results, purrr::pluck, 'numFlags'),
      numVessels = purrr::map_dbl(all_results, purrr::pluck, 'numVessels'),
      flags = purrr::map(all_results, purrr::pluck, 'flags'),
      timeseries = purrr::map(all_results, purrr::pluck, 'timeseries'))

    #
    if (quiet == FALSE) {
      print(paste("There are", df_out$numEvents, tolower(event_type), "events for ", df_out$numVessels, " vessels from ", df_out$numFlags, "flag(s) in the selected area in the Global Fishing Watch database"))
    }
  } else {
    if (quiet == FALSE) {
      print("Your request returned zero results")
    }
    return()
  }

  # Return results
  return(df_out)
}

