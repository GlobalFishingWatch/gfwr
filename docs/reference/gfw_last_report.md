# Base function to get status of last report generated

Function to check the status of the last API request sent with
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md).

## Usage

``` r
gfw_last_report(key = gfw_auth())
```

## Arguments

- key:

  Authorization token. Can be obtained with
  [`gfw_auth()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_auth.md)
  function

## Details

The `gfw_last_report()` function will tell you if the APIs are still
processing your request and will download the results if the request has
finished successfully. You will receive an error message if the request
finished but resulted in an error or if it's been \>30 minutes since the
last report was generated using
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md).

For more information, see the
https://globalfishingwatch.org/our-apis/documentation#get-last-report-generated.

## Examples

``` r
if (FALSE) { # \dontrun{
gfw_last_report(key = gfw_auth())
} # }
```
