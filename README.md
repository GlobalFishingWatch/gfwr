
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
#> Downloading 200 %
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
#>   index vesselRecord    sourceCode ssvid flag  shipname nShipname callsign imo  
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
#> 1     1 3c99c326d-dd2e-175d-… PURSE_SEINE_S… GFW_VESSEL_LIST                2015
#> 2     1 6632c9eb8-8009-abdb-… PURSE_SEINE_S… GFW_VESSEL_LIST                2019
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
#> Downloading 200 %
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
#>   index vesselRecord    sourceCode ssvid flag  shipname nShipname callsign imo  
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
#> 1     1 FISHING CARGO SERVICES PAN   629009266 <chr [1]>  2024-08-07T10:… 2024-…
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
#> 1     1 9827ea1ea… 6290… GABU RE… GABUREEF… GMB   C5J278   8300…           72392
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
#>   index vesselRecord    sourceCode ssvid flag  shipname nShipname callsign imo  
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
#> 1     1 COLINER RUS   273379740 <chr [1]>  2015-02-27T10:59:43Z 2024-09-30T20:2…
#> 2     1 COLINER CYP   511101495 <chr [1]>  2024-07-04T14:27:04Z 2024-07-24T14:2…
#> 3     1 COLINER CYP   210631000 <chr [1]>  2013-05-15T20:19:43Z 2024-07-04T14:1…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 3 × 5
#>   index dateFrom             dateTo               ssvid     sourceCode
#>   <dbl> <chr>                <chr>                <chr>     <list>    
#> 1     1 2023-01-01T00:00:00Z 2024-09-01T00:00:00Z 210631000 <chr [1]> 
#> 2     1 2020-01-01T00:00:00Z 2024-09-01T00:00:00Z 210631000 <chr [1]> 
#> 3     1 2024-08-09T00:00:00Z 2024-09-01T00:00:00Z 273379740 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 5 × 10
#>   index vesselId              geartypes_name geartypes_source geartypes_yearFrom
#>   <dbl> <chr>                 <chr>          <chr>                         <int>
#> 1     1 8c7304226-6c71-edbe-… CARRIER        GFW_VESSEL_LIST                2013
#> 2     1 3c81a942b-bf0a-f476-… CARRIER        GFW_VESSEL_LIST                2015
#> 3     1 da1cd7e1b-b8d0-539c-… CARRIER        GFW_VESSEL_LIST                2015
#> 4     1 0cb77880e-ee49-2ce4-… CARRIER        GFW_VESSEL_LIST                2012
#> 5     1 0edad163f-f53d-9ddb-… CARRIER        GFW_VESSEL_LIST                2024
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
#> 1                        1
#> 2                        2
#> 3                        5
#> 
#> $registryInfo
#> # A tibble: 8 × 17
#>   index vesselRecord    sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <dbl> <chr>           <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1     1 685862e0626f62… <chr [5]>  5480… PHL   JOHNREY… JOHNREYN… DUQA7    8118…
#> 2     2 b82d02e5c2c11e… <chr [5]>  4417… KOR   ADRIA    ADRIA     DTBY3    8919…
#> 3     2 b82d02e5c2c11e… <chr [4]>  4417… KOR   PREMIER  PREMIER   DTBY3    8919…
#> 4     3 a8d00ce54b37ad… <chr [3]>  2733… RUS   FRIO FO… FRIOFORW… UCRZ     9076…
#> 5     3 a8d00ce54b37ad… <chr [2]>  5111… PLW   FRIO FO… FRIOFORW… T8A4891  9076…
#> 6     3 a8d00ce54b37ad… <chr [6]>  2106… CYP   FRIO FO… FRIOFORW… 5BWC3    9076…
#> 7     3 a8d00ce54b37ad… <chr [2]>  3413… KNA   FRIO FO… FRIOFORW… V4JQ3    9076…
#> 8     3 a8d00ce54b37ad… <chr [2]>  3546… PAN   FRIO AE… FRIOAEGE… 3FGY4    9076…
#> # ℹ 8 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <chr>, lengthM <dbl>, tonnageGt <dbl>,
#> #   vesselInfoReference <chr>, extraFields <list>
#> 
#> $registryOwners
#> # A tibble: 5 × 7
#>   index name                          flag  ssvid     sourceCode dateFrom dateTo
#>   <dbl> <chr>                         <chr> <chr>     <list>     <chr>    <chr> 
#> 1     1 TRANS PACIFIC JOURNEY FISHING PHL   548012100 <chr [3]>  2017-02… 2019-…
#> 2     2 DONGWON INDUSTRIES            KOR   441734000 <chr [2]>  2013-09… 2024-…
#> 3     3 COLINER                       RUS   273379740 <chr [1]>  2015-02… 2024-…
#> 4     3 COLINER                       CYP   511101495 <chr [1]>  2024-07… 2024-…
#> 5     3 COLINER                       CYP   210631000 <chr [1]>  2013-05… 2024-…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 8 × 5
#>   index dateFrom             dateTo               ssvid     sourceCode
#>   <dbl> <chr>                <chr>                <chr>     <list>    
#> 1     1 2012-01-01T00:00:00Z 2017-10-25T00:00:00Z 548012100 <chr [1]> 
#> 2     1 2019-02-10T18:02:49Z 2024-09-01T00:00:00Z 548012100 <chr [1]> 
#> 3     2 2015-10-08T00:00:00Z 2020-07-21T00:00:00Z 441734000 <chr [1]> 
#> 4     2 2012-01-01T00:00:00Z 2013-09-19T00:00:00Z 441734000 <chr [1]> 
#> 5     2 2013-09-20T00:00:00Z 2024-09-01T00:00:00Z 441734000 <chr [1]> 
#> 6     3 2023-01-01T00:00:00Z 2024-09-01T00:00:00Z 210631000 <chr [1]> 
#> 7     3 2020-01-01T00:00:00Z 2024-09-01T00:00:00Z 210631000 <chr [1]> 
#> 8     3 2024-08-09T00:00:00Z 2024-09-01T00:00:00Z 273379740 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 9 × 10
#>   index vesselId              geartypes_name geartypes_source geartypes_yearFrom
#>   <dbl> <chr>                 <chr>          <chr>                         <int>
#> 1     1 71e7da672-2451-17da-… TUNA_PURSE_SE… COMBINATION_OF_…               2017
#> 2     1 55889aefb-bef9-224c-… TUNA_PURSE_SE… COMBINATION_OF_…               2017
#> 3     2 aca119c29-95dd-f5c4-… TUNA_PURSE_SE… COMBINATION_OF_…               2012
#> 4     2 6583c51e3-3626-5638-… TUNA_PURSE_SE… COMBINATION_OF_…               2013
#> 5     3 8c7304226-6c71-edbe-… CARRIER        GFW_VESSEL_LIST                2013
#> 6     3 3c81a942b-bf0a-f476-… CARRIER        GFW_VESSEL_LIST                2015
#> 7     3 da1cd7e1b-b8d0-539c-… CARRIER        GFW_VESSEL_LIST                2015
#> 8     3 0cb77880e-ee49-2ce4-… CARRIER        GFW_VESSEL_LIST                2012
#> 9     3 0edad163f-f53d-9ddb-… CARRIER        GFW_VESSEL_LIST                2024
#> # ℹ 5 more variables: geartypes_yearTo <int>, shiptypes_name <chr>,
#> #   shiptypes_source <chr>, shiptypes_yearFrom <int>, shiptypes_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 3 × 14
#>   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#>   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#> 1     1 71e7da672… 5480… JOHN RE… JOHNREYN… PHL   DUQA-7   8118…          133081
#> 2     2 6583c51e3… 4417… ADRIA    ADRIA     KOR   DTBY3    <NA>           360249
#> 3     3 8c7304226… 2106… FRIO FO… FRIOFORW… CYP   5BWC3    9076…         3369802
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
#>    start               end                 id                type     lat    lon
#>    <dttm>              <dttm>              <chr>             <chr>  <dbl>  <dbl>
#>  1 2019-12-30 11:00:00 2020-01-06 14:00:00 3067e6a37d326355… enco…   9.49  -99.1
#>  2 2019-12-31 16:00:00 2020-01-01 08:50:00 fe5c559756615f02… enco…  -3.44 -147. 
#>  3 2019-12-31 05:50:00 2020-01-01 12:20:00 3832c571fb382478… enco…  21.2   111. 
#>  4 2019-12-31 12:50:00 2020-01-01 09:50:00 c41db71d1ec87886… enco… -17.7   -79.2
#>  5 2019-12-30 11:00:00 2020-01-02 15:20:00 eb99dae4b58c8917… enco…   9.49  -99.1
#>  6 2019-12-27 09:10:00 2020-01-06 14:00:00 8743573abf5c7b44… enco…   9.50  -99.1
#>  7 2019-12-30 11:00:00 2020-01-06 14:00:00 3067e6a37d326355… enco…   9.49  -99.1
#>  8 2019-12-31 17:50:00 2020-01-01 03:00:00 4c547fe1bd001bc7… enco… -17.9   -79.1
#>  9 2019-12-31 17:50:00 2020-01-01 16:10:00 b8e18334905871c4… enco…  68.7    50.3
#> 10 2019-12-31 12:00:00 2020-01-01 13:50:00 c11e0476152439aa… enco… -17.6   -79.3
#> # ℹ 276 more rows
#> # ℹ 10 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_publicAuthorizations <list>, event_info <list>
```

> *Note*: We do not recommend trying too large downloads, such as all
> encounters for all vessels over a long period of time. This will
> possibly return time out (524) errors. Our team is working on a bulk
> download solution for the future.

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
#>    start               end                 id     type    lat   lon regions     
#>    <dttm>              <dttm>              <chr>  <chr> <dbl> <dbl> <list>      
#>  1 2020-10-26 14:08:01 2020-10-26 18:20:07 f3f5f… fish…  3.59 -49.9 <named list>
#>  2 2020-10-30 12:22:15 2020-10-30 13:51:56 8524e… fish…  3.79 -50.1 <named list>
#>  3 2020-10-20 03:23:35 2020-10-20 16:14:26 97790… fish…  4.89 -51.8 <named list>
#>  4 2020-10-17 06:06:57 2020-10-18 20:00:32 8404b… fish…  4.72 -51.5 <named list>
#>  5 2020-10-01 12:09:55 2020-10-02 22:03:36 d8ed3… fish…  4.73 -51.5 <named list>
#>  6 2020-10-21 12:16:04 2020-10-21 21:10:32 7b723… fish…  4.71 -51.5 <named list>
#>  7 2020-10-21 23:23:14 2020-10-22 18:05:07 b4600… fish…  4.69 -51.5 <named list>
#>  8 2020-10-03 21:08:06 2020-10-04 03:31:11 3ce13… fish…  4.75 -51.6 <named list>
#>  9 2020-10-03 05:29:59 2020-10-03 20:13:15 4795f… fish…  4.75 -51.5 <named list>
#> 10 2020-10-01 12:54:31 2020-10-01 21:26:31 083f8… fish…  4.75 -51.6 <named list>
#> # ℹ 49 more rows
#> # ℹ 9 more variables: boundingBox <list>, distances <list>, vesselId <chr>,
#> #   vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
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
#> Downloading 200 %
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
#>    start               end                 id    type    lat    lon regions     
#>    <dttm>              <dttm>              <chr> <chr> <dbl>  <dbl> <list>      
#>  1 2020-04-19 06:16:46 2020-04-21 14:02:19 5ad5… port… 28.1  -15.4  <named list>
#>  2 2021-08-01 12:58:44 2021-08-16 16:00:15 a26f… port…  5.20  -4.02 <named list>
#>  3 2020-06-10 13:51:11 2020-06-13 13:51:28 8f14… port…  5.23  -3.97 <named list>
#>  4 2020-06-25 09:13:36 2020-06-25 20:31:10 2986… port… 16.9  -25.0  <named list>
#>  5 2021-10-17 09:52:51 2021-10-17 16:06:40 d133… port… 14.6  -17.4  <named list>
#>  6 2020-08-11 11:43:45 2020-08-11 19:34:16 c604… port… 14.7  -17.4  <named list>
#>  7 2020-09-26 16:17:55 2020-10-01 18:59:15 80f2… port…  5.20  -4.02 <named list>
#>  8 2020-11-01 14:17:48 2020-11-06 12:25:53 f390… port…  5.20  -4.02 <named list>
#>  9 2021-05-19 22:46:40 2021-06-08 08:54:49 ed0f… port… 14.7  -17.4  <named list>
#> 10 2020-05-05 06:52:54 2020-05-07 14:22:35 729d… port…  5.20  -4.02 <named list>
#> # ℹ 15 more rows
#> # ℹ 8 more variables: boundingBox <list>, distances <list>, vesselId <chr>,
#> #   vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
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
#>    start               end                 id    type    lat    lon regions     
#>    <dttm>              <dttm>              <chr> <chr> <dbl>  <dbl> <list>      
#>  1 2017-03-09 17:19:17 2017-03-15 09:00:37 6e1a… port…  5.23  -4.02 <named list>
#>  2 2016-04-24 07:14:33 2016-04-24 11:54:59 104e… port… 14.6  -17.4  <named list>
#>  3 2019-06-07 09:01:12 2019-06-18 23:23:02 567f… port…  5.23  -4.02 <named list>
#>  4 2021-03-25 06:49:59 2021-03-28 21:20:36 c56c… port…  5.23  -4.02 <named list>
#>  5 2017-10-26 06:18:31 2017-11-28 07:30:05 f6bb… port…  5.21  -4.02 <named list>
#>  6 2020-03-05 13:28:59 2020-03-10 02:26:24 0d84… port…  5.20  -4.02 <named list>
#>  7 2019-08-05 07:57:25 2019-08-07 14:33:40 86ea… port… 14.6  -17.4  <named list>
#>  8 2017-05-08 07:01:08 2017-05-12 14:59:28 fa76… port…  5.29  -4.02 <named list>
#>  9 2015-12-06 11:48:38 2015-12-10 16:19:37 f03f… port…  5.23  -3.97 <named list>
#> 10 2019-09-29 05:40:18 2019-10-02 17:16:39 baa8… port… 14.6  -17.4  <named list>
#> # ℹ 64 more rows
#> # ℹ 8 more variables: boundingBox <list>, distances <list>, vesselId <chr>,
#> #   vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
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

<!--
> **Note**:  
> Because encounter events are events between two vessels, a single event will 
be represented twice in the data, once for each vessel. To capture this 
information and link the related data rows, the `id` field for encounter events 
includes an additional suffix (1 or 2) separated by a period. The `vessel` field
will also contain different information specific to each vessel.
-->

#### Multiple vessel events

As another example, let’s combine the Vessels and Events APIs to get
fishing events for a list of USA-flagged trawlers:

``` r
# Download the list of USA trawlers
usa_trawlers <- get_vessel_info(
  where = "flag='USA' AND geartypes='TRAWLERS'",
  search_type = "search",
  key = key,
  quiet = FALSE #uncomment this if you want an estimate progress of the download
)
#> 4138 total vessels
#> Downloading 2 %Downloading 3 %Downloading 4 %Downloading 6 %Downloading 7 %Downloading 8 %Downloading 9 %Downloading 10 %Downloading 12 %Downloading 13 %Downloading 14 %Downloading 15 %Downloading 16 %Downloading 18 %Downloading 19 %Downloading 20 %Downloading 21 %Downloading 22 %Downloading 24 %Downloading 25 %Downloading 26 %Downloading 27 %Downloading 28 %Downloading 30 %Downloading 31 %Downloading 32 %Downloading 33 %Downloading 34 %Downloading 36 %Downloading 37 %Downloading 38 %Downloading 39 %Downloading 40 %Downloading 42 %Downloading 43 %Downloading 44 %Downloading 45 %Downloading 46 %Downloading 48 %Downloading 49 %Downloading 50 %Downloading 51 %Downloading 53 %Downloading 54 %Downloading 55 %Downloading 56 %Downloading 57 %Downloading 59 %Downloading 60 %Downloading 61 %Downloading 62 %Downloading 63 %Downloading 65 %Downloading 66 %Downloading 67 %Downloading 68 %Downloading 69 %Downloading 71 %Downloading 72 %Downloading 73 %Downloading 74 %Downloading 75 %Downloading 77 %Downloading 78 %Downloading 79 %Downloading 80 %Downloading 81 %Downloading 83 %Downloading 84 %Downloading 85 %Downloading 86 %Downloading 87 %Downloading 89 %Downloading 90 %Downloading 91 %Downloading 92 %Downloading 93 %Downloading 95 %Downloading 96 %Downloading 97 %Downloading 98 %Downloading 100 %Downloading 101 %
```

This list returns 6586 `vesselIds` belonging to 4138 vessels.

``` r
usa_trawlers$selfReportedInfo
#> # A tibble: 6,586 × 14
#>    index vesselId  ssvid shipname nShipname flag  callsign imo   messagesCounter
#>    <dbl> <chr>     <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#>  1     1 c698dfcc… 3677… TREMONT  TREMONT   USA   WDJ5556  <NA>            71116
#>  2     2 64907178… 3662… SUSAN L  SUSANL    USA   WQZ4631  <NA>          1498944
#>  3     3 5e6c03ec… 3682… CAPTAIN… CAPTAINT… USA   WDN3761  <NA>           758116
#>  4     3 045a49e9… 3680… AMG      AMG       USA   WDK2542  <NA>             9964
#>  5     3 161cee78… 3677… ATLANTI… ATLANTIS1 USA   WDI5729  <NA>             3288
#>  6     4 9f555214… 3680… PELICAN  PELICAN   USA   WDJ8253  <NA>           312130
#>  7     4 15cea26f… 3680… PELICAN  PELICAN   USA   <NA>     <NA>              407
#>  8     5 47b94476… 3668… ORION    ORION     USA   <NA>     <NA>            23007
#>  9     6 242fa3fb… 3670… TAUNY A… TAUNYANN  USA   WDC4097  <NA>          2003837
#> 10     7 0dddd2a8… 3673… SHAMROCK SHAMROCK  USA   WDD8722  <NA>             2720
#> # ℹ 6,576 more rows
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

