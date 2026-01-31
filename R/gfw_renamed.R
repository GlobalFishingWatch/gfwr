#' Functions renamed in gfwr 3.0
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Several functions were renamed in gwfr v 3.0 for more descriptive names and a common `gfw_` suffix
#'
#' * `get_raster()`      -> `gfw_ais_fishing_hours()`
#' * `get_vessel_info()` -> `gfw_vessel_info()`
#' * `get_event()`       -> `gfw_event()`
#' * `get_event_stats()` -> `gfw_event_stats()`
#' * `get_regions()`     -> `gfw_regions()`
#' * `get_region_id()`   -> `gfw_region_id()`
#' * `get_last_report()` -> `gfw_last_report()`
#'
#' The two datasets were also renamed
#' * `marine_regions` -> `gfw_marine_regions`
#' * `test_shape` -> `gfw_test_shape`
#'
#'
#' @keywords internal
#' @rdname gfw_renamed
#' @export
get_raster <- function(spatial_resolution = NULL,
                       temporal_resolution = NULL,
                       start_date = "2023-01-01",
                       end_date = "2023-12-31",
                       region_source = NULL,
                       region = NULL,
                       group_by = NULL,
                       filter_by = NULL,
                       key = gfw_auth(),
                       print_request = FALSE) {
  lifecycle::deprecate_warn("3.0", "get_raster()", "gfw_ais_fishing_hours()")
  gfw_ais_fishing_hours(spatial_resolution,
                      temporal_resolution,
                      start_date,
                      end_date,
                      region_source,
                      region,
                      group_by,
                      filter_by,
                      key,
                      print_request)
  }

#' @keywords internal
#' @rdname gfw_renamed
#' @export
get_event <- function(event_type,
                      start_date = "2012-01-01",
                      end_date = "2024-12-31",
                      sort = "+start",
                      vessels = NULL,
                      flags = NULL,
                      vessel_types = NULL,
                      region_source = NULL,
                      region = NULL,
                      duration = 1,
                      encounter_types = NULL,
                      gap_intentional_disabling = deprecated(),
                      confidences = c(2, 3, 4),
                      key = gfw_auth(),
                      quiet = FALSE,
                      print_request = FALSE,
                      ...) {
  lifecycle::deprecate_warn("3.0", "get_event()", "gfw_event()")
  if (lifecycle::is_present(gap_intentional_disabling)) {

    # Signal the deprecation to the user
    lifecycle::deprecate_warn("3.0",
                              "gfwr::gfw_event(gap_intentional_disabling = )",
                              details = "Only intentional gaps are returned, equivalent to `gap_intentional_disabling = TRUE`")

  }
  gfw_event(event_type,
            start_date,
            end_date,
            sort,
            vessels,
            flags,
            vessel_types,
            region_source,
            region,
            duration,
            encounter_types,
            confidences,
            key,
            quiet,
            print_request,
            gap_intentional_disabling,
            ...)
}

#' @keywords internal
#' @rdname gfw_renamed
#' @export
get_event_stats <- function(event_type,
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
  lifecycle::deprecate_warn("3.0", "get_event_stats()", "gfw_event_stats()")
  gfw_event_stats(event_type,
                              start_date,
                              end_date,
                              interval,
                              vessels,
                              flags,
                              vessel_types,
                              region_source,
                              region,
                              duration,
                              encounter_types,
                              confidences,
                              key,
                              quiet,
                              print_request,
                              ...)
  }

#' @keywords internal
#' @rdname gfw_renamed
#' @export
get_region_id <- function(region_name = NULL,
                          region_source = "EEZ",
                          key = gfw_auth()
                          ) {
  lifecycle::deprecate_warn("3.0", "get_region_id()", "gfw_region_id()")
  gfw_region_id(region_name,
                region_source,
                key)
}

#' @keywords internal
#' @rdname gfw_renamed
#' @export
get_regions <- function(region_source = "EEZ",
                        key = gfw_auth()) {
  lifecycle::deprecate_warn("3.0", "get_regions()", "gfw_regions()")
  gfw_regions(region_source, key)
}

#' @keywords internal
#' @rdname gfw_renamed
#' @export
get_vessel_info <- function(query = NULL,
                            where = NULL,
                            search_type = "search",
                            ids = NULL,
                            includes = c("AUTHORIZATIONS",
                                         "OWNERSHIP",
                                         "MATCH_CRITERIA"),
                            match_fields = NULL,
                            registries_info_data = c("ALL"),
                            key = gfw_auth(),
                            quiet = FALSE,
                            print_request = FALSE,
                            ...) {
  lifecycle::deprecate_warn("3.0", "get_vessel_info()", "gfw_vessel_info()")
  gfw_vessel_info(query,
                  where,
                  search_type,
                  ids,
                  includes,
                  match_fields,
                  registries_info_data,
                  key,
                  quiet,
                  print_request,
                  ...)
}

#' @keywords internal
#' @rdname gfw_renamed
#' @export
get_last_report <- function(key = gfw_auth()) {
  lifecycle::deprecate_warn("3.0", "get_last_report()", "gfw_last_report()")
  gfw_last_report(key)
}


#' @keywords internal
#' @rdname gfw_renamed
#' @export
marine_regions <- function() {
  # Warning message:
  # `marine_regions` was deprecated in gfwr 3.0.
  # ℹ Please use `gfw_marine_regions` instead.
}


#' @keywords internal
#' @rdname gfw_renamed
#' @export
test_shape <- function() {
  # Warning message:
  # `test_shape` was deprecated in gfwr 3.0.
  # ℹ Please use `gfw_test_shape` instead.
}


