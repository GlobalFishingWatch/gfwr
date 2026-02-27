# Get events from API and convert response to tibble

Get events from API and convert response to tibble

## Usage

``` r
gfw_event(
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
  confidences = c(2, 3, 4),
  key = gfw_auth(),
  quiet = FALSE,
  print_request = FALSE,
  gap_intentional_disabling = deprecated(),
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

- sort:

  How to sort the events. By default, `+start`, which sorts the events
  in ascending order (+) of the start dates of the events. Other
  possible values are `-start`, `+end`, `-end`.

- vessels:

  A vector of `vesselIds`, obtained via
  [`gfw_vessel_info()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_vessel_info.md).
  The maximum number of `vesselIds` depends on the character length of
  the whole request, the request will fail with error
  `HTTP 422: Unprocessable entity` when too many `vesselIds` are sent.
  This value is around 2,800 vessels, depending on the other parameters
  of the request.

- flags:

  ISO3 code for the flag of the vessels. NULL by default.

- vessel_types:

  A vector of vessel types, any combination of: `"FISHING"`,
  `"CARRIER"`, `"SUPPORT"`, `"PASSENGER"`, `"OTHER_NON_FISHING"`,
  `"SEISMIC_VESSEL"`, `"BUNKER_OR_TANKER"`, `"CARGO"`.

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

  Minimum duration that the event should have (in minutes). The default
  value is 1.

- encounter_types:

  Only useful when `event_type = "ENCOUNTER"`. Filters for types of
  vessels during the encounter. A vector with any combination of:
  `"CARRIER-FISHING"`, `"FISHING-CARRIER"`, `"FISHING-SUPPORT"`,
  `"SUPPORT-FISHING"`.

- confidences:

  Only useful when `event_type = "PORT_VISIT"`. Confidence levels of
  port visits. Possible values: 2, 3, or 4. Low-confidence port visits
  (confidence 1) are not available for download. See the [API
  documentation](https://globalfishingwatch.org/our-apis/documentation#confidence-levels-of-a-port-visit)
  for more details

- key:

  Character, API token. Defaults to
  [`gfw_auth()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_auth.md).

- quiet:

  Boolean. Whether to print the number of events returned by the request

- print_request:

  Boolean. Whether to print the request, for debugging purposes. When
  contacting the GFW team it will be useful to send this string

- gap_intentional_disabling:

  Deprecated. The APIs will return only high confidence gaps (Defaults =
  TRUE).

- ...:

  Other arguments

## Details

Fishing events (`event_type = "FISHING"`) are specific to fishing
vessels and loitering events (`event_type = "LOITERING"`) are specific
to carrier vessels. Port visits (`event_type = "PORT_VISIT"`) and
encounters (`event_type = "ENCOUNTER"`) are available for all vessel
types. For more details about the various event types, see the [GFW API
documentation](https://globalfishingwatch.org/our-apis/documentation#data-caveat).

Encounter events involve multiple vessels and one row is returned for
each vessel involved in an encounter. For example, an encounter between
a carrier and fishing vessel (`CARRIER-FISHING`) will have one row for
the fishing vessel and one for the carrier vessel. The `id` field for
encounter events has two components separated by a `.`. The first
component is the unique id for the encounter event and will be the same
for all vessels involved in the encounter. The second component is an
integer used to distinguish between different vessels in the encounter.

## Examples

``` r
if (FALSE) { # \dontrun{
library(gfwr)
# port visits
gfw_event(event_type = "PORT_VISIT",
          vessels = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
          start_date = "2017-01-26",
          end_date = "2017-12-31",
          confidence = c(3, 4), # only for port visits
          key = gfw_auth())
 #encounters
 gfw_event(event_type = "ENCOUNTER",
 vessels = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
  start_date = "2012-01-30",
  end_date = "2024-02-04",
  key = gfw_auth())
 # fishing
 gfw_event(event_type = "FISHING",
 vessels = c("9b3e9019d-d67f-005a-9593-b66b997559e5"),
  start_date = "2017-01-26",
  end_date = "2023-02-04",
  key = gfw_auth())
 # GAPS
 gfw_event(event_type = "GAP",
 vessels = c("e0c9823749264a129d6b47a7aabce377",
  "8c7304226-6c71-edbe-0b63-c246734b3c01"),
  start_date = "2017-01-26",
  end_date = "2023-02-04",
  key = gfw_auth())
 # loitering
 gfw_event(event_type = "LOITERING",
 vessels = c("e0c9823749264a129d6b47a7aabce377",
  "8c7304226-6c71-edbe-0b63-c246734b3c01"),
  start_date = "2017-01-26",
  end_date = "2023-02-04",
  key = gfw_auth())
 # encounter type
 gfw_event(event_type = "ENCOUNTER",
 encounter_types = "CARRIER-FISHING",
 start_date = "2020-01-01",
 end_date = "2020-01-31",
 key = gfw_auth())

 # vessel types
 gfw_event(event_type = "ENCOUNTER",
 vessel_types = c("CARRIER", "FISHING"),
 start_date = "2020-01-01",
 end_date = "2020-01-31",
 key = gfw_auth())

# encounter events in Senegal EEZ
gfw_event(event_type = 'ENCOUNTER',
              start_date = "2020-10-01",
              end_date = "2020-12-31",
              region = 8371,
              region_source = 'EEZ',
              key = gfw_auth())

# Encounter events in user shapefile from a bounding box
test_polygon <- sf::st_bbox(c(xmin = -50, xmax = -20, ymin = -10, ymax = -30),
 crs = 4326) |>
 sf::st_as_sfc() |>
 sf::st_as_sf()
gfw_event(event_type = 'ENCOUNTER',
          start_date = "2023-01-01",
          end_date = "2023-06-01",
          region = test_polygon,
          region_source = 'USER_SHAPEFILE',
          key = gfw_auth())
} # }
```