For clarity, we should try to send groups of `vesselIds` that belong to
the same vessels. For this, we should check the `index` column in the
`$selfReportedInfo` dataset.

> *Note*: `get_event()` can receive up to 20 vessel ids at a time

``` r
each_USA_trawler <- usa_trawlers$selfReportedInfo[, c("index", "vesselId")] 
each_USA_trawler %>% filter(index <= 10)# how many vessels correspond to the first ten vessels. It's exactly 20 in this case to we will request those.
#> # A tibble: 17 × 2
#>    index vesselId                             
#>    <dbl> <chr>                                
#>  1     1 c698dfcc5-5c85-9329-b1ac-8b3656ea9233
#>  2     2 64907178b-b02a-f401-afa1-b3a099d7a142
#>  3     3 5e6c03ecd-d774-2d00-6b39-21ab335fca3b
#>  4     3 045a49e97-7d67-6ef7-219c-fd1a270af740
#>  5     3 161cee78f-f568-b97e-cb75-5348a2d811ba
#>  6     4 9f5552145-50ed-92f4-4514-5177b1a6511d
#>  7     4 15cea26f5-57ad-acac-4cbf-b45cefb7ab04
#>  8     5 47b944765-5819-b2ab-8c2e-cfc82bd2e82c
#>  9     6 242fa3fbf-fa03-eb47-5855-f0880b8e7acf
#> 10     7 0dddd2a83-3626-24f1-0fe6-3c4d45bbb409
#> 11     7 695b254f7-7e6c-ff50-dc63-55139d9e0101
#> 12     7 ac994bdab-b59c-9fcc-659e-40179e5dddfb
#> 13     8 bc29946f2-2b0b-9613-054a-cd59327226d9
#> 14     8 8d68317d6-6610-59c4-c99a-ef4cd41acd1a
#> 15     9 1d9aff16a-a1fc-b65a-3bf0-be4a3d7c961c
#> 16    10 4d8477087-7e84-e7e6-1e14-7ce8dca1adec
#> 17    10 a94d3d3f0-0a8b-8c02-e0aa-1b671402b496
ten_usa_trawlers <- each_USA_trawler %>% filter(index <= 10)
```

