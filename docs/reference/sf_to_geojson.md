# Formats an sf shapefile to a formatted geojson

Formats an sf shapefile to a formatted geojson

## Usage

``` r
sf_to_geojson(sf_shape, endpoint = "raster")
```

## Arguments

- sf_shape:

  The sf shapefile to transform

- endpoint:

  The GFW endpoint destination for the geojson ("raster" or "event")

## Value

A correctly-formatted geojson to be used in
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
or
[`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
