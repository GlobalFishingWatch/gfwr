# Package index

## Vessel identity

- [`gfw_vessel_info()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_vessel_info.md)
  : Base function to get vessel information from API and convert
  response to tibble

## AIS-based vessel presence and apparent fishing hours (formerly apparent fishing effort)

- [`gfw_ais_presence()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_presence.md)
  : Retrieve vessel presence from AIS data and convert response to
  tibble
- [`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
  : Retrieve apparent fishing hours derived from AIS data and convert
  response to tibble
- [`gfw_last_report()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_last_report.md)
  : Base function to get status of last report generated

## Events

AIS-based events: port visits, AIS disabling (‘gaps’), encounter and
loitering events

- [`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
  : Get events from API and convert response to tibble
- [`gfw_event_stats()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event_stats.md)
  : Get events stats from API and convert response to tibble

## SAR-based vessel detections

- [`gfw_sar_vessel_detections()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_sar_vessel_detections.md)
  : Retrieve vessel presence detected using SAR and convert response to
  tibble

## Auxiliary functions

- [`gfw_auth()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_auth.md)
  : Get user API token from .Renviron
- [`gfw_region_id()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_region_id.md)
  : Function to pull region code using region name and viceversa
- [`gfw_regions()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_regions.md)
  : List of available regions in Global Fishing Watch platforms, EEZs,
  MPAs, and RFMOs

## Datasets

- [`gfw_marine_regions`](https://globalfishingwatch.github.io/gfwr/reference/gfw_marine_regions.md)
  :

  Simplified Marine Regions v12 dataset (previously `marine_regions`)

- [`gfw_test_shape`](https://globalfishingwatch.github.io/gfwr/reference/gfw_test_shape.md)
  :

  A sample shapefile (previously `test_shape`)
