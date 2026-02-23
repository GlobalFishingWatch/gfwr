# Retrieve datasets from the 4 wings API

This is the basic internal function to retrieve 4wings datasets. It is
used under the hood by `gfw_ais_` and `gfw_sar_` functions, which are
split because the source data (AIS vs SAR) their documentation and
parameters differ

## Usage

``` r
gfw_4wings(
  api_endpoint = "AIS",
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
```

## Arguments

- api_endpoint:

  API endpoint

- spatial_resolution:

  Raster spatial resolution. Can be `"LOW"` (0.1 degree) or `"HIGH"`
  (0.01 degree).

- temporal_resolution:

  Raster temporal resolution. Can be `"HOURLY"`, `"DAILY"`, `"MONTHLY"`,
  `"YEARLY"`.

- start_date:

  Required. Start of date range to search events, in YYYY-MM-DD format
  and including this date.

- end_date:

  Required. End of date range to search events, in YYYY-MM-DD format and
  excluding this date.

- region_source:

  Required. Source of the region: `"EEZ"`, `"MPA"`, `"RFMO"` or
  `"USER_SHAPEFILE"`.

- region:

  Required. If `region_source` is set to `"EEZ"`, `"MPA"` or `"RFMO"`,
  GFW region code (see
  [`gfw_region_id()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_region_id.md)).
  If `region_source = "USER_SHAPEFILE"`, `sf` shapefile with the area of
  interest.

- group_by:

  Optional. Parameter to group by. Can be `"VESSEL_ID"`, `"FLAG"`,
  `"GEARTYPE"`, `"FLAGANDGEARTYPE"` or `"MMSI"`.

- filter_by:

  Fields to filter, variable depending on data source.

- key:

  Character, API token. Defaults to
  [`gfw_auth()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_auth.md).

- print_request:

  Boolean. Whether to print the request, for debugging purposes. When
  contacting the GFW team it will be useful to send this string.
