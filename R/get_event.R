#'
#' Base function to get events from API and convert response to data frame
#'
#' @param vessels A vector of VesselIDs, obtained via the `get_vessel_info()` function
#' @param event_type Type of event to get data of. A vector with any combination
#' of "ENCOUNTER", "FISHING", "GAP", "LOITERING", "PORT_VISIT"
#' @param encounter_types Filters for types of vessels during the encounter. A
#' vector with any combination of: "CARRIER-FISHING", "FISHING-CARRIER",
#' "FISHING-SUPPORT", "SUPPORT-FISHING"
#' @param vessel_types A vector of vessel types, any combination of: "FISHING",
#' "CARRIER", "SUPPORT", "PASSENGER", "OTHER_NON_FISHING", "SEISMIC_VESSEL",
#' "BUNKER_OR_TANKER", "CARGO"
#' @param duration duration, in minutes, of the event, ex. 30
#' @param start_date Start of date range to search events, in YYYY-MM-DD format and including this date
#' @param end_date End of date range to search events, in YYYY-MM-DD format and excluding this date
#' @param confidences Confidence levels (1-4) of events (port visits only)
#' @param region geojson shape to filter raster or GFW region code (such as an
#' EEZ code). See details about formatting the geojson
#' @param region_source source of the region ('EEZ','MPA', 'RFMO' or 'USER_JSON')
#' @param gap_intentional_disabling Logical. Whether the Gap events are intentional,
#' according to Global Fishing Watch algorithms
#' @param key Authorization token. Can be obtained with gfw_auth() function
#' @param quiet Boolean. Whether to print the number of events returned by the
#' request
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string
#' @param limit Limit
#' @param offset Offset
#' @param flags ISO3 code for the flag of the vessels. Null by default.
#' @param sort How to sort the events. By default, +start, which sorts the events
#' in ascending order (+) of the start dates of the events. Other possible values
#' are -start, +end, -end.
#' @param ... Other arguments
#'
#' @importFrom dplyr across
#' @importFrom dplyr mutate
#' @importFrom purrr map_chr
#' @importFrom purrr map_dbl
#' @importFrom purrr map
#' @importFrom purrr pluck
#' @importFrom purrr flatten
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
#' Encounter events involve multiple vessels and one row is returned for each
#' vessel involved in an encounter.
#' For example, an encounter between a carrier and fishing vessel
#' (`CARRIER-FISHING`) will have one row for the fishing vessel and one for the
#' carrier vessel. The `id` field for encounter events has two components
#' separated by a `.`. The first component is the unique id for the encounter
#' event and will be the same for all vessels involved in the encounter. The
#' second component is an integer used to distinguish between different vessels
#' in the encounter.
#'
#' @examples
#' library(gfwr)
#' # port visits
#' get_event(event_type = "PORT_VISIT",
#'           vessels = c("e0c9823749264a129d6b47a7aabce377",
#'           "8c7304226-6c71-edbe-0b63-c246734b3c01"),
#'           start_date = "2017-01-26",
#'           end_date = "2017-12-31",
#'           confidence = c(3, 4), # only for port visits
#'           key = gfw_auth())
#'  #encounters
#'  get_event(event_type = "ENCOUNTER",
#'  vessels = c("e0c9823749264a129d6b47a7aabce377",
#'   "8c7304226-6c71-edbe-0b63-c246734b3c01"),
#'   start_date = "2018-01-30",
#'   end_date = "2023-02-04",
#'   key = gfw_auth())
#'  # fishing
#'  get_event(event_type = "FISHING",
#'  vessels = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
#'   start_date = "2017-01-26",
#'   end_date = "2023-02-04",
#'   key = gfw_auth())
#'  # GAPS
#'  get_event(event_type = "GAP",
#'  vessels = c("e0c9823749264a129d6b47a7aabce377",
#'   "8c7304226-6c71-edbe-0b63-c246734b3c01"),
#'   start_date = "2017-01-26",
#'   end_date = "2023-02-04",
#'   key = gfw_auth())
#'  # loitering
#'  get_event(event_type = "LOITERING",
#'  vessels = c("e0c9823749264a129d6b47a7aabce377",
#'   "8c7304226-6c71-edbe-0b63-c246734b3c01"),
#'   start_date = "2017-01-26",
#'   end_date = "2023-02-04",
#'   key = gfw_auth())
#'  # encounter type
#'  get_event(event_type = "ENCOUNTER",
#'  encounter_types = "CARRIER-FISHING",
#'  start_date = "2020-01-01",
#'  end_date = "2020-01-31",
#'  key = gfw_auth())
#'  # vessel types
#'  get_event(event_type = "ENCOUNTER",
#'  vessel_types = c("CARRIER", "FISHING"),
#'  start_date = "2020-01-01",
#'  end_date = "2020-01-31",
#'  key = gfw_auth())
#' # fishing events in user geojson
#' region <- '"geometry": {"type": "Polygon","coordinates":
#' [[[120.36621093749999,26.725986812271756],[122.36572265625,26.725986812271756],
#' [122.36572265625,28.323724553546015],[120.36621093749999,28.323724553546015],
#' [120.36621093749999,26.725986812271756]]]}'
#' get_event(event_type = 'FISHING',
#'               start_date = "2017-01-01",
#'               end_date = "2017-01-31",
#'               region = region,
#'               region_source = 'USER_JSON',
#'               flags = 'CHN',
#'               key = gfw_auth())
#' # fishing events in Senegal EEZ
#'get_event(event_type = 'FISHING',
#'               start_date = "2020-10-01",
#'               end_date = "2020-12-31",
#'               region = 8371,
#'               region_source = 'EEZ',
#'               flags = 'CHN',
#'               key = gfw_auth())
#' # port visits in user region by ATG vessels
#'region = '"geometry":{"type": "Polygon","coordinates":
#'[[[30.552978515625,46.255846818480315],[31.22314453125,46.255846818480315],
#'[31.22314453125,46.59661864884465],[30.552978515625,46.59661864884465],
#'[30.552978515625,46.255846818480315]]]}'
#'get_event(event_type = 'PORT_VISIT',
#'          vessels = "e0248aed9-99b4-bae7-6b87-ff0a3c464676",
#'          start_date = "2017-01-01",
#'          end_date = "2017-01-31",
#'          region = region,
#'          region_source = 'USER_JSON',
#'          flags = 'ATG',
#'          duration = 60)
#' # loitering events in user region by KOR vessels
#'region = '"geometry": {"type": "Polygon","coordinates":
#'[[[43.835981972515576,-6.785011952437713],[43.83602857589722,-6.785011952437713],
#'[43.83602857589722,-6.784984652340707],[43.835981972515576,-6.784984652340707],
#'[43.835981972515576,-6.785011952437713]]]}'
#'get_event(event_type = 'LOITERING',
#'                           vessels = "82be6f228-8ce4-26d1-bf81-3b7979d0c72f",
#'                           start_date = "2017-01-01",
#'                           end_date = "2017-01-31",
#'                           region = region,
#'                           region_source = 'USER_JSON',
#'                           flags = 'KOR',
#'                           duration = 60)
#' # encounter events in user region by TWN vessels
#'region = '"geometry": {"type": "Polygon","coordinates":
#'[[[-130.9735107421875,-17.691128657307427],[-130.4901123046875,-17.691128657307427],
#'[-130.4901123046875,-17.209017141391765],[-130.9735107421875,-17.209017141391765],
#'[-130.9735107421875,-17.691128657307427]]]}'
#'get_event(event_type = 'ENCOUNTER',
#'          vessels = "55d38c0ee-e0d7-cb32-ac9c-8b3680d213b3",
#'          start_date = "2017-01-01",
#'          end_date = "2017-01-31",
#'          region = region,
#'          region_source = 'USER_JSON',
#'          flags = 'TWN',
#'          duration = 60)
#'get_event(event_type = 'GAP',
#'          start_date = "2017-01-01",
#'          end_date = "2017-01-31",
#'          flags = 'TWN',
#'          gap_intentional_disabling = TRUE)
#' @export

