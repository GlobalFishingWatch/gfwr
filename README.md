
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `gfwr`: Access data from Global Fishing Watch APIs <img src="man/figures/gfwr_hex_rgb.png" align="right" width="200px"/>

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/450635054.svg)](https://zenodo.org/badge/latestdoi/450635054)
[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Licence](https://img.shields.io/badge/license-Apache%202-blue)](https://opensource.org/licenses/Apache-2.0)
[![:registry status
badge](https://globalfishingwatch.r-universe.dev/badges/:registry)](https://github.com/r-universe/globalfishingwatch/actions/workflows/sync.yml)
<!-- badges: end -->

> **Important**  
> This version of `gfwr` gives access to Global Fishing Watch API
> [version
> 3](https://globalfishingwatch.org/our-apis/documentation#version-3-api).
> Starting April 30th, 2024, this is the official API version. For
> latest API releases, please check our [API release
> notes](https://globalfishingwatch.org/our-apis/documentation#api-release-notes)

The `gfwr` R package is a simple wrapper for the Global Fishing Watch
(GFW)
[APIs](https://globalfishingwatch.org/our-apis/documentation#introduction).
It provides convenient functions to freely pull GFW data directly into R
in tidy formats.

The package currently works with the following APIs:

- [Vessels
  API](https://globalfishingwatch.org/our-apis/documentation#vessels-api):
  vessel search and identity based on AIS self reported data and public
  registry information
- [Events
  API](https://globalfishingwatch.org/our-apis/documentation#events-api):
  encounters, loitering, port visits, AIS-disabling events and fishing
  events based on AIS data
- [Gridded fishing effort (4Wings
  API)](https://globalfishingwatch.org/our-apis/documentation#map-visualization-4wings-api):
  apparent fishing effort based on AIS data

> **Note**: See the [Terms of
> Use](https://globalfishingwatch.org/our-apis/documentation#reference-data)
> page for GFW APIs for information on our API licenses and rate limits.

## Installation

You can install the most recent version of `gfwr` using:

``` r
# Check/install remotes
if (!require("remotes"))
  install.packages("remotes")

remotes::install_github("GlobalFishingWatch/gfwr")
```

`gfwr` is also in the rOpenSci
[R-universe](https://globalfishingwatch.r-universe.dev/gfwr#), and can
be installed like this:

``` r
install.packages("gfwr", 
                 repos = c("https://globalfishingwatch.r-universe.dev",
                           "https://cran.r-project.org"))
```

Once everything is installed, you can load and use `gfwr` in your
scripts with `library(gfwr)`

``` r
library(gfwr)
```

## Authorization

The use of `gfwr` requires a GFW API token, which users can request from
the [GFW API Portal](https://globalfishingwatch.org/our-apis/tokens).
Save this token to your `.Renviron` file using
`usethis::edit_r_environ()` and adding a variable named `GFW_TOKEN` to
the file (`GFW_TOKEN="PASTE_YOUR_TOKEN_HERE"`). Save the `.Renviron`
file and restart the R session to make the edit effective.

Then use the `gfw_auth()` helper function to inform the key on your
function calls. You can use `gfw_auth()` directly or save the
information to an object in your R workspace every time and pass it to
subsequent `gfwr` functions.

So you can do:

``` r
key <- gfw_auth()
```

or this

``` r
key <- Sys.getenv("GFW_TOKEN")
```

> **Note**: `gfwr` functions are set to use `key = gfw_auth()` by
> default.

## Vessels API

The `get_vessel_info()` function allows you to get vessel identity
details from the [GFW Vessels
API](https://globalfishingwatch.org/our-apis/documentation#introduction-vessels-api).

There are two search types: `search`, and `id`.

- `search` is performed by using parameters `query` for basic searches
  and `where` for advanced searchers using SQL expressions
  - `query` takes a single identifier that can be the MMSI, IMO,
    callsign, or shipname as input and identifies all vessels that
    match.
  - `where` search allows for the use of complex search with logical
    clauses (AND, OR) and fuzzy matching with terms such as LIKE, using
    SQL syntax (see examples in the function)
  - `includes` adds information from public registries. Options are
    “MATCH_CRITERIA”, “OWNERSHIP” and “AUTHORIZATIONS”

### Examples

To get information of a vessel using its MMSI, IMO number, callsign or
name, the search can be done directly using the number or the string.
For example, to look for a vessel with `MMSI = 224224000`:

``` r
get_vessel_info(query = 224224000,
                search_type = "search",
                key = key)
#> 1 total vessels
#> $dataset
#> # A tibble: 1 × 1
#>   dataset                           
#>   <chr>                             
#> 1 public-global-vessel-identity:v3.0
#> 
#> $registryInfoTotalRecords
#> # A tibble: 1 × 1
#>   registryInfoTotalRecords
#>                      <int>
#> 1                        1
#> 
#> $registryInfo
#> # A tibble: 1 × 16
#>   index recordId        sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <dbl> <chr>           <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1     1 e0c9823749264a… <chr [6]>  2242… ESP   AGURTZA… AGURTZAB… EBSJ     8733…
#> # ℹ 7 more variables: transmissionDateFrom <chr>, transmissionDateTo <chr>,
#> #   geartypes <chr>, lengthM <dbl>, tonnageGt <int>, vesselInfoReference <chr>,
#> #   extraFields <list>
#> 
#> $registryOwners
#> # A tibble: 0 × 2
#> # ℹ 2 variables: index <dbl>, <list> <list>
#> 
#> $registryPublicAuthorizations
#> # A tibble: 3 × 5
#>   index dateFrom             dateTo               ssvid     sourceCode
#>   <dbl> <chr>                <chr>                <chr>     <list>    
#> 1     1 2019-01-01T00:00:00Z 2019-10-01T00:00:00Z 224224000 <chr [1]> 
#> 2     1 2012-01-01T00:00:00Z 2019-01-01T00:00:00Z 224224000 <chr [1]> 
#> 3     1 2019-10-15T00:00:00Z 2023-02-01T00:00:00Z 306118000 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 2 × 10
#>   index vesselId              geartypes_name geartypes_source geartypes_yearFrom
#>   <dbl> <chr>                 <chr>          <chr>                         <int>
#> 1     1 6632c9eb8-8009-abdb-… PURSE_SEINE_S… GFW_VESSEL_LIST                2019
#> 2     1 3c99c326d-dd2e-175d-… PURSE_SEINE_S… GFW_VESSEL_LIST                2015
#> # ℹ 5 more variables: geartypes_yearTo <int>, shiptypes_name <chr>,
#> #   shiptypes_source <chr>, shiptypes_yearFrom <int>, shiptypes_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 2 × 14
#>   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#>   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#> 1     1 6632c9eb8… 3061… AGURTZA… AGURTZAB… BES   PJBL     8733…          418581
#> 2     1 3c99c326d… 2242… AGURTZA… AGURTZAB… ESP   EBSJ     8733…          135057
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

To do more specific searches (`imo = '8300949'`), combine different
fields (`imo = '8300949' AND ssvid = '214182732'`) and do fuzzy matching
(`"shipname LIKE '%GABU REEFE%' OR imo = '8300949'"`), use parameter
`where` instead of `query`:

``` r
get_vessel_info(where = "shipname LIKE '%GABU REEFE%' OR imo = '8300949'",
                search_type = "search",
                key = key)
#> 1 total vessels
#> $dataset
#> # A tibble: 1 × 1
#>   dataset                           
#>   <chr>                             
#> 1 public-global-vessel-identity:v3.0
#> 
#> $registryInfoTotalRecords
#> # A tibble: 1 × 1
#>   registryInfoTotalRecords
#>                      <int>
#> 1                        1
#> 
#> $registryInfo
#> # A tibble: 1 × 17
#>   index recordId        sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <dbl> <chr>           <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1     1 b16ca93ea690fc… <chr [2]>  6290… GMB   GABU RE… GABUREEF… C5J278   8300…
#> # ℹ 8 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <chr>, lengthM <dbl>, tonnageGt <int>,
#> #   vesselInfoReference <chr>, extraFields <list>
#> 
#> $registryOwners
#> # A tibble: 4 × 7
#>   index name                   flag  ssvid     sourceCode dateFrom        dateTo
#>   <dbl> <chr>                  <chr> <chr>     <list>     <chr>           <chr> 
#> 1     1 FISHING CARGO SERVICES PAN   629009266 <chr [1]>  2024-08-07T10:… 2025-…
#> 2     1 FISHING CARGO SERVICES PAN   613590000 <chr [1]>  2022-01-24T09:… 2024-…
#> 3     1 FISHING CARGO SERVICES PAN   214182732 <chr [1]>  2019-02-23T11:… 2022-…
#> 4     1 FISHING CARGO SERVICES PAN   616852000 <chr [1]>  2012-01-08T19:… 2019-…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 0 × 2
#> # ℹ 2 variables: index <dbl>, <list> <list>
#> 
#> $combinedSourcesInfo
#> # A tibble: 4 × 10
#>   index vesselId              geartypes_name geartypes_source geartypes_yearFrom
#>   <dbl> <chr>                 <chr>          <chr>                         <int>
#> 1     1 1da8dbc23-3c48-d5ce-… CARRIER        GFW_VESSEL_LIST                2022
#> 2     1 58cf536b1-1fca-dac3-… CARRIER        GFW_VESSEL_LIST                2012
#> 3     1 0b7047cb5-58c8-6e63-… CARRIER        GFW_VESSEL_LIST                2019
#> 4     1 9827ea1ea-a120-f374-… CARRIER        GFW_VESSEL_LIST                2024
#> # ℹ 5 more variables: geartypes_yearTo <int>, shiptypes_name <chr>,
#> #   shiptypes_source <chr>, shiptypes_yearFrom <int>, shiptypes_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 4 × 14
#>   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#>   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#> 1     1 9827ea1ea… 6290… GABU RE… GABUREEF… GMB   C5J278   8300…          322865
#> 2     1 1da8dbc23… 6135… GABU RE… GABUREEF… CMR   TJMC996  8300…          973251
#> 3     1 0b7047cb5… 2141… GABU RE… GABUREEF… MDA   ER2732   8300…          642750
#> 4     1 58cf536b1… 6168… GABU RE… GABUREEF… COM   D6FJ2    8300…          469834
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

- The `id` search allows the user to specify a vector of `vesselId`s

> **Note**: `vesselId` is an internal ID generated by GFW to connect
> data accross APIs and involves a combination of vessel and tracking
> data information. It can be retrieved using `get_vessel_info()` and
> fetching the vector of responses inside `$selfReportedInfo$vesselId`.
> See the [identity
> vignette](https://globalfishingwatch.github.io/gfwr/articles/identity)
> for more information.

To search by `vesselId`, use parameter `ids` and specify
`search_type = "id"`:

``` r
get_vessel_info(ids = "8c7304226-6c71-edbe-0b63-c246734b3c01",
                search_type = "id",
                key = key)
#> 1 total vessels
#> $dataset
#> # A tibble: 1 × 1
#>   dataset                           
#>   <chr>                             
#> 1 public-global-vessel-identity:v3.0
#> 
#> $registryInfoTotalRecords
#> # A tibble: 1 × 1
#>   registryInfoTotalRecords
#>                      <int>
#> 1                        5
#> 
#> $registryInfo
#> # A tibble: 5 × 17
#>   index recordId        sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <dbl> <chr>           <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1     1 a8d00ce54b37ad… <chr [3]>  2733… RUS   FRIO FO… FRIOFORW… UCRZ     9076…
#> 2     1 a8d00ce54b37ad… <chr [2]>  5111… PLW   FRIO FO… FRIOFORW… T8A4891  9076…
#> 3     1 a8d00ce54b37ad… <chr [6]>  2106… CYP   FRIO FO… FRIOFORW… 5BWC3    9076…
#> 4     1 a8d00ce54b37ad… <chr [2]>  3413… KNA   FRIO FO… FRIOFORW… V4JQ3    9076…
#> 5     1 a8d00ce54b37ad… <chr [2]>  3546… PAN   FRIO AE… FRIOAEGE… 3FGY4    9076…
#> # ℹ 8 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <chr>, lengthM <int>, tonnageGt <int>,
#> #   vesselInfoReference <chr>, extraFields <list>
#> 
#> $registryOwners
#> # A tibble: 3 × 7
#>   index name    flag  ssvid     sourceCode dateFrom             dateTo          
#>   <dbl> <chr>   <chr> <chr>     <list>     <chr>                <chr>           
#> 1     1 COLINER RUS   273379740 <chr [1]>  2015-02-27T10:59:43Z 2025-01-31T23:5…
#> 2     1 COLINER CYP   511101495 <chr [1]>  2024-07-04T14:27:04Z 2024-07-24T14:2…
#> 3     1 COLINER CYP   210631000 <chr [1]>  2013-05-15T20:19:43Z 2024-07-04T14:1…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 3 × 5
#>   index dateFrom             dateTo               ssvid     sourceCode
#>   <dbl> <chr>                <chr>                <chr>     <list>    
#> 1     1 2023-01-01T00:00:00Z 2024-12-31T00:00:00Z 210631000 <chr [1]> 
#> 2     1 2020-01-01T00:00:00Z 2024-12-01T00:00:00Z 210631000 <chr [1]> 
#> 3     1 2024-08-09T00:00:00Z 2024-12-01T00:00:00Z 273379740 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 5 × 10
#>   index vesselId              geartypes_name geartypes_source geartypes_yearFrom
#>   <dbl> <chr>                 <chr>          <chr>                         <int>
#> 1     1 da1cd7e1b-b8d0-539c-… CARRIER        GFW_VESSEL_LIST                2015
#> 2     1 3c81a942b-bf0a-f476-… CARRIER        GFW_VESSEL_LIST                2015
#> 3     1 8c7304226-6c71-edbe-… CARRIER        GFW_VESSEL_LIST                2013
#> 4     1 0edad163f-f53d-9ddb-… CARRIER        GFW_VESSEL_LIST                2024
#> 5     1 0cb77880e-ee49-2ce4-… CARRIER        GFW_VESSEL_LIST                2012
#> # ℹ 5 more variables: geartypes_yearTo <int>, shiptypes_name <chr>,
#> #   shiptypes_source <chr>, shiptypes_yearFrom <int>, shiptypes_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 1 × 14
#>   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#>   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#> 1     1 8c7304226… 2106… FRIO FO… FRIOFORW… CYP   5BWC3    9076…         3369802
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

To specify more than one `vesselId`, you can submit a vector:

``` r
get_vessel_info(ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01",
                        "6583c51e3-3626-5638-866a-f47c3bc7ef7c",
                        "71e7da672-2451-17da-b239-857831602eca"),
                search_type = 'id',
                key = key)
#> 3 total vessels
#> $dataset
#> # A tibble: 3 × 1
#>   dataset                           
#>   <chr>                             
#> 1 public-global-vessel-identity:v3.0
#> 2 public-global-vessel-identity:v3.0
#> 3 public-global-vessel-identity:v3.0
#> 
#> $registryInfoTotalRecords
#> # A tibble: 3 × 1
#>   registryInfoTotalRecords
#>                      <int>
#> 1                        2
#> 2                        5
#> 3                        1
#> 
#> $registryInfo
#> # A tibble: 8 × 17
#>   index recordId        sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <dbl> <chr>           <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1     1 b82d02e5c2c11e… <chr [5]>  4417… KOR   ADRIA    ADRIA     DTBY3    8919…
#> 2     1 b82d02e5c2c11e… <chr [4]>  4417… KOR   PREMIER  PREMIER   DTBY3    8919…
#> 3     2 a8d00ce54b37ad… <chr [3]>  2733… RUS   FRIO FO… FRIOFORW… UCRZ     9076…
#> 4     2 a8d00ce54b37ad… <chr [2]>  5111… PLW   FRIO FO… FRIOFORW… T8A4891  9076…
#> 5     2 a8d00ce54b37ad… <chr [6]>  2106… CYP   FRIO FO… FRIOFORW… 5BWC3    9076…
#> 6     2 a8d00ce54b37ad… <chr [2]>  3413… KNA   FRIO FO… FRIOFORW… V4JQ3    9076…
#> 7     2 a8d00ce54b37ad… <chr [2]>  3546… PAN   FRIO AE… FRIOAEGE… 3FGY4    9076…
#> 8     3 685862e0626f62… <chr [5]>  5480… PHL   JOHNREY… JOHNREYN… DUQA7    8118…
#> # ℹ 8 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <chr>, lengthM <dbl>, tonnageGt <dbl>,
#> #   vesselInfoReference <chr>, extraFields <list>
#> 
#> $registryOwners
#> # A tibble: 5 × 7
#>   index name                          flag  ssvid     sourceCode dateFrom dateTo
#>   <dbl> <chr>                         <chr> <chr>     <list>     <chr>    <chr> 
#> 1     1 DONGWON INDUSTRIES            KOR   441734000 <chr [2]>  2013-09… 2024-…
#> 2     2 COLINER                       RUS   273379740 <chr [1]>  2015-02… 2025-…
#> 3     2 COLINER                       CYP   511101495 <chr [1]>  2024-07… 2024-…
#> 4     2 COLINER                       CYP   210631000 <chr [1]>  2013-05… 2024-…
#> 5     3 TRANS PACIFIC JOURNEY FISHING PHL   548012100 <chr [4]>  2017-02… 2019-…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 8 × 5
#>   index dateFrom             dateTo               ssvid     sourceCode
#>   <dbl> <chr>                <chr>                <chr>     <list>    
#> 1     1 2015-10-08T00:00:00Z 2020-07-21T00:00:00Z 441734000 <chr [1]> 
#> 2     1 2012-01-01T00:00:00Z 2013-09-19T00:00:00Z 441734000 <chr [1]> 
#> 3     1 2013-09-20T00:00:00Z 2025-01-01T00:00:00Z 441734000 <chr [1]> 
#> 4     2 2023-01-01T00:00:00Z 2024-12-31T00:00:00Z 210631000 <chr [1]> 
#> 5     2 2020-01-01T00:00:00Z 2024-12-01T00:00:00Z 210631000 <chr [1]> 
#> 6     2 2024-08-09T00:00:00Z 2024-12-01T00:00:00Z 273379740 <chr [1]> 
#> 7     3 2012-01-01T00:00:00Z 2017-10-25T00:00:00Z 548012100 <chr [1]> 
#> 8     3 2019-02-10T18:02:49Z 2025-01-01T00:00:00Z 548012100 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 9 × 10
#>   index vesselId              geartypes_name geartypes_source geartypes_yearFrom
#>   <dbl> <chr>                 <chr>          <chr>                         <int>
#> 1     1 aca119c29-95dd-f5c4-… TUNA_PURSE_SE… COMBINATION_OF_…               2012
#> 2     1 6583c51e3-3626-5638-… TUNA_PURSE_SE… COMBINATION_OF_…               2013
#> 3     2 da1cd7e1b-b8d0-539c-… CARRIER        GFW_VESSEL_LIST                2015
#> 4     2 3c81a942b-bf0a-f476-… CARRIER        GFW_VESSEL_LIST                2015
#> 5     2 8c7304226-6c71-edbe-… CARRIER        GFW_VESSEL_LIST                2013
#> 6     2 0edad163f-f53d-9ddb-… CARRIER        GFW_VESSEL_LIST                2024
#> 7     2 0cb77880e-ee49-2ce4-… CARRIER        GFW_VESSEL_LIST                2012
#> 8     3 55889aefb-bef9-224c-… TUNA_PURSE_SE… COMBINATION_OF_…               2017
#> 9     3 71e7da672-2451-17da-… TUNA_PURSE_SE… COMBINATION_OF_…               2017
#> # ℹ 5 more variables: geartypes_yearTo <int>, shiptypes_name <chr>,
#> #   shiptypes_source <chr>, shiptypes_yearFrom <int>, shiptypes_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 3 × 14
#>   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#>   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#> 1     1 6583c51e3… 4417… ADRIA    ADRIA     KOR   DTBY3    <NA>           360249
#> 2     2 8c7304226… 2106… FRIO FO… FRIOFORW… CYP   5BWC3    9076…         3369802
#> 3     3 71e7da672… 5480… JOHN RE… JOHNREYN… PHL   DUQA-7   8118…          133081
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

This is useful especially because a vessel can have different
`vesselId`s in time.

**Check the function documentation for examples with the other function
arguments and [our dedicated
vignette](https://globalfishingwatch.github.io/gfwr/articles/identity)
for more information about vessel identity markers and the outputs
retrieved.**

## Events API

The `get_event()` function allows you to get data on specific vessel
activities from the [GFW Events
API](https://globalfishingwatch.org/our-apis/documentation#events-api).
Event types include apparent fishing events, potential transshipment
events (two-vessel encounters and loitering by refrigerated carrier
vessels), port visits, and AIS-disabling events (“gaps”). Find more
information about events in our [caveat
documentation](https://globalfishingwatch.org/our-apis/documentation#data-caveat).

### Events in a given time range

You can get events in a given date range. By not specifying `vessels`,
the response will return results for all vessels.

``` r
get_event(event_type = 'ENCOUNTER',
          start_date = "2020-01-01",
          end_date = "2020-01-02",
          key = key
          )
#> [1] "Downloading 286 events from GFW"
#> # A tibble: 286 × 16
#>    start               end                 eventId       eventType    lat    lon
#>    <dttm>              <dttm>              <chr>         <chr>      <dbl>  <dbl>
#>  1 2019-12-31 17:50:00 2020-01-01 16:10:00 b8e183349058… encounter  68.7    50.3
#>  2 2019-12-30 11:00:00 2020-01-06 14:00:00 3067e6a37d32… encounter   9.49  -99.1
#>  3 2019-12-31 12:50:00 2020-01-01 09:50:00 c41db71d1ec8… encounter -17.7   -79.2
#>  4 2019-12-31 16:00:00 2020-01-01 08:50:00 fe5c55975661… encounter  -3.44 -147. 
#>  5 2019-12-31 12:00:00 2020-01-01 23:20:00 9d99a5cad40f… encounter  44.5   136. 
#>  6 2019-12-31 12:00:00 2020-01-01 13:50:00 c11e04761524… encounter -17.6   -79.3
#>  7 2019-12-31 05:50:00 2020-01-01 12:20:00 3832c571fb38… encounter  21.2   111. 
#>  8 2019-12-31 12:50:00 2020-01-01 09:50:00 c41db71d1ec8… encounter -17.7   -79.2
#>  9 2019-12-30 11:00:00 2020-01-02 15:20:00 eb99dae4b58c… encounter   9.49  -99.1
#> 10 2019-12-17 14:10:00 2020-01-02 04:10:00 2cacbbe4a0ca… encounter  67.5    15.5
#> # ℹ 276 more rows
#> # ℹ 10 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_publicAuthorizations <list>, event_info <list>
```

> *Note*: We do not recommend trying too large downloads, such as all
> encounters for all vessels over a long period of time. This will
> possibly return time out (524) errors. Our API team is working on
> another API specific for large downloads in the future.

### Events in a specific area

You can provide a polygon in `sf` format or the region code (such as an
EEZ code) to filter the raster. Check the function documentation for
more information about parameters `region` and `region_source`

``` r
 # fishing events in user shapefile
test_polygon <- sf::st_bbox(c(xmin = -70, xmax = -40, ymin = -10, ymax = 5),
  crs = 4326) |>
  sf::st_as_sfc() |>
  sf::st_as_sf()
get_event(event_type = 'FISHING',
               start_date = "2020-10-01",
               end_date = "2020-10-31",
               region = test_polygon,
               region_source = 'USER_SHAPEFILE',
               key = gfw_auth())
#> [1] "Downloading 59 events from GFW"
#> # A tibble: 59 × 16
#>    start               end                 eventId        eventType    lat   lon
#>    <dttm>              <dttm>              <chr>          <chr>      <dbl> <dbl>
#>  1 2020-10-03 05:50:14 2020-10-05 03:35:27 b68b49e7e3655… fishing    4.73  -51.5
#>  2 2020-10-30 12:22:15 2020-10-30 13:51:56 8524e3c9d9c25… fishing    3.79  -50.1
#>  3 2020-10-20 03:23:35 2020-10-20 16:14:26 97790a3a15dc5… fishing    4.89  -51.8
#>  4 2020-10-05 08:50:27 2020-10-06 17:35:21 c75671db2488b… fishing    4.71  -51.5
#>  5 2020-10-01 23:29:31 2020-10-03 03:11:17 4d538f3b37e2a… fishing    4.74  -51.5
#>  6 2020-10-18 00:18:32 2020-10-18 04:04:43 2fd3ab7d16550… fishing    0.449 -47.8
#>  7 2020-10-01 12:54:31 2020-10-01 21:26:31 083f87bff8592… fishing    4.75  -51.6
#>  8 2020-10-19 17:59:09 2020-10-19 19:04:28 991beb5e30978… fishing    0.541 -47.8
#>  9 2020-10-03 11:58:33 2020-10-03 19:30:08 92a28d8935c1c… fishing   -0.107 -47.7
#> 10 2020-10-20 00:10:59 2020-10-20 02:19:22 8f97786330d49… fishing    0.286 -47.9
#> # ℹ 49 more rows
#> # ℹ 10 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_publicAuthorizations <list>, event_info <list>
```

### Events for specific vessels

To extract events for specific vessels, the Events API needs `vesselId`
as input, so you always need to use `get_vessel_info()` first to extract
`vesselId` from `$selfReportedInfo` in the response.

#### Single vessel events

``` r
vessel_info <- get_vessel_info(query = 224224000, key = key)
#> 1 total vessels
vessel_info$selfReportedInfo
#> # A tibble: 2 × 14
#>   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#>   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#> 1     1 6632c9eb8… 3061… AGURTZA… AGURTZAB… BES   PJBL     8733…          418581
#> 2     1 3c99c326d… 2242… AGURTZA… AGURTZAB… ESP   EBSJ     8733…          135057
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

The results show this vessel’s story is grouped in two `vesselIds`.

To get a list of port visits for that vessel, you can use a single
`vesselId` of your interest:

``` r
id <- vessel_info$selfReportedInfo$vesselId
id
#> [1] "6632c9eb8-8009-abdb-baf9-b67d65f20510"
#> [2] "3c99c326d-dd2e-175d-626f-a3c488a4342b"

get_event(event_type = 'PORT_VISIT',
          vessels = id[1],
          confidences = 4,
          key = key
          )
#> [1] "Downloading 25 events from GFW"
#> # A tibble: 25 × 15
#>    start               end                 eventId        eventType   lat    lon
#>    <dttm>              <dttm>              <chr>          <chr>     <dbl>  <dbl>
#>  1 2020-12-14 09:46:52 2020-12-22 16:54:09 9205a53a7b91d… port_vis…  5.20  -4.04
#>  2 2020-02-23 12:44:03 2020-02-24 10:35:02 672bc20417b3c… port_vis… 16.9  -25.0 
#>  3 2020-04-19 06:16:46 2020-04-21 14:02:19 5ad5c93c5448d… port_vis… 28.1  -15.4 
#>  4 2020-07-06 06:45:06 2020-07-12 09:13:39 6845cffacfe25… port_vis…  5.20  -4.02
#>  5 2020-05-05 06:52:54 2020-05-07 14:22:35 729df630342f0… port_vis…  5.20  -4.02
#>  6 2020-01-27 08:04:38 2020-02-23 10:18:02 abed2e0c06e4e… port_vis… 16.9  -25.0 
#>  7 2020-06-10 13:51:11 2020-06-13 13:51:28 8f14e93f2e157… port_vis…  5.23  -3.97
#>  8 2019-11-15 14:15:11 2019-11-19 07:49:20 bbeed3f884a6f… port_vis…  5.20  -4.02
#>  9 2020-11-01 14:17:48 2020-11-06 12:25:53 f39043169c3c4… port_vis…  5.20  -4.02
#> 10 2021-03-25 06:49:59 2021-03-28 21:20:36 c56caaedee80f… port_vis…  5.23  -4.02
#> # ℹ 15 more rows
#> # ℹ 9 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, event_info <list>
```

But to get the whole event history, you can also use the whole vector of
`vesselId` for that vessel:

``` r
get_event(event_type = 'PORT_VISIT',
          vessels = id, #using the whole vector of vesselIds
          confidences = 4,
          key = key
          )
#> [1] "Downloading 74 events from GFW"
#> # A tibble: 74 × 15
#>    start               end                 eventId        eventType   lat    lon
#>    <dttm>              <dttm>              <chr>          <chr>     <dbl>  <dbl>
#>  1 2020-02-23 12:44:03 2020-02-24 10:35:02 672bc20417b3c… port_vis… 16.9  -25.0 
#>  2 2016-08-17 18:17:46 2016-08-20 14:18:44 3a7e8e0630e33… port_vis…  5.26  -4.01
#>  3 2020-06-25 09:13:36 2020-06-25 20:31:10 29863e18bfa98… port_vis… 16.9  -25.0 
#>  4 2020-06-20 12:33:45 2020-06-20 19:43:10 a8f5401a3bbec… port_vis… 14.6  -17.4 
#>  5 2015-12-06 11:48:38 2015-12-10 16:19:37 f03fae29b2df6… port_vis…  5.23  -3.97
#>  6 2020-04-19 06:16:46 2020-04-21 14:02:19 5ad5c93c5448d… port_vis… 28.1  -15.4 
#>  7 2017-07-20 01:24:50 2017-08-17 13:14:35 c3a91322707ba… port_vis…  5.20  -4.02
#>  8 2020-08-19 09:44:55 2020-08-19 18:39:59 724b8c1b2fb6d… port_vis… 16.9  -25.0 
#>  9 2020-08-08 06:40:40 2020-08-10 08:13:39 acd48bf28e6b3… port_vis… 14.6  -17.4 
#> 10 2020-08-11 11:43:45 2020-08-11 19:34:16 c6042c5da685f… port_vis… 14.7  -17.4 
#> # ℹ 64 more rows
#> # ℹ 9 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, event_info <list>
```

> *Note*: Try narrowing your search using `start_date` and `end_date` if
> the request is too large and returns a time out error (524)

When a date range is provided to `get_event()` using both `start_date`
and `end_date`, any event overlapping that range will be returned,
including events that start prior to `start_date` or end after
`end_date`. If just `start_date` or `end_date` are provided, results
will include all events that end after `start_date` or begin prior to
`end_date`, respectively.

> **Note**:  
> Because encounter events are events between two vessels, a single
> event will be represented twice in the data, once for each vessel. To
> capture this information and link the related data rows, the `id`
> field for encounter events includes an additional suffix (1 or 2)
> separated by a period. The `vessel` field will also contain different
> information specific to each vessel.

#### Events for multiple vessels

As another example, let’s combine the Vessels and Events APIs to get
fishing events for a list of USA-flagged trawlers:

``` r
# Download the list of USA trawlers
usa_trawlers <- get_vessel_info(
  where = "flag='USA' AND geartypes='TRAWLERS'",
  search_type = "search",
  key = key,
  quiet = TRUE 
)
  # Set quiet = FALSE if you want an estimate progress of the download
```

This list returns 6444 `vesselIds` belonging to 4164 vessels.

``` r
usa_trawlers$selfReportedInfo
#> # A tibble: 6,444 × 14
#>    index vesselId  ssvid shipname nShipname flag  callsign imo   messagesCounter
#>    <dbl> <chr>     <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#>  1     1 64907178… 3662… SUSAN L  SUSANL    USA   WQZ4631  <NA>          1741753
#>  2     2 c698dfcc… 3677… TREMONT  TREMONT   USA   WDJ5556  <NA>            71116
#>  3     3 9f555214… 3680… PELICAN  PELICAN   USA   WDJ8253  <NA>           319425
#>  4     3 15cea26f… 3680… PELICAN  PELICAN   USA   <NA>     <NA>              407
#>  5     4 47b94476… 3668… ORION    ORION     USA   <NA>     <NA>            23007
#>  6     5 242fa3fb… 3670… TAUNY A… TAUNYANN  USA   WDC4097  <NA>          2177349
#>  7     6 0dddd2a8… 3673… SHAMROCK SHAMROCK  USA   WDD8722  <NA>             2720
#>  8     6 695b254f… 3673… SHAMROCK SHAMROCK  USA   <NA>     <NA>              477
#>  9     6 ac994bda… 3673… <NA>     <NA>      USA   WDD8722  <NA>             3179
#> 10     7 bc29946f… 3667… ALEX     ALEX      USA   WDA2216  <NA>           839744
#> # ℹ 6,434 more rows
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

To fetch events for this list of vessels, we will use the `vesselId`
column and send it to the `vessels` parameter in `get_event()` function.

For clarity, we should try to send groups of `vesselIds` that belong to
the same vessels. For this, we can check the `index` column in the
`$selfReportedInfo` dataset.

> *Note*: `get_event()` can receive several `vesselIds` at a time but
> will fail when the character length of the whole request is too long
> (~100,000 characters). This means it will fail with error **HTTP 422:
> Unprocessable entity** when too many `vesselIds` are requested, this
> value can be around 2,800 `vesselIds` depending on the other
> parameters of the search.

For this example, we will send the `vesselIds` corresponding to the
first twenty vessels in the response:

``` r
each_USA_trawler <- usa_trawlers$selfReportedInfo[, c("index", "vesselId")] 
# how many vessels correspond to the first twenty vessels. 
(twenty_usa_trawlers <- each_USA_trawler %>% filter(index <= 20))
#> # A tibble: 47 × 2
#>    index vesselId                             
#>    <dbl> <chr>                                
#>  1     1 64907178b-b02a-f401-afa1-b3a099d7a142
#>  2     2 c698dfcc5-5c85-9329-b1ac-8b3656ea9233
#>  3     3 9f5552145-50ed-92f4-4514-5177b1a6511d
#>  4     3 15cea26f5-57ad-acac-4cbf-b45cefb7ab04
#>  5     4 47b944765-5819-b2ab-8c2e-cfc82bd2e82c
#>  6     5 242fa3fbf-fa03-eb47-5855-f0880b8e7acf
#>  7     6 0dddd2a83-3626-24f1-0fe6-3c4d45bbb409
#>  8     6 695b254f7-7e6c-ff50-dc63-55139d9e0101
#>  9     6 ac994bdab-b59c-9fcc-659e-40179e5dddfb
#> 10     7 bc29946f2-2b0b-9613-054a-cd59327226d9
#> # ℹ 37 more rows
```

There are 47 `vesselIds` corresponding to those 20 vessels.

Let’s pass the vector of `vesselIds` to Events API. Now get the list of
fishing events for these trawlers in January, 2020:

``` r
events <- get_event(event_type = 'FISHING',
                    vessels = twenty_usa_trawlers$vesselId,
                    start_date = "2020-01-01", 
                    end_date = "2020-02-01", 
                    key = key)
#> [1] "Downloading 38 events from GFW"
events
#> # A tibble: 38 × 16
#>    start               end                 eventId        eventType   lat    lon
#>    <dttm>              <dttm>              <chr>          <chr>     <dbl>  <dbl>
#>  1 2020-01-09 21:14:43 2020-01-10 10:16:36 c60e52370d48a… fishing    38.1  -73.8
#>  2 2020-01-28 09:43:34 2020-01-28 22:03:50 7d9519e296041… fishing    38.0  -73.9
#>  3 2020-01-06 07:35:06 2020-01-06 10:20:02 47bbfb7d2f0ee… fishing    45.9 -124. 
#>  4 2020-01-15 23:35:18 2020-01-16 07:05:08 9eeaee52acbcb… fishing    38.0  -73.9
#>  5 2020-01-23 06:40:00 2020-01-23 07:48:45 5d37b7e7f124d… fishing    38.0  -73.9
#>  6 2020-01-14 23:39:33 2020-01-15 01:16:19 a8b50bdbf3713… fishing    37.8  -74.2
#>  7 2020-01-31 15:05:36 2020-01-31 21:32:05 32c27b8be6040… fishing    43.0 -125. 
#>  8 2020-01-23 11:55:49 2020-01-23 22:03:58 6662cc521a4c8… fishing    38.0  -73.9
#>  9 2020-01-10 18:21:53 2020-01-12 03:13:04 6739137b68e5f… fishing    38.0  -73.9
#> 10 2020-01-17 06:46:00 2020-01-17 08:53:00 1789e3addb7fc… fishing    43.7 -124. 
#> # ℹ 28 more rows
#> # ℹ 10 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_publicAuthorizations <list>, event_info <list>
```

The columns starting by `vessel` hold the vessel-related information for
each event: `vesselId`, `vessel_name`, `ssvid` (MMSI), `flag`,
`vessel type` and public authorizations.

``` r
events %>% 
  dplyr::select(starts_with("vessel"))
#> # A tibble: 38 × 6
#>    vesselId                     vessel_name vessel_ssvid vessel_flag vessel_type
#>    <chr>                        <chr>       <chr>        <chr>       <chr>      
#>  1 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  2 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  3 0bc8f5c22-27d2-92d9-a979-2a… GRANADA     367156340    USA         fishing    
#>  4 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  5 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  6 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  7 454a28f85-56e4-93cb-efa6-ff… BERNADETTE  366233570    USA         fishing    
#>  8 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  9 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#> 10 8d68317d6-6610-59c4-c99a-ef… ALEX        366788850    USA         fishing    
#> # ℹ 28 more rows
#> # ℹ 1 more variable: vessel_publicAuthorizations <list>
```

When no events are available, the `get_event()` function returns
nothing.

``` r
get_event(event_type = 'FISHING',
          vessels = twenty_usa_trawlers$vesselId[2],
          start_date = "2020-01-01",
          end_date = "2020-01-01",
          key = key
          )
#> [1] "Your request returned zero results"
#> NULL
```

## Fishing effort API

The `get_raster()` function gets a raster from the [4Wings
API](https://globalfishingwatch.org/our-apis/documentation#map-visualization-4wings-api)
and converts the response to a data frame. In order to use it, you
should specify:

- The spatial resolution, which can be `LOW` (0.1 degree) or `HIGH`
  (0.01 degree)
- The temporal resolution, which can be `HOURLY`, `DAILY`, `MONTHLY`,
  `YEARLY` or `ENTIRE`.
- The variable to group by: `FLAG`, `GEARTYPE`, `FLAGANDGEARTYPE`,
  `MMSI` or `VESSEL_ID`
- The date range `note: this must be 366 days or less`
- The region polygon in `sf` format or the region code (such as an EEZ
  code) to filter the raster
- The source for the specified region. Currently, `EEZ`, `MPA`, `RFMO`
  or `USER_SHAPEFILE` (for `sf` shapefiles).

### User-defined shapefile

You can load an sf shapefile with your area of interest and fetch
fishing effort for this area using `region_source = 'USER_SHAPEFILE'`
and `region = [YOUR_SHAPE]`. We added a sample shapefile inside `gfwr`
to show how `'USER_SHAPEFILE'` works:

``` r
data("test_shape")

test_shape
#> Simple feature collection with 1 feature and 0 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 56.74815 ymin: 0 xmax: 70 ymax: 21.79799
#> Geodetic CRS:  WGS 84
#>                         geometry
#> 1 MULTIPOLYGON (((70 15.20471...

get_raster(
  spatial_resolution = 'LOW',
  temporal_resolution = 'YEARLY',
  group_by = 'FLAG',
  start_date = '2021-01-01',
  end_date = '2021-02-01',
  region_source = 'USER_SHAPEFILE',
  region = test_shape,
  key = key
  )
#> # A tibble: 2,618 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  15.2  61.4         2021 CHN              3                    13.3 
#>  2  15.1  60.4         2021 CHN              2                    15.6 
#>  3  15.6  62.7         2021 CHN              2                    35.7 
#>  4  15.7  63.7         2021 CHN              2                    14.6 
#>  5   4.6  65.7         2021 TWN              1                     1.82
#>  6   5.8  67.2         2021 TWN              1                    10.2 
#>  7  15.4  60.6         2021 CHN              1                     7.81
#>  8  12.5  62.2         2021 CHN              1                     6.18
#>  9   6    68.8         2021 <NA>             1                     5.46
#> 10   3.5  65.5         2021 LKA              1                     3.98
#> # ℹ 2,608 more rows
```

### Fishing effort in preloaded EEZ, RFMOs and MPAs

If you want raster data from a particular EEZ, you can use the
`get_region_id()` function to get the EEZ id, and enter that code in the
`region` argument of `get_raster()` instead of the region shapefile
(with `region_source = "EEZ"`):

``` r
# use EEZ function to get EEZ code of Cote d'Ivoire
code_eez <- get_region_id(region_name = 'CIV', region_source = 'EEZ', key = key)

get_raster(spatial_resolution = 'LOW',
           temporal_resolution = 'YEARLY',
           group_by = 'FLAG',
           start_date = "2021-01-01",
           end_date = "2021-10-01",
           region = code_eez$id,
           region_source = 'EEZ',
           key = key)
#> # A tibble: 577 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1   4.5  -3.8         2021 PAN              1                     2.24
#>  2   4.7  -5.8         2021 CHN              1                     3.62
#>  3   1.7  -5.6         2021 BLZ              1                     0.39
#>  4   4    -3.6         2021 BES              1                     2.99
#>  5   3.1  -4           2021 FRA              1                     5.1 
#>  6   5.1  -4.6         2021 CHN              1                     2.24
#>  7   3.9  -3.5         2021 GTM              1                     2.21
#>  8   3.7  -5           2021 BLZ              1                     0.11
#>  9   3.5  -4.7         2021 BLZ              1                     2.75
#> 10   2.1  -6.4         2021 BLZ              1                     3.98
#> # ℹ 567 more rows
```

You could search for just one word in the name of the EEZ and then
decide which one you want:

``` r
(get_region_id(region_name = 'France', region_source = 'EEZ', key = key))
#> # A tibble: 3 × 3
#>      id label                            iso3 
#>   <int> <chr>                            <chr>
#> 1  5677 France                           FRA  
#> 2 48966 Joint regime area Spain / France FRA  
#> 3 48976 Joint regime area Italy / France FRA
```

From the results above, let’s say we’re interested in the French
Exclusive Economic Zone, `5677`

``` r
get_raster(spatial_resolution = 'LOW',
           temporal_resolution = 'YEARLY',
           group_by = 'FLAG',
           start_date = "2021-01-01",
           end_date = "2021-10-01",
           region = 5677,
           region_source = 'EEZ',
           key = key)
#> # A tibble: 5,430 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  47.3  -6.1         2021 FRA             12                   412.  
#>  2  49    -1.7         2021 FRA             19                   225.  
#>  3  45.9  -4.9         2021 FRA              2                     4.31
#>  4  47.4  -3.1         2021 FRA             11                    20.2 
#>  5  45.2  -4.3         2021 IRL              1                     0.95
#>  6  48.4  -6.3         2021 FRA              7                    16.5 
#>  7  46.7  -4.7         2021 ESP             11                    70.8 
#>  8  46.8  -5.6         2021 FRA              1                     1.07
#>  9  45.5  -5           2021 ESP             26                   136.  
#> 10  46.5  -4.6         2021 ESP              3                     4.67
#> # ℹ 5,420 more rows
```

A similar approach can be used to search for a specific Marine Protected
Area, in this case the Phoenix Island Protected Area (PIPA)

``` r
# use region id function to get MPA code of Phoenix Island Protected Area
code_mpa <- get_region_id(region_name = 'Phoenix',
                          region_source = 'MPA',
                          key = key)

get_raster(spatial_resolution = 'LOW',
           temporal_resolution = 'YEARLY',
           group_by = 'FLAG',
           start_date = "2015-01-01",
           end_date = "2015-06-01",
           region = code_mpa$id[1],
           region_source = 'MPA',
           key = key)
#> # A tibble: 38 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  -3.6 -176.         2015 KOR              1                     1.98
#>  2  -1   -170.         2015 KOR              1                     2.39
#>  3  -4.1 -176.         2015 KOR              1                     2.67
#>  4  -2.9 -176.         2015 FSM              1                     2.77
#>  5  -2.6 -176.         2015 KOR              1                    13.9 
#>  6  -2.8 -176.         2015 KOR              1                    10.4 
#>  7  -3   -176.         2015 FSM              1                     2.16
#>  8  -3.5 -176.         2015 KOR              1                     3.11
#>  9  -3.6 -176.         2015 KIR              1                     6.07
#> 10  -2.8 -176.         2015 KOR              2                    18.4 
#> # ℹ 28 more rows
```

It is also possible to filter rasters to regional fisheries management
organizations (RFMO) like `"ICCAT"`, `"IATTC"`, `"IOTC"`, `"CCSBT"` and
`"WCPFC"`.

``` r
get_raster(spatial_resolution = 'LOW',
           temporal_resolution = 'DAILY',
           group_by = 'FLAG',
           start_date = "2021-01-01",
           end_date = "2021-01-04",
           region = 'ICCAT',
           region_source = 'RFMO',
           key = key)
#> # A tibble: 16,424 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl> <date>       <chr>        <dbl>                    <dbl>
#>  1  38.9  26.8 2021-01-02   TUR              2                     3   
#>  2  59     0.1 2021-01-03   GBR              2                    13.9 
#>  3  59.9  25.1 2021-01-03   FIN              2                     3   
#>  4  59.9  -2.8 2021-01-03   GBR              1                     3.32
#>  5  47.6  -3   2021-01-02   FRA              1                     2.41
#>  6  51.4  -8.9 2021-01-02   IRL              1                     0.79
#>  7  58.9  10.6 2021-01-03   SWE              1                     0.58
#>  8  38.7  26.7 2021-01-03   TUR              1                    13.4 
#>  9  15.7 -29.7 2021-01-03   JPN              1                     1.09
#> 10  11.8 -16.8 2021-01-03   KOR              1                     0.88
#> # ℹ 16,414 more rows
```

> *Note*: For a complete list of MPAs, RFMOs and EEZ, check the function
> `get_regions()`

The `get_region_id()` function also works in reverse. If a region id is
passed as a `numeric` to the function as the `region_name`, the
corresponding region label or iso3 code can be returned. This is
especially useful when events are returned with regions.

``` r
# using same example as above
get_event(event_type = 'FISHING',
          vessels = twenty_usa_trawlers$vesselId,
          start_date = "2020-01-01",
          end_date = "2020-02-01",
          key = key
          ) %>% 
  # extract EEZ id code
  dplyr::mutate(eez = as.character(
    purrr::map(purrr::map(regions, purrr::pluck, 'eez'),
               paste0, collapse = ','))) %>%
  dplyr::select(eventId, eventType, start, end, lat, lon, eez) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(eez_name = get_region_id(region_name = as.numeric(eez),
                                         region_source = 'EEZ',
                                         key = key)$label) %>% 
  dplyr::select(-start, -end)
#> [1] "Downloading 38 events from GFW"
#> # A tibble: 38 × 6
#> # Rowwise: 
#>    eventId                          eventType   lat    lon eez   eez_name     
#>    <chr>                            <chr>     <dbl>  <dbl> <chr> <chr>        
#>  1 47bbfb7d2f0ee76f1f6789a163639ec3 fishing    45.9 -124.  8456  United States
#>  2 1789e3addb7fc5c5e4f953c5d71eb032 fishing    43.7 -124.  8456  United States
#>  3 23330ffa0e1bbab43ead8328456c45aa fishing    43.7 -124.  8456  United States
#>  4 9eeaee52acbcb893d1b2f2e80ed4b1b9 fishing    38.0  -73.9 8456  United States
#>  5 5d37b7e7f124d8e80eb3c683cc6bd1b4 fishing    38.0  -73.9 8456  United States
#>  6 a8b50bdbf3713e47b131f203abc7a339 fishing    37.8  -74.2 8456  United States
#>  7 32c27b8be60405dd20d344325b298d04 fishing    43.0 -125.  8456  United States
#>  8 6662cc521a4c81f9943f6f006b939770 fishing    38.0  -73.9 8456  United States
#>  9 6739137b68e5fb477de38226f57892f7 fishing    38.0  -73.9 8456  United States
#> 10 c60e52370d48a741413094daec2d78ca fishing    38.1  -73.8 8456  United States
#> # ℹ 28 more rows
```

### When your API request times out

For API performance reasons, the `get_raster()` function restricts
individual queries to a single year of data. However, even with this
restriction, it is possible for API request to time out before it
completes. When this occurs, the initial `get_raster()` call will return
an HTTP 524 error, and subsequent API requests using any `gfwr` `get_`
function will return an HTTP 429 error until the original request
completes:

> Error in `httr2::req_perform()`: ! HTTP 429 Too Many Requests. • Your
> application token is not currently enabled to perform more than one
> concurrent report. If you need to generate more than one report
> concurrently, contact us at <apis@globalfishingwatch.org>

Although no data was received, the request is still being processed by
the APIs and will become available when it completes. To account for
this, `gfwr` includes the `get_last_report()` function, which lets users
request the results of their last API request with `get_raster()`.

The `get_last_report()` function will tell you if the APIs are still
processing your request and will download the results if the request has
finished successfully. You will receive an error message if the request
finished but resulted in an error or if it’s been \>30 minutes since the
last report was generated using `get_raster()`. For more information,
see the [Get last report generated
endpoint](https://globalfishingwatch.org/our-apis/documentation#get-last-report-generated)
documentation on the GFW API page.

## Contributing

We welcome all contributions to improve the package! Please read our
[Contribution
Guide](https://github.com/GlobalFishingWatch/gfwr/blob/main/Contributing.md)
and reach out!