The first 20 `vesselIds` correspond to 10 vessels according to `index`.

Let’s pass the vector of vessel ids to Events API. Now get the list of
fishing events for these trawlers in January, 2020:

``` r
events <- get_event(event_type = 'FISHING',
                    vessels = ten_usa_trawlers$vesselId,
                    start_date = "2020-01-01", 
                    end_date = "2020-02-01", 
                    key = key)
#> [1] "Downloading 32 events from GFW"
events
#> # A tibble: 32 × 16
#>    start               end                 id     type    lat   lon regions     
#>    <dttm>              <dttm>              <chr>  <chr> <dbl> <dbl> <list>      
#>  1 2020-01-15 02:29:41 2020-01-15 14:44:05 e77d4… fish…  38.0 -73.9 <named list>
#>  2 2020-01-23 11:55:49 2020-01-23 22:03:58 6662c… fish…  38.0 -73.9 <named list>
#>  3 2020-01-22 03:07:24 2020-01-23 03:57:57 7812a… fish…  38.0 -73.9 <named list>
#>  4 2020-01-30 23:49:26 2020-01-31 04:34:08 90c53… fish…  38   -73.9 <named list>
#>  5 2020-01-14 12:21:55 2020-01-14 15:39:38 ab054… fish…  37.5 -74.4 <named list>
#>  6 2020-01-29 01:14:50 2020-01-29 03:37:58 37d74… fish…  38.1 -73.9 <named list>
#>  7 2020-01-15 17:46:45 2020-01-15 21:34:32 b1907… fish…  38.1 -73.9 <named list>
#>  8 2020-01-31 07:05:56 2020-01-31 14:52:07 78e72… fish…  38.0 -73.9 <named list>
#>  9 2020-01-24 14:05:32 2020-01-24 22:02:36 761b7… fish…  38.0 -74.0 <named list>
#> 10 2020-01-10 18:21:53 2020-01-12 03:13:04 67391… fish…  38.0 -73.9 <named list>
#> # ℹ 22 more rows
#> # ℹ 9 more variables: boundingBox <list>, distances <list>, vesselId <chr>,
#> #   vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_publicAuthorizations <list>, event_info <list>
```