get_event <- function(event_type,
                      encounter_types = NULL,
                      vessels = NULL,
                      flags = NULL,
                      vessel_types = NULL,
                      start_date = "2012-01-01",
                      end_date = "2024-12-31",
                      region = NULL,
                      region_source = NULL,
                      gap_intentional_disabling = NULL,
                      duration = 1,
                      confidences = c(2, 3, 4),
                      limit = 99999,
                      offset = 0,
                      sort = "+start",
                      key = gfw_auth(),
                      quiet = FALSE,
                      print_request = FALSE,
                      ...) {
  # API endpoint specific parameters from ...
  args <- list(...)
  for (i in seq_len(length(args))) {
    assign(names(args[i]), args[[i]])
  }
  url_args <- c(limit = limit,
                offset = offset,
                sort = sort
            )

  body_args <- c(args)
  duration <- c('duration' = duration)
  #dates
  if (!is.null(start_date)) {
    start <- c("startDate" = start_date)
    #body_args <- c(body_args, start)
  }
  if (!is.null(end_date)) {
    end <- c('endDate' = end_date)
    #body_args <- c(body_args, end)
  }
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
  # encounter_types
  if (!is.null(encounter_types)) {
    encounter_types <- list("encounterTypes" = encounter_types)
    body_args <- c(body_args, encounter_types)
  }
  # vessel_types
  if (!is.null(vessel_types)) {
    vessel_types <- list('vesselTypes' = vessel_types)
    body_args <- c(body_args, vessel_types)
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
  # gap_intentional_disabling
  if (!is.null(gap_intentional_disabling)) {
    gap_intentional_disabling <-
      list("gapIntentionalDisabling" = gap_intentional_disabling)
    body_args <- c(body_args, gap_intentional_disabling)
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
    } else if (region_source == 'USER_JSON' & is.character(region)) {
       region
    } else {
      stop('region source and region format do not match')
    }
  }

  if (is.null(region_source)) {

      body_args <- jsonlite::toJSON(c(body_args,
                                      list(startDate = jsonlite::unbox(start)),
                                      list(endDate = jsonlite::unbox(end))
      ))
  } else if (region_source == 'USER_JSON') {

      body_args <- jsonlite::toJSON(c(body_args,
                                    list(startDate = jsonlite::unbox(start)), # removes from array
                                    list(endDate = jsonlite::unbox(end))
                                    ))
      # user json is just concatenated onto other body arguments
      body_args <- gsub('}$', '', body_args)
      body_args <- paste0(body_args,',', region,'}')

  } else {

      body_args <- jsonlite::toJSON(c(body_args,
                                      jsonlite::fromJSON(region),
                                      list(startDate = jsonlite::unbox(start)),
                                      list(endDate = jsonlite::unbox(end))
                                      ))
  }

  endpoint <- base %>%
    httr2::req_url_path_append('events') %>%
    httr2::req_url_query(!!!url_args) %>%
    httr2::req_body_raw(., body = body_args)
  if (print_request) print(endpoint)

  # API call; will paginate if necessary, otherwise return list with one response
  all_results <- gfw_api_request(endpoint, key)
  # Extract all entries from list of responses
  all_entries <- purrr::map(all_results, purrr::pluck, 'entries') %>%
    purrr::flatten(.)
  #
  # Process results if they exist
  if (length(all_entries) > 0) {
    #
    #     # Convert list to dataframe
    df_out <- tibble::tibble(
      start = purrr::map_chr(all_entries, 'start'),
      end = purrr::map_chr(all_entries, 'end'),
      id = purrr::map_chr(all_entries, 'id'),
      type = purrr::map_chr(all_entries, 'type'),
      lat = purrr::map_dbl(all_entries, purrr::pluck, 'position','lat'),
      lon = purrr::map_dbl(all_entries, purrr::pluck, 'position','lon'),
      regions = purrr::map(all_entries, purrr::pluck, 'regions'),
      eez = purrr::map(all_entries, 'eez'),
      rfmo = purrr::map(all_entries, 'rfmo'),
      fao = purrr::map(all_entries, 'fao'),
      boundingBox = purrr::map(all_entries, 'boundingBox'),
      distances = purrr::map(all_entries, 'distances'),
      vessel = purrr::map(all_entries, 'vessel'),
      event_info = purrr::map(all_entries, length(all_entries[[1]])) # the event_info is always the last element
    )

    # Map function to each event to convert to data frame
    event_df <- df_out %>%
      dplyr::mutate(dplyr::across(c(start, end), make_datetime))
    #
    #     # Print out total events
    total <- nrow(event_df)
    if (quiet == FALSE) {
      print(paste("Downloading", total, "events from GFW"))
    }
  } else {
    if (quiet == FALSE) {
      print("Your request returned zero results")
    }
    return()
  }

  # Return results
  return(event_df)
}







