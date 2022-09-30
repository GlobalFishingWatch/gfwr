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