The columns starting by `vessel` have the vessel-related information for
each event: `vesselId`, `vessel_name`, `ssvid` (MMSI), `flag`,
`vessel type` and public authorizations.

``` r
events %>% 
  dplyr::select(starts_with("vessel"))
#> # A tibble: 32 × 6
#>    vesselId                     vessel_name vessel_ssvid vessel_flag vessel_type
#>    <chr>                        <chr>       <chr>        <chr>       <chr>      
#>  1 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  2 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  3 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  4 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  5 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  6 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  7 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  8 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  9 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#> 10 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#> # ℹ 22 more rows
#> # ℹ 1 more variable: vessel_publicAuthorizations <list>
```

When no events are available, the `get_event()` function returns
nothing.

``` r
get_event(event_type = 'FISHING',
          vessels = ten_usa_trawlers$vesselId[2],
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

### Examples

You can load a sample shapefile inside `gfwr` to see how
`'USER_SHAPEFILE'` works:

``` r
data("test_shape")

get_raster(
  spatial_resolution = 'LOW',
  temporal_resolution = 'YEARLY',
  group_by = 'FLAG',
  start_date = '2021-01-01',
  end_date = '2021-02-01',
  region = test_shape,
  region_source = 'USER_SHAPEFILE',
  key = key
  )