#'
#' Base function to get events stats from API and convert response to data frame
#'
#' @param vessels A vector of VesselIDs, obtained via the `get_vessel_info()` function
#' @param event_type Type of event to get data of. A vector with any combination
#' of "ENCOUNTER", "FISHING", "GAP", "LOITERING", "PORT_VISIT"
#' @param encounter_types Filters for types of vessels during the encounter. A
#' vector with any combination of: "CARRIER-FISHING", "FISHING-CARRIER",
#' "FISHING-SUPPORT", "SUPPORT-FISHING"
#' @param start_date Start of date range to search events, in YYYY-MM-DD format and including this date
#' @param end_date End of date range to search events, in YYYY-MM-DD format and excluding this date
#' @param confidences Confidence levels (1-4) of events (port visits only)
#' @param region_source Optional but mandatory if using the argument region.
#' Source of the region. If 'EEZ','MPA', 'RFMO',
#' then the value for the argument region must be the code for that region.
#' If 'USER_JSON', then region has to point to a formatted geojson shapefile.
#' See Details about formatting the geojson.
#' @param region GFW region code (such as an EEZ, MPA or RFMO code) or a
#' formatted geojson shape. See Details about formatting the geojson.
#' @param duration duration, in minutes, of the event, ex. 30
#' @param interval Time series granularity. Must be a string. Possible values: 'HOUR', 'DAY', 'MONTH', 'YEAR'.
#' @param key Authorization token. Can be obtained with gfw_auth() function
#' @param quiet Boolean. Whether to print the number of events returned by the
#' request
#' @param print_request Boolean. Whether to print the request, for debugging
#' purposes. When contacting the GFW team it will be useful to send this string
#' @param vessel_types Optional. A vector of vessel types, any combination of:
#' "FISHING", "CARRIER", "SUPPORT", "PASSENGER", "OTHER_NON_FISHING", "SEISMIC_VESSEL",
#' "BUNKER_OR_TANKER", "CARGO"
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
#' The user-defined geojson has to be surrounded by a geojson tag,
#' that can be created using a simple paste:
#'
#' ```
#' geojson_tagged <- paste0('{"geojson":', your_geojson,'}').
#' ```
#'
#' If you have an __sf__ shapefile, you can also use function [sf_to_geojson()]
#' to obtain the correctly-formatted geojson.
#'
#' @examples
#' library(gfwr)
#'  # stats for encounters involving Russian carriers in given time range
#' get_event_stats(event_type = 'ENCOUNTER',
#' encounter_types = c("CARRIER-FISHING","FISHING-CARRIER"),
#' vessel_types = 'CARRIER',
#' start_date = "2018-01-01",
#' end_date = "2023-01-31",
#' flags = 'RUS',
#' duration = 60,
#' interval = "YEAR",
#' key = gfw_auth())
#'  # port visits stats in a region (Senegal)
#'  get_event_stats(event_type = 'PORT_VISIT',
#' start_date = "2018-01-01",
#' end_date = "2019-01-31",
#' confidences = c('3','4'),
#' region = 8371,
#' region_source = 'EEZ',
#' interval = "YEAR")
#' @export

get_event_stats <- function(event_type,
                      encounter_types = NULL,
                      vessels = NULL,
                      vessel_types = NULL,
                      start_date = "2012-01-01",
                      end_date = "2024-12-31",
                      region_source = NULL,
                      region = NULL,
                      interval = NULL,
                      duration = 1,
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
    } else if (region_source == 'USER_JSON' & is.character(region)) {
      region
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
  } else if (region_source == 'USER_JSON') {

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
    httr2::req_body_raw(body = body_args)
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
      print(paste("Downloading", df_out$numEvents, "events for ", df_out$numVessels, " vessels from ", df_out$numFlags, "flag(s) from GFW"))
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

