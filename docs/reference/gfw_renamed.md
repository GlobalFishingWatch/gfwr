# Functions renamed in gfwr 3.0

**\[deprecated\]**

Several functions were renamed in gwfr v 3.0 for more descriptive names
and a common `gfw_` suffix

- `get_raster()` -\>
  [`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)

- `get_vessel_info()` -\>
  [`gfw_vessel_info()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_vessel_info.md)

- `get_event()` -\>
  [`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)

- `get_event_stats()` -\>
  [`gfw_event_stats()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event_stats.md)

- `get_regions()` -\>
  [`gfw_regions()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_regions.md)

- `get_region_id()` -\>
  [`gfw_region_id()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_region_id.md)

- `get_last_report()` -\>
  [`gfw_last_report()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_last_report.md)

The two datasets were also renamed

- `marine_regions` -\> `gfw_marine_regions`

- `test_shape` -\> `gfw_test_shape`

## Usage

``` r
get_raster(
  spatial_resolution = NULL,
  temporal_resolution = NULL,
  start_date = "2023-01-01",
  end_date = "2023-12-31",
  region_source = NULL,
  region = NULL,
  group_by = NULL,
  filter_by = NULL,
  key = gfw_auth(),
  print_request = FALSE
)

get_event(
  event_type,
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
  ...
)

get_event_stats(
  event_type,
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
  ...
)

get_region_id(region_name = NULL, region_source = "EEZ", key = gfw_auth())

get_regions(region_source = "EEZ", key = gfw_auth())

get_vessel_info(
  query = NULL,
  where = NULL,
  search_type = "search",
  ids = NULL,
  includes = c("AUTHORIZATIONS", "OWNERSHIP", "MATCH_CRITERIA"),
  match_fields = NULL,
  registries_info_data = c("ALL"),
  key = gfw_auth(),
  quiet = FALSE,
  print_request = FALSE,
  ...
)

get_last_report(key = gfw_auth())

marine_regions()

test_shape()
```
