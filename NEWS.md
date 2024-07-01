# gfwr 2.0.0

__`gfwr` was updated to work with version 3 of our APIs.__ This results in various breaking changes in 
parameter names and output formats. We aim to list here the major modifications but please also
check [the API documentation](https://globalfishingwatch.org/our-apis/documentation#version-3-api)
and the [migration guide](https://globalfishingwatch.org/our-apis/assets/GFW_API.Migration_Guide_to_v3.pdf)
if anything is new or missing.

## Endpoints

- Same endpoints as in v1.1.0
  + `get_raster()` communicates with the 4Wings API to get fishing effort
  + `get_vessel_info()` communicates with the Vessels API
  + `get_event()` communicates with the Events API
  
- New endpoints: 
  + `get_events_stats()` to get events statistics worldwide or for a specific
  region 
  + `get_last_report()` to check status of last API request to `get_raster()`
  
**Note:** Some [APIs](https://globalfishingwatch.org/our-apis/documentation#version-3-api) were not implemented because they were primarily designed for a frontend application rather than for data download. These APIs are:

* `/v3/4wings/generate-png`
* `/v3/4wings/tile/:type/:z/:x/:y`
* `/v3/4wings/interaction/{z}/{x}/{y}/{cells}`
* `/v3/4wings/bins/:z`

## Major changes and new features

- General
  - Improved documentation in-package, including two vignettes that can be accessed 
  in our website https://globalfishingwatch.github.io/gfwr/ 
  - Functions have a new parameter `print_request` that will print the API request and 
will be useful when requesting support. Please describe the problem, send a simplified 
script and copy the string of the request when [filling an issue](https://github.com/GlobalFishingWatch/gfwr/issues). 
  - The `region` argument for `get_raster()` and` get_event()` now accepts `sf` polygons rather than GeoJSON strings
- `get_vessel_info()`
  + Incorporated non-fishing vessel types to the datasets. A simple search will return 
  vessels of all vessel types ("CARRIER", "SUPPORT", "PASSENGER", "OTHER_NON_FISHING", "SEISMIC_VESSEL", "BUNKER_OR_TANKER", and "CARGO" in addition to "FISHING")
  + `search_type = search` replaces `search type = "basic"` and `"advanced"`. Instead, use parameter `query` for basic search or parameter `where` for advanced search (i.e. when using SQL expressions)
  + Registry information is now available: Parameter `includes` allows the search to include ownership information, public authorizations from public registries, and the criteria for matching with AIS data
- `get_event()`
  + Vessel types supported now include non-fishing vessels: "FISHING", "CARRIER", "SUPPORT", "PASSENGER", "OTHER_NON_FISHING", "SEISMIC_VESSEL", "BUNKER_OR_TANKER", and "CARGO"
  + Event types now include fishing, gaps in AIS transmission, encounters, loitering events and port visits. Fishing events are specific to fishing vessels, loitering events are specific to carrier vessels. Port visits and encounters are available for all vessel types. Parameter `confidence` (1 to 4) allows filtering for high confidence port visits. 
  + All parameters must now be specified using UPPER CASE (ex. `event_type = "FISHING"` instead of `event_type = "fishing"`)
  + A user-defined shapefile can now be sent in the requests, as an `sf` object

- `get_raster()`
  + All parameters must now be specified using UPPER CASE (ex. `spatial_resolution = "LOW"` instead of `spatial_resolution = "low"`)
  + The `region` argument now accepts `sf` polygons rather than a GeoJSON string
  + Parameters `start_date` and `end_date` replace `date_range` for consistency with other functions
  


# gfwr 1.1.0

## New features:

-   In addition to your own JSON region, can now pass EEZ or MPA id to `get_raster()` function to query specific region

-   `get_region_id()` now takes id and returns label. This allows you to get the label for the id values returned by certain endpoints (e.g. `get_event()`)

-   Considerable speed increases in `get_event()` function

## Bug fixes:

-   `get_event()` prints `"Your request returned zero results"` and returns `NULL` when the API response contains no results instead of causing an error.

## Other news:

### Updated documentation

-   `get_raster()`: requires `group_by` and appropriate parameter name is `gearType`

-   Added a `NEWS.md` file to track changes to the package.

# gfwr 1.0.0

-   Initial release of the `gfwr` package. It includes functions to access three GFW APIs - Vessels API, Events API, and Map Visualization (4Wings) API.
