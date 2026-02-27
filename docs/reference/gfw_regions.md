# List of available regions in Global Fishing Watch platforms, EEZs, MPAs, and RFMOs

List of available regions in Global Fishing Watch platforms, EEZs, MPAs,
and RFMOs

## Usage

``` r
gfw_regions(region_source = "EEZ", key = gfw_auth())
```

## Arguments

- region_source:

  string, source of region data ("EEZ", "MPA", "RFMO')

- key:

  Character, API token. Defaults to
  [`gfw_auth()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_auth.md).

## Value

A dataframe with all region ids and names for specified region type

## See also

[`gfw_region_id()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_region_id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gfw_regions(region_source = "EEZ")
gfw_regions(region_source = "RFMO")
gfw_regions(region_source = "MPA")
} # }
```
