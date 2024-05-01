# gfwr 2.0.0

__gfwr was updated to the version 3 of our API.__ This implies in various breaking changes in 
parameter names and output format. We aim to list here the major modifications but please
check [the API documentation](https://globalfishingwatch.org/our-apis/documentation#version-3-api)
and the [migration guide](https://drive.google.com/file/d/1xPXhG6tj3132wHvCLu0OwwgKV7NtbuFI/view?usp=drive_link)
if anything is new or missing.

## Endpoints

- Same endpoints as in v 1.1.0
  + get_raster() communicates with the 4Wings API to get fishing effort
  + get_vessel_info() communicates with the Vessel API
  + get_events() communicates with Event API
  
- New endpoints: 
+ get_events_stats()
- Future implementations:
  + get_insights() communicates with the new Insights API
  
## New features

- get_vessel_info() 
    + incorporated non-fishing vessels to the datasets
    + `search_type = search` replaces `search type = "basic"` and `"advanced"`. 
    Instead, use parameter `query` for basic search or parameter `where` for advanced 
    search (SQL expressions like `"imo = 'xxxx'"`)
    + 


- Functions have a new parameter `print_request` that will print the API request and 
will be useful when requesting support. Please describe the problem and copy the
string of the request. 



## Bug fixes

## Other news:

### Updated documentation
# gfwr 1.1.0

## New features:

-   In addition to your own JSON region, can now pass EEZ or MPA id to `get_raster` function to query specific region

-   `get_region_id` now takes id and returns label. This allows you to get the label for the id values returned by certain endpoints (e.g. `get_event`)

-   Considerable speed increases in `get_event` function

## Bug fixes:

-   `get_event` prints `"Your request returned zero results"` and returns `NULL` when the API response contains no results instead of causing an error.

## Other news:

### Updated documentation

-   `get_raster`: requires `group_by` and appropriate parameter name is `gearType`

-   Added a `NEWS.md` file to track changes to the package.

# gfwr 1.0.0

-   Initial release of the `gfwr` package. It includes functions to access three GFW APIs - Vessels API, Events API, and Map Visualization (4Wings) API.