#> Rows: 2682 Columns: 6
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): flag
#> dbl (5): Lat, Lon, Time Range, Vessel IDs, Apparent Fishing Hours
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 2,682 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  16.8  60.6         2021 CHN              1                     6.1 
#>  2  16.7  60.6         2021 CHN              1                    10.1 
#>  3  16.7  60.7         2021 CHN              1                     3.46
#>  4  17.2  61.5         2021 CHN              1                     2.96
#>  5  16.6  61.7         2021 CHN              1                     5.88
#>  6  16.7  61.7         2021 CHN              1                     5.44
#>  7  16.6  61.6         2021 CHN              1                    16.6 
#>  8  17    62.4         2021 CHN              1                     1.64
#>  9  16.9  62.4         2021 CHN              1                     6.38
#> 10  16.9  62.3         2021 CHN              1                     7.85
#> # ℹ 2,672 more rows
```

If you want raster data from a particular EEZ, you can use the
`get_region_id()` function to get the EEZ id, and enter that code in the
`region` argument of `get_raster()` instead of the region shapefile
(ensuring you specify the `region_source` as `'EEZ'`:

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
#> Rows: 596 Columns: 6
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): flag
#> dbl (5): Lat, Lon, Time Range, Vessel IDs, Apparent Fishing Hours
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 596 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1   5.2  -4           2021 BES              3                    17.9 
#>  2   3.2  -5.8         2021 BLZ              1                     3.47
#>  3   3.3  -5.8         2021 BLZ              1                     5.19
#>  4   3.9  -4.6         2021 BLZ              1                     2.7 
#>  5   2.3  -6.5         2021 BLZ              1                     2.25
#>  6   4.6  -4           2021 BLZ              1                     2.31
#>  7   2    -6           2021 BLZ              1                     4.52
#>  8   4.6  -3.9         2021 BLZ              3                     6.66
#>  9   3.9  -3.6         2021 BLZ              1                     1.03
#> 10   1.2  -6.7         2021 BLZ              1                     1.41
#> # ℹ 586 more rows
```

