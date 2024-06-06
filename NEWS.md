# gfwr 2.0.0

__gfwr was updated to work with version 3 of our APIs.__ This results in various breaking changes in 
parameter names and output formats. We aim to list here the major modifications but please also
check [the API documentation](https://globalfishingwatch.org/our-apis/documentation#version-3-api)
and the [migration guide](https://drive.google.com/file/d/1xPXhG6tj3132wHvCLu0OwwgKV7NtbuFI/view?usp=drive_link)
if anything is new or missing.

## Endpoints

- Same endpoints as in v1.1.0
  + `get_raster()` communicates with the 4Wings API to get fishing effort
  + `get_vessel_info()` communicates with the Vessels API
  + `get_events()` communicates with the Events API
  
- New endpoints: 
  + `get_events_stats()` to get events statistics worldwide or for a specific
  region
  

## Major changes and new features

- General
  - Improved documentation of parameters in-package
  - Functions have a new parameter `print_request` that will print the API request and 
will be useful when requesting support. Please describe the problem, send a simplified 
script and copy the string of the request when [filling an issue](https://github.com/GlobalFishingWatch/gfwr/issues). 
  - New helper function `sf_to_geojson()` helps format sf objects to be used in `get_raster()` and` get_event()`
- `get_vessel_info()`
  + Incorporated non-fishing vessel types to the datasets. A simple search will return 
  vessels of all vessel types ("CARRIER", "SUPPORT", "PASSENGER", "OTHER_NON_FISHING", "SEISMIC_VESSEL", "BUNKER_OR_TANKER", and "CARGO" in addition to "FISHING")
  + `search_type` used to allow values `basic`, `advanced`, or `id`. Now `basic` and `advanced`
  have been replaced by `search` to be used when the vessel id is not specified in parameter `ids`. 
  In that case, use parameter `query` for basic search or parameter `where` for advanced search 
  (i.e. searches that use SQL expressions)
  + Parameter `includes` allows the search to include ownership information, public authorizations,
  and criteria for matching
- `get_event()`
  + Vessel types supported now include non-fishing vessels: "FISHING", "CARRIER", "SUPPORT", "PASSENGER", "OTHER_NON_FISHING", "SEISMIC_VESSEL", "BUNKER_OR_TANKER", and "CARGO"
  + Event types now include fishing, gaps in AIS transmission, encounters, loitering events and port visits. Fishing events are specific to fishing vessels, loitering events are specific to carrier vessels. Port visits and encounters are available for all vessel types. Parameter `confidence` (1 to 4) allows filtering for high confidence port visits. 
  + All parameters must now be specified using UPPER CASE (ex. `event_type = "FISHING"` instead of `event_type = "fishing"`)
  + A user-defined shapefile can now be sent in the request. The shapefile needs to be formatted as a geojson, surrounded by a tag (`'{"geojson":....}'`) to enter the query. If you have an `sf` shapefile, use function `sf_to_geojson()` to format `sf` objects to the correct format.
  + The polygon can also be written as a geojson text, but needs to be enclosed with the tag. Use `paste0('{"geojson":', geoj,'}')` when defining polygons manually.

- `get_raster()`
  + All parameters must now be specified using UPPER CASE (ex. `spatial_resolution = "LOW"` instead of `spatial_resolution = "low"`)

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
