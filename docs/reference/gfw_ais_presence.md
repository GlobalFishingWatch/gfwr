# Retrieve vessel presence from AIS data and convert response to tibble

This function communicates with the `public-global-presence` latest
dataset to extract global vessel presence derived from AIS data. The
presence is determined by taking one position per hour per vessel from
the positions transmitted by the vessel's AIS. Unlike the apparent
fishing effort dataset, this includes all vessel types and focuses on
presence rather than fishing classification.

## Usage

``` r
gfw_ais_presence(
  spatial_resolution = NULL,
  temporal_resolution = NULL,
  start_date = NULL,
  end_date = NULL,
  region_source = NULL,
  region = NULL,
  group_by = NULL,
  filter_by = NULL,
  key = gfw_auth(),
  print_request = FALSE
)
```

## Arguments

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
  **excluding this date**.

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

  Fields to filter AIS-based vessel presence. Possible options are
  `flag`, `vessel_type`, `speed`. See Details for more information

- key:

  Character, API token. Defaults to
  [`gfw_auth()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_auth.md).

- print_request:

  Boolean. Whether to print the request, for debugging purposes. When
  contacting the GFW team it will be useful to send this string.

## Details

The `filter_by` parameter accepts `flag`, `vessel_type`, `speed`
options. This parameter accepts SQL expressions like
`filter_by = "flag IN ('ESP')"`, `flag in ('ESP', 'USA')`,
`vessel_type = 'cargo'`. Accepted vessel speed ranges are the following:

- `<2` – Less than 2 knots

- `2-4` – 2 to 4 knots

- `4-6` – 4 to 6 knots

- `6-10` – 6 to 10 knots

- `10-15` – 10 to 15 knots

- `15-25` – 15 to 25 knots

- `>25` – Greater than 25 knots

## References

AIS vessel presence examples in the API documentation
https://globalfishingwatch.org/our-apis/documentation#report-ais-vessel-presence-examples

## Examples

``` r
if (FALSE) { # \dontrun{
library(gfwr)
# using region codes

code_eez <- gfw_region_id(region_name = "CIV", region_source = "EEZ")
gfw_ais_presence(spatial_resolution = "LOW",
           temporal_resolution = "YEARLY",
           group_by = "FLAG",
           start_date = "2021-01-01",
           end_date = "2021-01-10",
           region = code_eez$id,
           region_source = "EEZ",
           key = gfw_auth(),
           print_request = TRUE)

# Grouping by flag

code_mpa <- gfw_region_id(region_name = "Galapagos", region_source = "MPA")
gfw_ais_presence(spatial_resolution = "LOW",
           temporal_resolution = "MONTHLY",
           group_by = "FLAG",
           start_date = "2022-01-01",
           end_date = "2022-02-01",
           region = code_mpa$id[3],
           region_source = "MPA")

# Filter by flag but grouping by VESSEL_ID

code_mpa <- gfw_region_id(region_name = "Galapagos", region_source = "MPA")
gfw_ais_presence(spatial_resolution = "LOW",
           temporal_resolution = "MONTHLY",
           group_by = "VESSEL_ID",
           filter_by = "flag in ('ECU')",
           start_date = "2022-01-01",
           end_date = "2022-02-01",
           region = code_mpa$id[3],
           region_source = "MPA")

code_rfmo <- gfw_region_id(region_name = "GFCM", region_source = "RFMO")
gfw_ais_presence(spatial_resolution = "LOW",
           temporal_resolution = "YEARLY",
           start_date = "2022-01-01",
           end_date = "2023-01-01",
           region = code_rfmo$id[1],
           region_source = "RFMO")

# Using a sf from disk /loading a test sf object
data(test_shape)
gfw_ais_presence(spatial_resolution = "LOW",
            temporal_resolution = "YEARLY",
            start_date = "2021-01-01",
            end_date = "2021-02-01",
            region = test_shape,
            region_source = "USER_SHAPEFILE",
            key = gfw_auth(),
            print_request = TRUE)
} # }
```
