
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

> A **Python package** to communicate with Global Fishing Watch APIs was
> released in April 2025. Check the
> [gfw-api-python-client](https://github.com/GlobalFishingWatch/gfw-api-python-client)
> repository.

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
- [Gridded apparent fishing effort (4Wings
  API)](https://globalfishingwatch.org/our-apis/documentation#map-visualization-4wings-api):
  apparent fishing effort based on AIS data

> **Note**: See the [Terms of
> Use](https://globalfishingwatch.org/our-apis/documentation#reference-data)
> page for Global Fishing Watch APIs for information on our API licenses
> and rate limits.

## Installation

You can install the most recent version of `gfwr` using:

``` r
# Check/install remotes
if (!require("remotes"))
  install.packages("remotes")

remotes::install_github("GlobalFishingWatch/gfwr",
                        dependencies = TRUE)
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

`gfwr` functions are set to use `key = gfw_auth()` by default so in
general you shouldn’t need to refer to the key in your function calls.

If the token configuration was not done properly you will see the
following error:

``` r
Error in `httr2::req_perform()`:
! HTTP 401 Unauthorized.
```

In case you need to specify the key you can use `gfw_auth()` to save an
object

``` r
key <- gfw_auth()
```

or fetch the key directly from the `.Renviron` file

``` r
key <- Sys.getenv("GFW_TOKEN")
```

The examples in the package documentation will omit an explicit call to
key.

## Vessels API

The `get_vessel_info()` function allows you to get vessel identity
details from the [Vessels
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

### Basic search by identity markers `(search_type = "search")`

To get information of a vessel using its MMSI, IMO number, callsign or
name, the search can be done directly using the number or the string.
For example, to look for a vessel with `MMSI = 224224000`:

``` r
get_vessel_info(query = 224224000,
                search_type = "search")
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
#> 1     1 e0c9823749264a… <chr [7]>  2242… ESP   AGURTZA… AGURTZAB… EBSJ     8733…
#> # ℹ 7 more variables: transmissionDateFrom <chr>, transmissionDateTo <chr>,
#> #   geartypes <chr>, lengthM <int>, tonnageGt <dbl>, vesselInfoReference <chr>,
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

### Complex searches using `where`

To do more specific searches (e.g. `"imo = '8300949'"`), combine
different fields (`"imo = '8300949' AND ssvid = '214182732'"`) and do
fuzzy matching (`"shipname LIKE '%GABU REEFE%' OR imo = '8300949'"`),
use parameter `where` instead of `query`:

``` r
get_vessel_info(where = "shipname LIKE '%GABU REEFE%' OR imo = '8300949'",
                search_type = "search")
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
#> 1     1 b16ca93ea690fc… <chr [3]>  6290… GMB   GABU RE… GABUREEF… C5J278   8300…
#> # ℹ 8 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <chr>, lengthM <dbl>, tonnageGt <int>,
#> #   vesselInfoReference <chr>, extraFields <list>
#> 
#> $registryOwners
#> # A tibble: 4 × 7
#>   index name                   flag  ssvid     sourceCode dateFrom        dateTo
#>   <dbl> <chr>                  <chr> <chr>     <list>     <chr>           <chr> 
#> 1     1 FISHING CARGO SERVICES PAN   629009266 <chr [2]>  2024-08-07T10:… 2025-…
#> 2     1 FISHING CARGO SERVICES PAN   613590000 <chr [2]>  2022-01-24T09:… 2024-…
#> 3     1 FISHING CARGO SERVICES PAN   214182732 <chr [2]>  2019-02-23T11:… 2022-…
#> 4     1 FISHING CARGO SERVICES PAN   616852000 <chr [2]>  2012-01-08T19:… 2019-…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 0 × 2
#> # ℹ 2 variables: index <dbl>, <list> <list>
#> 
#> $combinedSourcesInfo
#> # A tibble: 7 × 10
#>   index vesselId              geartypes_name geartypes_source geartypes_yearFrom
#>   <dbl> <chr>                 <chr>          <chr>                         <int>
#> 1     1 1da8dbc23-3c48-d5ce-… CARRIER        GFW_VESSEL_LIST                2022
#> 2     1 58cf536b1-1fca-dac3-… CARRIER        GFW_VESSEL_LIST                2012
#> 3     1 0b7047cb5-58c8-6e63-… CARRIER        GFW_VESSEL_LIST                2019
#> 4     1 9827ea1ea-a120-f374-… CARRIER        GFW_VESSEL_LIST                2024
#> 5     1 9827ea1ea-a120-f374-… CARRIER        GFW_VESSEL_LIST                2024
#> 6     1 9827ea1ea-a120-f374-… CARRIER        GFW_VESSEL_LIST                2025
#> 7     1 9827ea1ea-a120-f374-… CARRIER        GFW_VESSEL_LIST                2025
#> # ℹ 5 more variables: geartypes_yearTo <int>, shiptypes_name <chr>,
#> #   shiptypes_source <chr>, shiptypes_yearFrom <int>, shiptypes_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 4 × 14
#>   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#>   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#> 1     1 9827ea1ea… 6290… GABU RE… GABUREEF… GMB   C5J278   8300…          759956
#> 2     1 1da8dbc23… 6135… GABU RE… GABUREEF… CMR   TJMC996  8300…          973251
#> 3     1 0b7047cb5… 2141… GABU RE… GABUREEF… MDA   ER2732   8300…          642750
#> 4     1 58cf536b1… 6168… GABU RE… GABUREEF… COM   D6FJ2    8300…          469834
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

### Search by vessel ID

To search by `vesselId`, use parameter `ids` and specify
`search_type = "id"`.

> **Note**: `vesselId` is an internal ID generated by Global Fishing
> Watch to connect data accross APIs and involves a combination of
> vessel and tracking data information. It can be retrieved using
> `get_vessel_info()` and fetching the vector of responses inside
> `$selfReportedInfo$vesselId`. See the [identity
> vignette](https://globalfishingwatch.github.io/gfwr/articles/identity)
> for more information.

#### Single vessel IDs

``` r
get_vessel_info(ids = "8c7304226-6c71-edbe-0b63-c246734b3c01",
                search_type = "id")
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
#> 1     1 a8d00ce54b37ad… <chr [4]>  2733… RUS   FRIO FO… FRIOFORW… UCRZ     9076…
#> 2     1 a8d00ce54b37ad… <chr [3]>  5111… PLW   FRIO FO… FRIOFORW… T8A4891  9076…
#> 3     1 a8d00ce54b37ad… <chr [7]>  2106… CYP   FRIO FO… FRIOFORW… 5BWC3    9076…
#> 4     1 a8d00ce54b37ad… <chr [2]>  3413… KNA   FRIO FO… FRIOFORW… V4JQ3    9076…
#> 5     1 a8d00ce54b37ad… <chr [3]>  3546… PAN   FRIOAEG… FRIOAEGE… 3FGY4    9076…
#> # ℹ 8 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <chr>, lengthM <int>, tonnageGt <int>,
#> #   vesselInfoReference <chr>, extraFields <list>
#> 
#> $registryOwners
#> # A tibble: 3 × 7
#>   index name    flag  ssvid     sourceCode dateFrom             dateTo          
#>   <dbl> <chr>   <chr> <chr>     <list>     <chr>                <chr>           
#> 1     1 COLINER RUS   273379740 <chr [2]>  2015-02-27T10:59:43Z 2025-05-31T23:5…
#> 2     1 COLINER CYP   511101495 <chr [1]>  2024-07-04T14:27:04Z 2024-07-24T14:2…
#> 3     1 COLINER CYP   210631000 <chr [1]>  2013-05-15T20:19:43Z 2024-07-04T14:1…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 3 × 5
#>   index dateFrom             dateTo               ssvid     sourceCode
#>   <dbl> <chr>                <chr>                <chr>     <list>    
#> 1     1 2023-01-01T00:00:00Z 2024-12-31T00:00:00Z 210631000 <chr [1]> 
#> 2     1 2020-01-01T00:00:00Z 2024-12-01T00:00:00Z 210631000 <chr [1]> 
#> 3     1 2024-08-09T00:00:00Z 2025-05-01T00:00:00Z 273379740 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 13 × 10
#>    index vesselId             geartypes_name geartypes_source geartypes_yearFrom
#>    <dbl> <chr>                <chr>          <chr>                         <int>
#>  1     1 3c81a942b-bf0a-f476… CARRIER        GFW_VESSEL_LIST                2015
#>  2     1 8c7304226-6c71-edbe… CARRIER        GFW_VESSEL_LIST                2013
#>  3     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2019
#>  4     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2019
#>  5     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2019
#>  6     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2025
#>  7     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2025
#>  8     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2025
#>  9     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2015
#> 10     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2015
#> 11     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2015
#> 12     1 0edad163f-f53d-9ddb… CARRIER        GFW_VESSEL_LIST                2024
#> 13     1 0cb77880e-ee49-2ce4… CARRIER        GFW_VESSEL_LIST                2012
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

#### Multiple vessel IDs

To specify more than one `vesselId`, you can submit a vector:

``` r
get_vessel_info(ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01",
                        "6583c51e3-3626-5638-866a-f47c3bc7ef7c",
                        "71e7da672-2451-17da-b239-857831602eca"),
                search_type = "id")
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
#> 1                        5
#> 2                        2
#> 3                        1
#> 
#> $registryInfo
#> # A tibble: 8 × 17
#>   index recordId        sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <dbl> <chr>           <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1     1 a8d00ce54b37ad… <chr [4]>  2733… RUS   FRIO FO… FRIOFORW… UCRZ     9076…
#> 2     1 a8d00ce54b37ad… <chr [3]>  5111… PLW   FRIO FO… FRIOFORW… T8A4891  9076…
#> 3     1 a8d00ce54b37ad… <chr [7]>  2106… CYP   FRIO FO… FRIOFORW… 5BWC3    9076…
#> 4     1 a8d00ce54b37ad… <chr [2]>  3413… KNA   FRIO FO… FRIOFORW… V4JQ3    9076…
#> 5     1 a8d00ce54b37ad… <chr [3]>  3546… PAN   FRIOAEG… FRIOAEGE… 3FGY4    9076…
#> 6     2 b82d02e5c2c11e… <chr [6]>  4417… KOR   ADRIA    ADRIA     DTBY3    8919…
#> 7     2 b82d02e5c2c11e… <chr [5]>  4417… KOR   PREMIER  PREMIER   DTBY3    8919…
#> 8     3 685862e0626f62… <chr [6]>  5480… PHL   JOHNREY… JOHNREYN… DUQA7    8118…
#> # ℹ 8 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <chr>, lengthM <dbl>, tonnageGt <dbl>,
#> #   vesselInfoReference <chr>, extraFields <list>
#> 
#> $registryOwners
#> # A tibble: 3 × 7
#>   index name    flag  ssvid     sourceCode dateFrom             dateTo          
#>   <dbl> <chr>   <chr> <chr>     <list>     <chr>                <chr>           
#> 1     1 COLINER RUS   273379740 <chr [2]>  2015-02-27T10:59:43Z 2025-05-31T23:5…
#> 2     1 COLINER CYP   511101495 <chr [1]>  2024-07-04T14:27:04Z 2024-07-24T14:2…
#> 3     1 COLINER CYP   210631000 <chr [1]>  2013-05-15T20:19:43Z 2024-07-04T14:1…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 8 × 5
#>   index dateFrom             dateTo               ssvid     sourceCode
#>   <dbl> <chr>                <chr>                <chr>     <list>    
#> 1     1 2023-01-01T00:00:00Z 2024-12-31T00:00:00Z 210631000 <chr [1]> 
#> 2     1 2020-01-01T00:00:00Z 2024-12-01T00:00:00Z 210631000 <chr [1]> 
#> 3     1 2024-08-09T00:00:00Z 2025-05-01T00:00:00Z 273379740 <chr [1]> 
#> 4     2 2015-10-08T00:00:00Z 2020-07-21T00:00:00Z 441734000 <chr [1]> 
#> 5     2 2012-01-01T00:00:00Z 2013-09-19T00:00:00Z 441734000 <chr [1]> 
#> 6     2 2013-09-20T00:00:00Z 2025-01-01T00:00:00Z 441734000 <chr [1]> 
#> 7     3 2012-01-01T00:00:00Z 2017-10-25T00:00:00Z 548012100 <chr [1]> 
#> 8     3 2019-02-10T18:02:49Z 2025-05-01T00:00:00Z 548012100 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 17 × 10
#>    index vesselId             geartypes_name geartypes_source geartypes_yearFrom
#>    <dbl> <chr>                <chr>          <chr>                         <int>
#>  1     1 3c81a942b-bf0a-f476… CARRIER        GFW_VESSEL_LIST                2015
#>  2     1 8c7304226-6c71-edbe… CARRIER        GFW_VESSEL_LIST                2013
#>  3     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2019
#>  4     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2019
#>  5     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2019
#>  6     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2025
#>  7     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2025
#>  8     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2025
#>  9     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2015
#> 10     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2015
#> 11     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2015
#> 12     1 0edad163f-f53d-9ddb… CARRIER        GFW_VESSEL_LIST                2024
#> 13     1 0cb77880e-ee49-2ce4… CARRIER        GFW_VESSEL_LIST                2012
#> 14     2 aca119c29-95dd-f5c4… TUNA_PURSE_SE… COMBINATION_OF_…               2012
#> 15     2 6583c51e3-3626-5638… TUNA_PURSE_SE… COMBINATION_OF_…               2013
#> 16     3 55889aefb-bef9-224c… TUNA_PURSE_SE… COMBINATION_OF_…               2017
#> 17     3 71e7da672-2451-17da… TUNA_PURSE_SE… COMBINATION_OF_…               2017
#> # ℹ 5 more variables: geartypes_yearTo <int>, shiptypes_name <chr>,
#> #   shiptypes_source <chr>, shiptypes_yearFrom <int>, shiptypes_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 3 × 14
#>   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#>   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#> 1     1 8c7304226… 2106… FRIO FO… FRIOFORW… CYP   5BWC3    9076…         3369802
#> 2     2 6583c51e3… 4417… ADRIA    ADRIA     KOR   DTBY3    <NA>           360249
#> 3     3 71e7da672… 5480… JOHN RE… JOHNREYN… PHL   DUQA-7   8118…          133081
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

**Check the function documentation for examples with the other function
arguments and [our dedicated
vignette](https://globalfishingwatch.github.io/gfwr/articles/identity)
for more information about vessel identity markers and the outputs
retrieved.**

## Events API

The `get_event()` function allows you to get data on specific vessel
activities from the [Events
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
get_event(event_type = "ENCOUNTER",
          start_date = "2020-01-01",
          end_date = "2020-01-02")
#> [1] "Downloading 288 events from GFW"
#> # A tibble: 288 × 17
#>    start               end                 eventId        eventType    lat   lon
#>    <dttm>              <dttm>              <chr>          <chr>      <dbl> <dbl>
#>  1 2019-12-30 11:00:00 2020-01-06 14:00:00 3067e6a37d326… encounter   9.49 -99.1
#>  2 2019-12-31 12:00:00 2020-01-01 13:50:00 c11e047615243… encounter -17.6  -79.3
#>  3 2020-01-01 00:00:00 2020-01-01 02:40:00 3b109ab4e8fc4… encounter  34.7  129. 
#>  4 2020-01-01 00:40:00 2020-01-01 08:20:00 3de48259ac99d… encounter  26.6  120. 
#>  5 2020-01-01 17:30:00 2020-01-02 04:30:00 4d721ad85f1cf… encounter  68.7   50.3
#>  6 2020-01-01 00:00:00 2020-01-01 11:20:00 255d53a814907… encounter  44.5  136. 
#>  7 2020-01-01 17:40:00 2020-01-01 23:30:00 24df89e2316c7… encounter  38.3  121. 
#>  8 2020-01-01 14:20:00 2020-01-01 16:30:00 96ccfc41e8c64… encounter   6.18  99.7
#>  9 2020-01-01 13:20:00 2020-01-01 20:50:00 8663bd73cdffd… encounter -45.4  -60.6
#> 10 2020-01-01 18:20:00 2020-01-01 22:20:00 1f565991a7c23… encounter  38.5  121. 
#> # ℹ 278 more rows
#> # ℹ 11 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_publicAuthorizations <list>,
#> #   vessel_nextPort <list>, event_info <list>
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
test_polygon <- sf::st_bbox(c(xmin = -70,
                              xmax = -40,
                              ymin = -10,
                              ymax = 5),
  crs = 4326) |>
  sf::st_as_sfc() |>
  sf::st_as_sf()
get_event(event_type = "FISHING",
               start_date = "2020-10-01",
               end_date = "2020-10-31",
               region = test_polygon,
               region_source = "USER_SHAPEFILE")
#> [1] "Downloading 59 events from GFW"
#> # A tibble: 59 × 17
#>    start               end                 eventId         eventType   lat   lon
#>    <dttm>              <dttm>              <chr>           <chr>     <dbl> <dbl>
#>  1 2020-10-20 03:23:35 2020-10-20 16:14:26 97790a3a15dc5f… fishing   4.89  -51.8
#>  2 2020-10-01 12:54:31 2020-10-01 21:26:31 083f87bff85928… fishing   4.75  -51.6
#>  3 2020-10-01 23:29:31 2020-10-03 03:11:17 4d538f3b37e2ae… fishing   4.74  -51.5
#>  4 2020-10-05 08:50:27 2020-10-06 17:35:21 c75671db2488b8… fishing   4.71  -51.5
#>  5 2020-10-03 05:50:14 2020-10-05 03:35:27 b68b49e7e3655c… fishing   4.73  -51.5
#>  6 2020-10-30 12:22:15 2020-10-30 13:51:56 8524e3c9d9c25f… fishing   3.79  -50.1
#>  7 2020-10-03 21:08:06 2020-10-04 03:31:11 3ce13bbe2752ec… fishing   4.75  -51.6
#>  8 2020-10-17 17:59:45 2020-10-17 19:45:10 b08ba788b149c2… fishing   0.222 -47.7
#>  9 2020-10-24 15:44:03 2020-10-24 18:56:19 fbf1567e527d4d… fishing   0.259 -47.9
#> 10 2020-10-18 21:29:13 2020-10-18 22:28:02 eb82a3cc27a9e0… fishing   4.95  -51.6
#> # ℹ 49 more rows
#> # ℹ 11 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_publicAuthorizations <list>,
#> #   vessel_nextPort <lgl>, event_info <list>
```

### Events for specific vessels

To extract events for specific vessels, the Events API needs `vesselId`
as input, so you always need to use `get_vessel_info()` first to extract
`vesselId` from `$selfReportedInfo` in the response.

#### Single vessel events

``` r
vessel_info <- get_vessel_info(query = 224224000)
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

get_event(event_type = "PORT_VISIT",
          vessels = id[1],
          confidences = 4
          )
#> [1] "Downloading 25 events from GFW"
#> # A tibble: 25 × 16
#>    start               end                 eventId        eventType   lat    lon
#>    <dttm>              <dttm>              <chr>          <chr>     <dbl>  <dbl>
#>  1 2020-01-27 08:04:38 2020-02-23 10:18:02 abed2e0c06e4e… port_vis… 16.9  -25.0 
#>  2 2021-08-01 12:58:44 2021-08-16 16:00:15 a26f4940e189c… port_vis…  5.20  -4.02
#>  3 2020-03-05 13:28:59 2020-03-10 02:26:24 0d845cb306614… port_vis…  5.20  -4.02
#>  4 2020-04-19 06:16:46 2020-04-21 14:02:19 5ad5c93c5448d… port_vis… 28.1  -15.4 
#>  5 2020-11-01 14:17:48 2020-11-06 12:25:53 f39043169c3c4… port_vis…  5.20  -4.02
#>  6 2020-05-05 06:52:54 2020-05-07 14:22:35 729df630342f0… port_vis…  5.20  -4.02
#>  7 2021-10-17 09:52:51 2021-10-17 16:06:40 d133e151d9edd… port_vis… 14.6  -17.4 
#>  8 2021-11-11 18:41:10 2021-11-20 18:43:26 af0cb5d7ee288… port_vis…  5.20  -4.04
#>  9 2020-06-25 09:13:36 2020-06-25 20:31:10 29863e18bfa98… port_vis… 16.9  -25.0 
#> 10 2020-07-06 06:45:06 2020-07-12 09:13:39 6845cffacfe25… port_vis…  5.20  -4.02
#> # ℹ 15 more rows
#> # ℹ 10 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_nextPort <lgl>, event_info <list>
```

But to get the whole event history, it’s better to use the whole vector
of `vesselId` for that vessel. Notice how the following request provides
more results than the previous one:

``` r
get_event(event_type = "PORT_VISIT",
          vessels = id, #using the whole vector of vesselIds
          confidences = 4
          )
#> [1] "Downloading 74 events from GFW"
#> # A tibble: 74 × 16
#>    start               end                 eventId        eventType   lat    lon
#>    <dttm>              <dttm>              <chr>          <chr>     <dbl>  <dbl>
#>  1 2019-09-29 05:40:18 2019-10-02 17:16:39 baa809792afe6… port_vis… 14.6  -17.4 
#>  2 2016-05-18 19:31:04 2016-05-22 14:20:05 8f19c373a1d4b… port_vis…  5.20  -4.02
#>  3 2017-06-11 13:06:41 2017-06-11 20:24:21 37dd9b53c8e95… port_vis… 14.7  -17.4 
#>  4 2017-07-20 01:24:50 2017-08-17 13:14:35 c3a91322707ba… port_vis…  5.20  -4.02
#>  5 2016-02-25 14:26:38 2016-03-01 13:21:21 6265aa07f2c16… port_vis…  5.23  -3.97
#>  6 2016-06-26 15:08:16 2016-06-30 10:39:03 bf64dfbc753b4… port_vis…  5.19  -4.08
#>  7 2019-12-06 11:02:09 2019-12-11 10:20:04 bcd967c59306c… port_vis…  5.20  -4.04
#>  8 2021-08-01 12:58:44 2021-08-16 16:00:15 a26f4940e189c… port_vis…  5.20  -4.02
#>  9 2020-01-11 11:18:49 2020-01-15 11:54:49 889beb4fc4bfb… port_vis…  5.23  -4.02
#> 10 2017-09-26 05:57:58 2017-09-30 09:45:51 bd92902851ea3… port_vis…  5.20  -4.02
#> # ℹ 64 more rows
#> # ℹ 10 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_nextPort <lgl>, event_info <list>
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
  quiet = TRUE 
  )
# Set quiet = TRUE if you want the output to return silently
```

This list returns 6486 `vesselIds` belonging to 4163 vessels.

``` r
usa_trawlers$selfReportedInfo
#> # A tibble: 6,662 × 14
#>    index vesselId  ssvid shipname nShipname flag  callsign imo   messagesCounter
#>    <dbl> <chr>     <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#>  1     1 d32af732… 3680… SUPERMA… SUPERMAN… USA   WDJ8890  <NA>           267397
#>  2     1 5446e7cd… 3680… SUPERMA… SUPERMAN… USA   <NA>     <NA>             6184
#>  3     2 47b94476… 3668… ORION    ORION     USA   <NA>     <NA>            23007
#>  4     3 9f555214… 3680… PELICAN  PELICAN   USA   WDJ8253  <NA>           401525
#>  5     3 15cea26f… 3680… PELICAN  PELICAN   USA   <NA>     <NA>              407
#>  6     4 0dddd2a8… 3673… SHAMROCK SHAMROCK  USA   WDD8722  <NA>             2720
#>  7     4 695b254f… 3673… SHAMROCK SHAMROCK  USA   <NA>     <NA>              477
#>  8     4 ac994bda… 3673… <NA>     <NA>      USA   WDD8722  <NA>             3179
#>  9     5 bc29946f… 3667… ALEX     ALEX      USA   WDA2216  <NA>           840772
#> 10     5 0e4052b1… 3667… <NA>     <NA>      USA   WDA2216  <NA>             8403
#> # ℹ 6,652 more rows
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
#> # A tibble: 51 × 2
#>    index vesselId                             
#>    <dbl> <chr>                                
#>  1     1 d32af7320-0748-9a63-abd7-48ad721e63b8
#>  2     1 5446e7cd1-1f75-4672-d859-01211df72fba
#>  3     2 47b944765-5819-b2ab-8c2e-cfc82bd2e82c
#>  4     3 9f5552145-50ed-92f4-4514-5177b1a6511d
#>  5     3 15cea26f5-57ad-acac-4cbf-b45cefb7ab04
#>  6     4 0dddd2a83-3626-24f1-0fe6-3c4d45bbb409
#>  7     4 695b254f7-7e6c-ff50-dc63-55139d9e0101
#>  8     4 ac994bdab-b59c-9fcc-659e-40179e5dddfb
#>  9     5 bc29946f2-2b0b-9613-054a-cd59327226d9
#> 10     5 0e4052b12-2e16-969f-d3e3-2a266be74255
#> # ℹ 41 more rows
```

There are 51 `vesselIds` corresponding to those 20 vessels.

Let’s pass the vector of `vesselIds` to Events API. Now get the list of
fishing events for these trawlers in January, 2020:

``` r
fishing_events <- get_event(event_type = "FISHING",
                            vessels = twenty_usa_trawlers$vesselId,
                            start_date = "2020-01-01",
                            end_date = "2020-02-01")
#> [1] "Downloading 63 events from GFW"
fishing_events
#> # A tibble: 63 × 17
#>    start               end                 eventId        eventType   lat    lon
#>    <dttm>              <dttm>              <chr>          <chr>     <dbl>  <dbl>
#>  1 2020-01-22 03:07:24 2020-01-23 03:57:57 7812ab3b7950f… fishing    38.0  -73.9
#>  2 2020-01-05 03:57:26 2020-01-05 05:24:51 0a79fe4183554… fishing    44.4 -124. 
#>  3 2020-01-18 06:54:55 2020-01-18 07:29:56 5ff9724477b70… fishing    41.4  -69.3
#>  4 2020-01-25 09:38:35 2020-01-25 10:34:01 6b4c28449e7fe… fishing    40.1  -72.7
#>  5 2020-01-16 15:07:04 2020-01-16 17:16:20 db046d9ebb664… fishing    41.4  -69.3
#>  6 2020-01-17 18:15:20 2020-01-17 23:14:40 4fe0db533d5a6… fishing    41.5  -70.2
#>  7 2020-01-17 09:10:03 2020-01-17 17:57:00 e5d2760a2cd5e… fishing    41.5  -70.1
#>  8 2020-01-05 15:00:22 2020-01-06 00:35:34 873cf3ee8755c… fishing    41.4  -68.7
#>  9 2020-01-15 21:35:14 2020-01-16 11:01:12 2c309e235a0d1… fishing    41.4  -68.7
#> 10 2020-01-16 17:38:41 2020-01-17 07:47:12 1b4256ca28af9… fishing    41.4  -69.6
#> # ℹ 53 more rows
#> # ℹ 11 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_publicAuthorizations <list>,
#> #   vessel_nextPort <lgl>, event_info <list>
```

The columns starting by `vessel` hold the vessel-related information for
each event: `vesselId`, `vessel_name`, `ssvid` (MMSI), `flag`,
`vessel type` and public authorizations.

``` r
fishing_events %>% 
  dplyr::select(starts_with("vessel"))
#> # A tibble: 63 × 7
#>    vesselId                     vessel_name vessel_ssvid vessel_flag vessel_type
#>    <chr>                        <chr>       <chr>        <chr>       <chr>      
#>  1 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  2 0203066e4-4f99-c97a-7b94-0e… PROSPECTOR  367428110    USA         fishing    
#>  3 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#>  4 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#>  5 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#>  6 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#>  7 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#>  8 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#>  9 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#> 10 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#> # ℹ 53 more rows
#> # ℹ 2 more variables: vessel_publicAuthorizations <list>, vessel_nextPort <lgl>
```

When no events are available, the `get_event()` function returns
nothing.

``` r
get_event(event_type = "FISHING",
          vessels = twenty_usa_trawlers$vesselId[2],
          start_date = "2020-01-01",
          end_date = "2020-01-01"
          )
#> [1] "Your request returned zero results"
#> NULL
```

## Apparent fishing effort API

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

You can load an `sf` shapefile with your area of interest and fetch
apparent fishing effort for this area using
`region_source = "USER_SHAPEFILE"` and `region = [YOUR_SHAPE]`. We added
a sample shapefile inside `gfwr` to show how `"USER_SHAPEFILE"` works:

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
  spatial_resolution = "LOW",
  temporal_resolution = "YEARLY",
  group_by = "FLAG",
  start_date = "2021-01-01",
  end_date = "2021-02-01",
  region_source = "USER_SHAPEFILE",
  region = test_shape
  )
#> # A tibble: 2,686 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  15.1  60.4         2021 CHN              2                    15.6 
#>  2  15.2  61.4         2021 CHN              3                    13.3 
#>  3  15.7  63.7         2021 CHN              2                    14.6 
#>  4  15.6  62.7         2021 CHN              1                    11.7 
#>  5   4.6  65.7         2021 TWN              1                     1.82
#>  6   5.8  67.2         2021 TWN              1                    10.2 
#>  7  15.4  60.6         2021 CHN              1                     7.81
#>  8  12.5  62.2         2021 CHN              1                     5.78
#>  9   6    68.8         2021 <NA>             1                     5.46
#> 10   3.5  65.5         2021 LKA              1                     3.98
#> # ℹ 2,676 more rows
```

### Apparent fishing effort in preloaded EEZ, RFMOs and MPAs

#### EEZ

If you want raster data from a particular EEZ, you can use the
`get_region_id()` function to get the EEZ id, and enter that code in the
`region_name` argument of `get_raster()` instead of the region shapefile
(with `region_source = "EEZ"`):

``` r
# use EEZ function to get EEZ code of Cote d'Ivoire
code_eez <- get_region_id(region_name = "CIV", region_source = "EEZ")

get_raster(spatial_resolution = "LOW",
           temporal_resolution = "YEARLY",
           group_by = "FLAG",
           start_date = "2021-01-01",
           end_date = "2021-10-01",
           region = code_eez$id,
           region_source = "EEZ")
#> # A tibble: 595 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1   4.5  -3.8         2021 PAN              1                     2.24
#>  2   2.1  -6.4         2021 BLZ              1                     3.98
#>  3   4.5  -6.7         2021 CHN              1                    35.4 
#>  4   3.3  -6.6         2021 BLZ              1                     4.05
#>  5   1.4  -6.8         2021 BLZ              1                     3.27
#>  6   4.7  -5.8         2021 CHN              1                     3.62
#>  7   4.4  -3.7         2021 BLZ              1                     0.72
#>  8   1.7  -5.6         2021 BLZ              1                     0.39
#>  9   4    -3.6         2021 BES              1                     2.99
#> 10   3.1  -4           2021 FRA              1                     5.1 
#> # ℹ 585 more rows
```

You could search for just one word in the name of the EEZ and then
decide which one you want:

``` r
(get_region_id(region_name = "France", region_source = "EEZ"))
#> # A tibble: 3 × 5
#>   iso3  label                                id GEONAME                 POL_TYPE
#>   <chr> <chr>                             <dbl> <chr>                   <chr>   
#> 1 <NA>  Joint regime area: Spain / France 48966 Joint regime area: Spa… Joint r…
#> 2 <NA>  Joint regime area: France / Italy 48976 Joint regime area: Fra… Joint r…
#> 3 FRA   France                             5677 French Exclusive Econo… 200NM
```

From the results above, let’s say we’re interested in the French
Exclusive Economic Zone, `5677`

``` r
get_raster(spatial_resolution = "LOW",
           temporal_resolution = "YEARLY",
           group_by = "FLAG",
           start_date = "2021-01-01",
           end_date = "2021-10-01",
           region = 5677,
           region_source = "EEZ"
           )
#> # A tibble: 5,618 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  45.2  -3           2021 FRA             13                   239.  
#>  2  45.1  -3.3         2021 ESP             21                    62.2 
#>  3  41.3   8.9         2021 ITA              1                     2.16
#>  4  43.4   4.5         2021 FRA             12                    86.4 
#>  5  44.4  -1.6         2021 FRA              4                    61.7 
#>  6  46.2  -3.8         2021 FRA             11                    76.7 
#>  7  46.1  -3.5         2021 ESP              5                    14.2 
#>  8  49.9  -1.2         2021 FRA              9                    82.5 
#>  9  43.3   4.4         2021 FRA             20                   342.  
#> 10  50     0.2         2021 GBR              3                   165.  
#> # ℹ 5,608 more rows
```

#### Marine Protected Areas (MPAs)

A similar approach can be used to search for a specific Marine Protected
Area, in this case the Phoenix Island Protected Area (PIPA)

``` r
# use region id function to get MPA code of Phoenix Island Protected Area
code_mpa <- get_region_id(region_name = "Phoenix",
                          region_source = "MPA")
code_mpa
#> # A tibble: 2 × 2
#>   id        label                                                               
#>   <chr>     <chr>                                                               
#> 1 309888    Phoenix Islands Protected Area - Protected Area                     
#> 2 555512002 Phoenix Islands Protected Area - World Heritage Site (natural or mi…
get_raster(spatial_resolution = "LOW",
           temporal_resolution = "YEARLY",
           group_by = "FLAG",
           start_date = "2015-01-01",
           end_date = "2015-06-01",
           region = code_mpa$id[1],
           region_source = "MPA")
#> # A tibble: 38 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  -3.6 -176.         2015 KOR              1                     1.98
#>  2  -2.8 -176.         2015 KOR              1                    10.4 
#>  3  -3.5 -176.         2015 KOR              1                     3.11
#>  4  -1   -170.         2015 KOR              1                     2.39
#>  5  -4.1 -176.         2015 KOR              1                     2.67
#>  6  -2.9 -176.         2015 FSM              1                     2.77
#>  7  -3   -176.         2015 FSM              1                     2.16
#>  8  -2.6 -176.         2015 KOR              1                    13.9 
#>  9  -3.6 -176.         2015 KIR              1                     6.07
#> 10  -2.3 -176.         2015 TWN              1                    17.3 
#> # ℹ 28 more rows
```

#### Regional Fisheries Management Organizations (RFMOs)

It is also possible to filter rasters to regional fisheries management
organizations (RFMO) like `"ICCAT"`, `"IATTC"`, `"IOTC"`, `"CCSBT"` and
`"WCPFC"`.

``` r
get_raster(spatial_resolution = "LOW",
           temporal_resolution = "DAILY",
           group_by = "FLAG",
           start_date = "2021-01-01",
           end_date = "2021-01-04",
           region = "ICCAT",
           region_source = "RFMO")
#> # A tibble: 16,878 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl> <date>       <chr>        <dbl>                    <dbl>
#>  1  44.5 -57.1 2021-01-02   CAN              1                     0.43
#>  2  14.3 -17.2 2021-01-02   SEN              3                     6   
#>  3 -30     2.5 2021-01-01   SEN              1                     0.57
#>  4  19.8 -17.2 2021-01-01   FRA              1                     1.81
#>  5  57.8  10.4 2021-01-03   DNK              6                     5.91
#>  6  59.3  -3.6 2021-01-02   GBR              1                     0.34
#>  7   8.6 -26.9 2021-01-01   JPN              1                     1.96
#>  8  50.1  -4.5 2021-01-02   GBR              3                     4.81
#>  9  55.5   8.2 2021-01-03   DNK              4                     7.09
#> 10  16.5 -18.1 2021-01-01   JPN              1                     0.53
#> # ℹ 16,868 more rows
```

> *Note*: For a complete list of MPAs, RFMOs and EEZ, check the function
> `get_regions()`

### When your API request times out

For API performance reasons, the `get_raster()` function restricts
individual queries to a single year of data. However, even with this
restriction, it is possible for API request to time out before it
completes. When this occurs, the initial `get_raster()` call will return
an `HTTP 524 error`, and subsequent API requests using any `gfwr` `get_`
function will return an `HTTP 429 error` until the original request
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
documentation on the Global Fishing Watch API page.

## Reverse region id search

The `get_region_id()` function also works in reverse. If a region id is
passed as a `numeric` to the function as the `region_name`, the
corresponding region label or iso3 code can be returned. This is
especially useful when events are returned with regions.

Using the same example with twenty trawlers fishing events,
`fishing_events`, you can see the `eez` information is returned as the
numeric code in the `"eez"` column.

``` r
fishing_events <- get_event(event_type = "FISHING",
                            vessels = twenty_usa_trawlers$vesselId,
                            start_date = "2020-01-01",
                            end_date = "2020-02-01") %>%
  # extract EEZ id code
  dplyr::mutate(eez = as.character(
    purrr::map(purrr::map(regions, purrr::pluck, "eez"),
               paste0, collapse = ","))) %>%
  dplyr::select(eez, eventId, eventType, start, end, lat, lon) 
#> [1] "Downloading 63 events from GFW"

fishing_events
#> # A tibble: 63 × 7
#>    eez   eventId  eventType start               end                   lat    lon
#>    <chr> <chr>    <chr>     <dttm>              <dttm>              <dbl>  <dbl>
#>  1 8456  0a79fe4… fishing   2020-01-05 03:57:26 2020-01-05 05:24:51  44.4 -124. 
#>  2 8456  7812ab3… fishing   2020-01-22 03:07:24 2020-01-23 03:57:57  38.0  -73.9
#>  3 8456  0b0e500… fishing   2020-01-25 12:32:16 2020-01-25 13:32:16  39.9  -73.0
#>  4 8456  cf7977e… fishing   2020-01-18 08:32:40 2020-01-19 20:25:48  41.4  -69.3
#>  5 8456  c5409b5… fishing   2020-01-13 15:19:52 2020-01-13 17:47:54  41.5  -69.3
#>  6 8456  6640019… fishing   2020-01-14 04:56:04 2020-01-14 08:13:47  41.4  -68.7
#>  7 8456  ea4db5b… fishing   2020-01-13 20:43:47 2020-01-14 04:08:49  41.4  -68.7
#>  8 8456  ce3b328… fishing   2020-01-26 14:54:28 2020-01-27 10:03:45  39.6  -72.8
#>  9 8456  6937c9b… fishing   2020-01-25 13:58:44 2020-01-26 13:47:48  39.8  -72.8
#> 10 8456  ea857a1… fishing   2020-01-31 05:25:15 2020-01-31 06:43:40  42.8 -125. 
#> # ℹ 53 more rows
```

We can apply `get_region_id()` to the numeric vector to extract the
labels:

``` r
fishing_events %>% 
  mutate(eez_name = purrr::map_df(as.numeric(fishing_events$eez),
                                  ~get_region_id(region_name = .x,
                                                 region_source = "EEZ"))$label) %>% 
  dplyr::relocate(eez, eez_name)
#> # A tibble: 63 × 8
#>    eez   eez_name      eventId eventType start               end                
#>    <chr> <chr>         <chr>   <chr>     <dttm>              <dttm>             
#>  1 8456  United States 0a79fe… fishing   2020-01-05 03:57:26 2020-01-05 05:24:51
#>  2 8456  United States 7812ab… fishing   2020-01-22 03:07:24 2020-01-23 03:57:57
#>  3 8456  United States 0b0e50… fishing   2020-01-25 12:32:16 2020-01-25 13:32:16
#>  4 8456  United States cf7977… fishing   2020-01-18 08:32:40 2020-01-19 20:25:48
#>  5 8456  United States c5409b… fishing   2020-01-13 15:19:52 2020-01-13 17:47:54
#>  6 8456  United States 664001… fishing   2020-01-14 04:56:04 2020-01-14 08:13:47
#>  7 8456  United States ea4db5… fishing   2020-01-13 20:43:47 2020-01-14 04:08:49
#>  8 8456  United States ce3b32… fishing   2020-01-26 14:54:28 2020-01-27 10:03:45
#>  9 8456  United States 6937c9… fishing   2020-01-25 13:58:44 2020-01-26 13:47:48
#> 10 8456  United States ea857a… fishing   2020-01-31 05:25:15 2020-01-31 06:43:40
#> # ℹ 53 more rows
#> # ℹ 2 more variables: lat <dbl>, lon <dbl>
```