You could search for just one word in the name of the EEZ and then
decide which one you want:

``` r
(get_region_id(region_name = 'France', region_source = 'EEZ', key = key))
#> # A tibble: 3 × 3
#>      id label                            iso3 
#>   <dbl> <chr>                            <chr>
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
#> Rows: 5433 Columns: 6
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): flag
#> dbl (5): Lat, Lon, Time Range, Vessel IDs, Apparent Fishing Hours
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 5,433 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  50.9   1.3         2021 BEL              1                     8.77
#>  2  50.8   1.4         2021 FRA             27                  1881.  
#>  3  51.4   2.1         2021 FRA             14                   142.  
#>  4  51.3   2           2021 FRA             13                    62.4 
#>  5  51.3   2           2021 NLD             15                    77.6 
#>  6  51.2   2.1         2021 NLD             20                   122.  
#>  7  51.2   2           2021 FRA             22                   470.  
#>  8  51.2   2           2021 BEL              2                    27.0 
#>  9  51.5   2.1         2021 NLD             18                   205.  
#> 10  51.5   2.3         2021 FRA             10                    49.5 
#> # ℹ 5,423 more rows
```

A similar approach can be used to search for a specific Marine Protected
Area, in this case the Phoenix Island Protected Area (PIPA)

``` r
# use region id function to get MPA code of Phoenix Island Protected Area
code_mpa <- get_region_id(region_name = 'Phoenix', region_source = 'MPA', key = key)

get_raster(spatial_resolution = 'LOW',
           temporal_resolution = 'YEARLY',
           group_by = 'FLAG',
           start_date = "2015-01-01",
           end_date = "2015-06-01",
           region = code_mpa$id[1],
           region_source = 'MPA',
           key = key)
#> Rows: 38 Columns: 6
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): flag
#> dbl (5): Lat, Lon, Time Range, Vessel IDs, Apparent Fishing Hours
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 38 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  -2.9 -176.         2015 FSM              1                     5.09
#>  2  -3   -176.         2015 FSM              1                     2.16
#>  3  -1.3 -171.         2015 KOR              1                     0.08
#>  4  -1.7 -172.         2015 KOR              1                     0.98
#>  5  -3.9 -176.         2015 KOR              2                     5.21
#>  6  -4.1 -176.         2015 KOR              1                     1.57
#>  7  -3.9 -173.         2015 KOR              1                     0.01
#>  8  -2.9 -176.         2015 KOR              2                    10.8 
#>  9  -3.1 -176.         2015 KOR              3                    11.5 
#> 10  -2.8 -176.         2015 KOR              2                    18.4 
#> # ℹ 28 more rows
```

