# Get events stats from API and convert response to tibble

Get events stats from API and convert response to tibble

## Usage

``` r
gfw_event_stats(
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
```

## Arguments

- event_type:

  Type of event to get data of. A vector with any combination of
  "ENCOUNTER", "FISHING", "GAP", "LOITERING", "PORT_VISIT"

- start_date:

  Start of date range to search events, in YYYY-MM-DD format and
  including this date

- end_date:

  End of date range to search events, in YYYY-MM-DD format and
  **excluding this date**

- interval:

  Time series granularity. Must be a string. Possible values: 'HOUR',
  'DAY', 'MONTH', 'YEAR'.

- vessels:

  A vector of vesselIds, obtained via
  [`gfw_vessel_info()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_vessel_info.md)

- flags:

  ISO3 code for the flag of the vessels. Null by default.

- vessel_types:

  A vector of vessel types, any combination of: `"FISHING"`,
  `"CARRIER"`, `"SUPPORT"`, `"PASSENGER"`, `"OTHER_NON_FISHING"`,
  `"SEISMIC_VESSEL"`, `"BUNKER_OR_TANKER"`, `"CARGO"`

- region_source:

  Optional. Source of the region ('EEZ','MPA', 'RFMO' or
  'USER_SHAPEFILE').

- region:

  Optional but required if a value for `region_source` is specified. If
  `region_source` is set to "EEZ", "MPA" or "RFMO", GFW region code (see
  [`gfw_region_id()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_region_id.md)).
  If `region_source = "USER_SHAPEFILE"`, `sf` shapefile with the area of
  interest.

- duration:

  minimum duration of the event in minutes. The default value is 1.

- encounter_types:

  Only useful when `event_type = "ENCOUNTER"`. Filters for types of
  vessels during the encounter. A vector with any combination of:
  `"CARRIER-FISHING"`, `"FISHING-CARRIER"`, `"FISHING-SUPPORT"`,
  `"SUPPORT-FISHING"`.

- confidences:

  Only useful when event_type = "PORT_VISIT". Confidence levels (2-4) of
  events.

- key:

  Character, API token. Defaults to
  [`gfw_auth()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_auth.md).

- quiet:

  Boolean. Whether to print the number of events returned by the request

- print_request:

  Boolean. Whether to print the request, for debugging purposes. When
  contacting the GFW team it will be useful to send this string

- ...:

  Other arguments

## Details

There are currently four available event types and these events are
provided for three vessel types - fishing, carrier, and support vessels.
Fishing events (`event_type = "FISHING"`) are specific to fishing
vessels and loitering events (`event_type = "LOITERING"`) are specific
to carrier vessels. Port visits (`event_type = "PORT_VISIT"`) and
encounters (`event_type = "ENCOUNTER"`) are available for all vessel
types. For more details about the various event types, see the [GFW API
documentation](https://globalfishingwatch.org/our-apis/documentation#data-caveat).

## Examples

``` r
if (FALSE) { # \dontrun{
library(gfwr)
 # stats for encounters involving Russian carriers in given time range
gfw_event_stats(event_type = 'ENCOUNTER',
encounter_types = c("CARRIER-FISHING","FISHING-CARRIER"),
vessel_types = 'CARRIER',
start_date = "2018-01-01",
end_date = "2023-01-31",
flags = 'RUS',
duration = 60,
interval = "YEAR")
 # port visits stats in a region (Senegal)
 gfw_event_stats(event_type = 'PORT_VISIT',
start_date = "2018-01-01",
end_date = "2019-01-31",
confidences = c('3','4'),
region = 8371,
region_source = 'EEZ',
interval = "YEAR")
} # }
```
