# Function to pull region code using region name and viceversa

Function to pull region code using region name and viceversa

## Usage

``` r
gfw_region_id(
  region = NULL,
  region_source = "EEZ",
  key = gfw_auth(),
  region_name = deprecated()
)
```

## Arguments

- region:

  Character or numeric EEZ MPA or RFMO name or id.

- region_source:

  Character, source of region data, `"EEZ"`, `"MPA"` or `"RFMO"`.

- key:

  Character, API token. Defaults to
  [`gfw_auth()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_auth.md).

- region_name:

  Deprecated, replaced by region.

## Value

For `gfw_region_id()`, the corresponding code, region names or iso code
for the EEZ, MPA or RFMO label

## See also

[`gfw_regions()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_regions.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gfw_region_id(region = "COL", region_source = "EEZ")
gfw_region_id(region = "Colombia", region_source = "EEZ")
gfw_region_id(region = "Nazca", region_source = "MPA")
gfw_region_id(region = "IOTC", region_source = "RFMO")
gfw_region_id(region = 8456, region_source = "EEZ")
# Handling empty strings (high-seas)
gfw_region_id(region = "", region_source = "EEZ")
gfw_region_id(region = NA, region_source = "EEZ")
gfw_region_id(region = NA, region_source = "MPA")
} # }
```