It is also possible to filter rasters to one of the five regional
fisheries management organizations (RFMO) that manage tuna and tuna-like
species. These include `"ICCAT"`, `"IATTC"`,`"IOTC"`, `"CCSBT"` and
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
#> Rows: 16709 Columns: 6
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr  (1): flag
#> dbl  (4): Lat, Lon, Vessel IDs, Apparent Fishing Hours
#> date (1): Time Range
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 16,709 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl> <date>       <chr>        <dbl>                    <dbl>
#>  1  69.4 -58.5 2021-01-01   GRL              1                     4.03
#>  2  69.4 -58.4 2021-01-01   GRL              1                     1.26
#>  3  69.3 -58.4 2021-01-01   GRL              1                     3.21
#>  4  69.1 -58.5 2021-01-01   GRL              1                     1.24
#>  5  69.1 -58.4 2021-01-01   GRL              1                     1.05
#>  6  69   -58.5 2021-01-01   GRL              2                     5.71
#>  7  69   -58.4 2021-01-01   GRL              1                     0.71
#>  8  67.8 -56.6 2021-01-03   GRL              2                     1.78
#>  9  67.7 -56.6 2021-01-02   GRL              3                    39.6 
#> 10  67.8 -56.6 2021-01-02   GRL              1                     1.25
#> # ℹ 16,699 more rows
```

The `get_region_id()` function also works in reverse. If a region id is
passed as a `numeric` to the function as the `region_name`, the
corresponding region label or iso3 code can be returned. This is
especially useful when events are returned with regions.

``` r
# using same example as above
get_event(event_type = 'FISHING',
          vessels = ten_usa_trawlers$vesselId,
          start_date = "2020-01-01",
          end_date = "2020-02-01",
          key = key
          ) %>% 
  # extract EEZ id code
  dplyr::mutate(eez = as.character(purrr::map(purrr::map(regions, purrr::pluck, 'eez'),
                                              paste0, collapse = ','))) %>%
  dplyr::select(id, type, start, end, lat, lon, eez) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(eez_name = get_region_id(region_name = as.numeric(eez),
                                         region_source = 'EEZ',
                                         key = key)$label) %>% 
  dplyr::select(-start, -end)
