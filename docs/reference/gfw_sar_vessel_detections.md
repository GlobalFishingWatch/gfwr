# Retrieve vessel presence detected using SAR and convert response to tibble

Retrieve vessel presence detected using SAR and convert response to
tibble

## Usage

``` r
gfw_sar_vessel_detections(
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

  Fields to filter SAR vessel detections. See Details for possible
  options.

- key:

  Character, API token. Defaults to
  [`gfw_auth()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_auth.md).

- print_request:

  Boolean. Whether to print the request, for debugging purposes. When
  contacting the GFW team it will be useful to send this string.

## Details

Possible filter options are:

- `matched` – Whether detection matched with AIS data Example:
  `"matched='true'"` or `"matched='false'"`

- flag – Vessel flag state (when matched with AIS). Example:
  `"flag in ('ESP', 'USA')"`

- `vessel_id` – Vessel identifier (when matched with AIS). See the
  identity vignette for details about Vessel ID.

- `geartype` – Fishing gear type (when matched with AIS) → View
  [supported gear
  types](https://globalfishingwatch.org/our-apis/documentation#gear-types-supported).
  Example: `"geartype in ('tuna_purse_seines', 'driftnets')"`

- `neural_vessel_type` – AI classification based on neural network
  model. Values: \<= 0.1: "Likely non-fishing", \>= 0.9: "Likely
  fishing", 0.1 - 0.9: "Other/Unknown"

- `shiptype` – Vessel type classification (when matched with AIS) → See
  [Vessel
  types](https://globalfishingwatch.org/our-apis/documentation#vessel-types)

## Examples

``` r
if (FALSE) { # \dontrun{
library(gfwr)
# using region codes
code_eez <- gfw_region_id(region = "Chile", region_source = "EEZ")
gfw_sar_vessel_detections(spatial_resolution = "LOW",
           temporal_resolution = "YEARLY",
           group_by = "FLAG",
           start_date = "2021-01-01",
           end_date = "2022-01-01",
           region = code_eez$id,
           region_source = "EEZ",
           key = gfw_auth())
# filter by matched
gfw_sar_vessel_detections(spatial_resolution = "LOW",
                          temporal_resolution = "YEARLY",
                          group_by = "VESSEL_ID",
                          filter_by = "matched = 'true'",
                          start_date = "2021-01-01",
                          end_date = "2022-01-01",
                          region = code_eez$id,
                          region_source = "EEZ",
                          key = gfw_auth())
## Unmatched vessels will have no id information:
gfw_sar_vessel_detections(spatial_resolution = "LOW",
                          temporal_resolution = "YEARLY",
                          group_by = "VESSEL_ID",
                          filter_by = "matched = 'false'",
                          start_date = "2021-01-01",
                          end_date = "2022-01-01",
                          region = code_eez$id,
                          region_source = "EEZ",
                          key = gfw_auth())
# Filter by flag
gfw_sar_vessel_detections(spatial_resolution = "LOW",
                          temporal_resolution = "YEARLY",
                          group_by = "VESSEL_ID",
                          filter_by = "flag IN ('PER', 'ECU')",
                          start_date = "2021-01-01",
                          end_date = "2022-01-01",
                          region = code_eez$id,
                          region_source = "EEZ",
                          key = gfw_auth())
# Filter by vessel ID
gfw_sar_vessel_detections(spatial_resolution = "LOW",
                          temporal_resolution = "YEARLY",
                          filter_by = "vessel_id = '320335fcf-fbe5-54e0-9367-b36ae25b64b5'",
                          start_date = "2021-01-01",
                          end_date = "2022-01-01",
                          region = code_eez$id,
                          region_source = "EEZ",
                          key = gfw_auth())
# Filter by geartype
gfw_sar_vessel_detections(spatial_resolution = "LOW",
                          temporal_resolution = "YEARLY",
                          group_by = "VESSEL_ID",
                          filter_by = "geartype IN ('tuna_purse_seines',
                           'driftnets')",
                          start_date = "2021-01-01",
                          end_date = "2022-01-01",
                          region = code_eez$id,
                          region_source = "EEZ",
                          key = gfw_auth())
# Filter by neural_vessel_type
gfw_sar_vessel_detections(spatial_resolution = "LOW",
                          temporal_resolution = "YEARLY",
                          filter_by = "neural_vessel_type = '0.3'",
                          start_date = "2021-01-01",
                          end_date = "2022-01-01",
                          region = code_eez$id,
                          region_source = "EEZ",
                          key = gfw_auth())
# Filter by shiptype (vessel type)
gfw_sar_vessel_detections(spatial_resolution = "LOW",
                          temporal_resolution = "YEARLY",
                          filter_by = "shiptype = 'CARGO'",
                          start_date = "2021-01-01",
                          end_date = "2022-01-01",
                          region = code_eez$id,
                          region_source = "EEZ",
                          key = gfw_auth())


} # }
```