#> [1] "Downloading 32 events from GFW"
#> # A tibble: 32 × 6
#> # Rowwise: 
#>    id                               type      lat   lon eez   eez_name     
#>    <chr>                            <chr>   <dbl> <dbl> <chr> <chr>        
#>  1 e77d4c67e09568bf6d21806a8b685527 fishing  38.0 -73.9 8456  United States
#>  2 6662cc521a4c81f9943f6f006b939770 fishing  38.0 -73.9 8456  United States
#>  3 7812ab3b7950fc01a2e0e1e8fda3710a fishing  38.0 -73.9 8456  United States
#>  4 90c53f1ca75710bdc234d58b8027fc05 fishing  38   -73.9 8456  United States
#>  5 ab0541c79191fa4379ff181db3034191 fishing  37.5 -74.4 8456  United States
#>  6 37d74bd1caa4ac69fc559c19242b45f3 fishing  38.1 -73.9 8456  United States
#>  7 b1907b472756ff68ccdef2b61d964fbd fishing  38.1 -73.9 8456  United States
#>  8 78e72bb10c3e36657d220d5855163865 fishing  38.0 -73.9 8456  United States
#>  9 761b7338d7e8667cbb220f7c2c49af43 fishing  38.0 -74.0 8456  United States
#> 10 6739137b68e5fb477de38226f57892f7 fishing  38.0 -73.9 8456  United States
#> # ℹ 22 more rows
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
