
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
- [Vessel presence based on
  AIS](https://globalfishingwatch.org/our-apis/documentation#map-visualization-4wings-api)
  for all vessel types
- [Apparent fishing effort in hours, based on
  AIS](https://globalfishingwatch.org/our-apis/documentation#map-visualization-4wings-api)
  for all vessels classified as fishing vessels
- [SAR vessel
  detections](https://globalfishingwatch.org/our-apis/documentation#map-visualization-4wings-api),
  indicating which vessels were matched or unmatched with AIS

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

The `gfw_vessel_info()` function allows you to get vessel identity
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
gfw_vessel_info(query = 224224000,
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
gfw_vessel_info(where = "shipname LIKE '%GABU REEFE%' OR imo = '8300949'",
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
#> # A tibble: 4 × 10
#>   index vesselId              geartypes_name geartypes_source geartypes_yearFrom
#>   <dbl> <chr>                 <chr>          <chr>                         <int>
#> 1     1 9827ea1ea-a120-f374-… CARRIER        GFW_VESSEL_LIST                2024
#> 2     1 0b7047cb5-58c8-6e63-… CARRIER        GFW_VESSEL_LIST                2019
#> 3     1 58cf536b1-1fca-dac3-… CARRIER        GFW_VESSEL_LIST                2012
#> 4     1 1da8dbc23-3c48-d5ce-… CARRIER        GFW_VESSEL_LIST                2022
#> # ℹ 5 more variables: geartypes_yearTo <int>, shiptypes_name <chr>,
#> #   shiptypes_source <chr>, shiptypes_yearFrom <int>, shiptypes_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 4 × 14
#>   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#>   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#> 1     1 9827ea1ea… 6290… GABU RE… GABUREEF… GMB   C5J278   8300…          968799
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
> `gfw_vessel_info()` and fetching the vector of responses inside
> `$selfReportedInfo$vesselId`. See the [identity
> vignette](https://globalfishingwatch.github.io/gfwr/articles/identity)
> for more information.

#### Single vessel IDs

``` r
gfw_vessel_info(ids = "8c7304226-6c71-edbe-0b63-c246734b3c01",
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
#> 1     1 COLINER RUS   273379740 <chr [2]>  2015-02-27T10:59:43Z 2025-08-31T23:0…
#> 2     1 COLINER CYP   511101495 <chr [1]>  2024-07-04T14:27:04Z 2024-07-24T14:2…
#> 3     1 COLINER CYP   210631000 <chr [1]>  2013-05-15T20:19:43Z 2024-07-04T14:1…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 3 × 5
#>   index dateFrom             dateTo               ssvid     sourceCode
#>   <dbl> <chr>                <chr>                <chr>     <list>    
#> 1     1 2023-01-01T00:00:00Z 2024-12-31T00:00:00Z 210631000 <chr [1]> 
#> 2     1 2020-01-01T00:00:00Z 2024-12-01T00:00:00Z 210631000 <chr [1]> 
#> 3     1 2024-08-09T00:00:00Z 2025-09-01T00:00:00Z 273379740 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 8 × 10
#>   index vesselId              geartypes_name geartypes_source geartypes_yearFrom
#>   <dbl> <chr>                 <chr>          <chr>                         <int>
#> 1     1 3c81a942b-bf0a-f476-… CARRIER        GFW_VESSEL_LIST                2015
#> 2     1 0cb77880e-ee49-2ce4-… CARRIER        GFW_VESSEL_LIST                2012
#> 3     1 0edad163f-f53d-9ddb-… CARRIER        GFW_VESSEL_LIST                2024
#> 4     1 da1cd7e1b-b8d0-539c-… CARRIER        GFW_VESSEL_LIST                2015
#> 5     1 da1cd7e1b-b8d0-539c-… CARRIER        GFW_VESSEL_LIST                2015
#> 6     1 da1cd7e1b-b8d0-539c-… CARRIER        GFW_VESSEL_LIST                2019
#> 7     1 da1cd7e1b-b8d0-539c-… CARRIER        GFW_VESSEL_LIST                2019
#> 8     1 8c7304226-6c71-edbe-… CARRIER        GFW_VESSEL_LIST                2013
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
gfw_vessel_info(ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01",
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
#> 2                        1
#> 3                        2
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
#> 6     2 685862e0626f62… <chr [6]>  5480… PHL   JOHNREY… JOHNREYN… DUQA7    8118…
#> 7     3 b82d02e5c2c11e… <chr [6]>  4417… KOR   ADRIA    ADRIA     DTBY3    8919…
#> 8     3 b82d02e5c2c11e… <chr [5]>  4417… KOR   PREMIER  PREMIER   DTBY3    8919…
#> # ℹ 8 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <chr>, lengthM <dbl>, tonnageGt <dbl>,
#> #   vesselInfoReference <chr>, extraFields <list>
#> 
#> $registryOwners
#> # A tibble: 3 × 7
#>   index name    flag  ssvid     sourceCode dateFrom             dateTo          
#>   <dbl> <chr>   <chr> <chr>     <list>     <chr>                <chr>           
#> 1     1 COLINER RUS   273379740 <chr [2]>  2015-02-27T10:59:43Z 2025-08-31T23:0…
#> 2     1 COLINER CYP   511101495 <chr [1]>  2024-07-04T14:27:04Z 2024-07-24T14:2…
#> 3     1 COLINER CYP   210631000 <chr [1]>  2013-05-15T20:19:43Z 2024-07-04T14:1…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 8 × 5
#>   index dateFrom             dateTo               ssvid     sourceCode
#>   <dbl> <chr>                <chr>                <chr>     <list>    
#> 1     1 2023-01-01T00:00:00Z 2024-12-31T00:00:00Z 210631000 <chr [1]> 
#> 2     1 2020-01-01T00:00:00Z 2024-12-01T00:00:00Z 210631000 <chr [1]> 
#> 3     1 2024-08-09T00:00:00Z 2025-09-01T00:00:00Z 273379740 <chr [1]> 
#> 4     2 2012-01-01T00:00:00Z 2017-10-25T00:00:00Z 548012100 <chr [1]> 
#> 5     2 2019-02-10T18:02:49Z 2025-09-01T00:00:00Z 548012100 <chr [1]> 
#> 6     3 2015-10-08T00:00:00Z 2020-07-21T00:00:00Z 441734000 <chr [1]> 
#> 7     3 2012-01-01T00:00:00Z 2013-09-19T00:00:00Z 441734000 <chr [1]> 
#> 8     3 2013-09-20T00:00:00Z 2025-01-01T00:00:00Z 441734000 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 12 × 10
#>    index vesselId             geartypes_name geartypes_source geartypes_yearFrom
#>    <dbl> <chr>                <chr>          <chr>                         <int>
#>  1     1 3c81a942b-bf0a-f476… CARRIER        GFW_VESSEL_LIST                2015
#>  2     1 0cb77880e-ee49-2ce4… CARRIER        GFW_VESSEL_LIST                2012
#>  3     1 0edad163f-f53d-9ddb… CARRIER        GFW_VESSEL_LIST                2024
#>  4     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2015
#>  5     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2015
#>  6     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2019
#>  7     1 da1cd7e1b-b8d0-539c… CARRIER        GFW_VESSEL_LIST                2019
#>  8     1 8c7304226-6c71-edbe… CARRIER        GFW_VESSEL_LIST                2013
#>  9     2 55889aefb-bef9-224c… TUNA_PURSE_SE… COMBINATION_OF_…               2017
#> 10     2 71e7da672-2451-17da… TUNA_PURSE_SE… COMBINATION_OF_…               2017
#> 11     3 aca119c29-95dd-f5c4… TUNA_PURSE_SE… COMBINATION_OF_…               2012
#> 12     3 6583c51e3-3626-5638… TUNA_PURSE_SE… COMBINATION_OF_…               2013
#> # ℹ 5 more variables: geartypes_yearTo <int>, shiptypes_name <chr>,
#> #   shiptypes_source <chr>, shiptypes_yearFrom <int>, shiptypes_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 3 × 14
#>   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#>   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#> 1     1 8c7304226… 2106… FRIO FO… FRIOFORW… CYP   5BWC3    9076…         3369802
#> 2     2 71e7da672… 5480… JOHN RE… JOHNREYN… PHL   DUQA-7   8118…          133081
#> 3     3 6583c51e3… 4417… ADRIA    ADRIA     KOR   DTBY3    <NA>           360249
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

**Check the function documentation for examples with the other function
arguments and [our dedicated
vignette](https://globalfishingwatch.github.io/gfwr/articles/identity)
for more information about vessel identity markers and the outputs
retrieved.**

## Events API

The `gfw_event()` function allows you to get data on specific vessel
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
gfw_event(event_type = "ENCOUNTER",
          start_date = "2020-01-01",
          end_date = "2020-01-02")
#> [1] "Downloading 282 events from GFW"
#> # A tibble: 282 × 17
#>    start               end                 eventId      eventType     lat    lon
#>    <dttm>              <dttm>              <chr>        <chr>       <dbl>  <dbl>
#>  1 2019-12-31 17:50:00 2020-01-01 03:00:00 4c547fe1bd0… encounter -17.9   -79.1 
#>  2 2019-12-17 14:10:00 2020-01-02 04:10:00 2cacbbe4a0c… encounter  67.5    15.5 
#>  3 2020-01-01 08:10:00 2020-01-01 11:10:00 dc46f3bf7da… encounter   0.993  -4.18
#>  4 2020-01-01 06:10:00 2020-01-01 20:10:00 7278387d3f6… encounter  24.6   119.  
#>  5 2020-01-01 10:20:00 2020-01-01 18:50:00 964ab8ab911… encounter  34.6   129.  
#>  6 2020-01-01 12:30:00 2020-01-01 17:50:00 3792aec35df… encounter  38.5   121.  
#>  7 2020-01-01 10:50:00 2020-01-01 15:40:00 de299550942… encounter   8.01  -13.5 
#>  8 2020-01-01 16:20:00 2020-01-01 21:10:00 55d211fba82… encounter  38.5   121.  
#>  9 2020-01-01 05:40:00 2020-01-01 13:00:00 1136954e706… encounter  21.2   111.  
#> 10 2020-01-01 10:30:00 2020-01-01 13:20:00 245565dd264… encounter  60.1   169.  
#> # ℹ 272 more rows
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
gfw_event(event_type = "FISHING",
               start_date = "2020-10-01",
               end_date = "2020-10-31",
               region = test_polygon,
               region_source = "USER_SHAPEFILE")
#> [1] "Downloading 59 events from GFW"
#> # A tibble: 59 × 17
#>    start               end                 eventId        eventType    lat   lon
#>    <dttm>              <dttm>              <chr>          <chr>      <dbl> <dbl>
#>  1 2020-10-03 05:50:14 2020-10-05 03:35:27 b68b49e7e3655… fishing    4.73  -51.5
#>  2 2020-10-23 09:23:27 2020-10-23 14:23:03 a559f9c1a2fee… fishing    4.72  -51.5
#>  3 2020-10-01 12:09:55 2020-10-02 22:03:36 d8ed35e858292… fishing    4.73  -51.5
#>  4 2020-10-24 12:44:50 2020-10-24 13:37:16 9388ff85a3d81… fishing    0.267 -47.8
#>  5 2020-10-18 00:18:32 2020-10-18 04:04:43 2fd3ab7d16550… fishing    0.449 -47.8
#>  6 2020-10-17 17:59:45 2020-10-17 19:45:10 b08ba788b149c… fishing    0.222 -47.7
#>  7 2020-10-22 12:42:13 2020-10-22 17:58:59 22205188596dc… fishing   -0.121 -47.7
#>  8 2020-10-03 11:58:33 2020-10-03 19:30:08 92a28d8935c1c… fishing   -0.107 -47.7
#>  9 2020-10-18 23:15:26 2020-10-19 07:52:48 b40e1caf208b9… fishing    0.474 -47.8
#> 10 2020-10-18 21:29:13 2020-10-18 22:28:02 eb82a3cc27a9e… fishing    4.95  -51.6
#> # ℹ 49 more rows
#> # ℹ 11 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_publicAuthorizations <list>,
#> #   vessel_nextPort <lgl>, event_info <list>
```

### Events for specific vessels

To extract events for specific vessels, the Events API needs `vesselId`
as input, so you always need to use `gfw_vessel_info()` first to extract
`vesselId` from `$selfReportedInfo` in the response.

#### Single vessel events

``` r
vessel_info <- gfw_vessel_info(query = 224224000)
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

gfw_event(event_type = "PORT_VISIT",
          vessels = id[1],
          confidences = 4
          )
#> [1] "Downloading 25 events from GFW"
#> # A tibble: 25 × 16
#>    start               end                 eventId        eventType   lat    lon
#>    <dttm>              <dttm>              <chr>          <chr>     <dbl>  <dbl>
#>  1 2020-01-11 11:18:49 2020-01-15 11:54:49 889beb4fc4bfb… port_vis…  5.23  -4.02
#>  2 2020-02-23 12:44:03 2020-02-24 10:35:02 672bc20417b3c… port_vis… 16.9  -25.0 
#>  3 2020-03-05 13:28:59 2020-03-10 02:26:24 0d845cb306614… port_vis…  5.20  -4.02
#>  4 2020-06-20 12:33:45 2020-06-20 19:43:10 a8f5401a3bbec… port_vis… 14.6  -17.4 
#>  5 2019-11-15 14:15:11 2019-11-19 07:49:20 bbeed3f884a6f… port_vis…  5.20  -4.02
#>  6 2020-07-06 06:45:06 2020-07-12 09:13:39 6845cffacfe25… port_vis…  5.20  -4.02
#>  7 2019-12-06 11:02:09 2019-12-11 10:20:04 bcd967c59306c… port_vis…  5.20  -4.04
#>  8 2020-12-14 09:46:52 2020-12-22 16:54:09 9205a53a7b91d… port_vis…  5.20  -4.04
#>  9 2021-05-19 22:46:40 2021-06-08 08:54:49 ed0ffc8600077… port_vis… 14.7  -17.4 
#> 10 2020-04-01 05:55:58 2020-04-05 15:03:18 953e1cf8246db… port_vis…  5.23  -4.02
#> # ℹ 15 more rows
#> # ℹ 10 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_nextPort <lgl>, event_info <list>
```

But to get the whole event history, it’s better to use the whole vector
of `vesselId` for that vessel. Notice how the following request provides
more results than the previous one:

``` r
gfw_event(event_type = "PORT_VISIT",
          vessels = id, #using the whole vector of vesselIds
          confidences = 4
          )
#> [1] "Downloading 74 events from GFW"
#> # A tibble: 74 × 16
#>    start               end                 eventId        eventType   lat    lon
#>    <dttm>              <dttm>              <chr>          <chr>     <dbl>  <dbl>
#>  1 2019-09-29 05:40:18 2019-10-02 17:16:39 baa809792afe6… port_vis… 14.6  -17.4 
#>  2 2018-11-06 17:27:26 2018-11-11 09:43:00 a1e988d982768… port_vis…  5.23  -4.02
#>  3 2020-01-11 11:18:49 2020-01-15 11:54:49 889beb4fc4bfb… port_vis…  5.23  -4.02
#>  4 2017-04-13 10:07:49 2017-04-29 20:58:13 de2a5c8f51a93… port_vis… 14.6  -17.4 
#>  5 2020-02-23 12:44:03 2020-02-24 10:35:02 672bc20417b3c… port_vis… 16.9  -25.0 
#>  6 2016-10-04 17:15:47 2016-10-09 21:02:28 2d376318fda23… port_vis…  5.23  -4.02
#>  7 2020-06-20 12:33:45 2020-06-20 19:43:10 a8f5401a3bbec… port_vis… 14.6  -17.4 
#>  8 2017-05-13 07:10:29 2017-05-13 09:11:40 757664f40518d… port_vis… 14.7  -17.3 
#>  9 2017-05-08 07:01:08 2017-05-12 14:59:28 fa765a604c499… port_vis…  5.29  -4.02
#> 10 2015-12-29 14:52:13 2016-01-03 16:38:59 ecd93cc08b521… port_vis…  5.29  -4.01
#> # ℹ 64 more rows
#> # ℹ 10 more variables: regions <list>, boundingBox <list>, distances <list>,
#> #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
#> #   vessel_type <chr>, vessel_nextPort <lgl>, event_info <list>
```

> *Note*: Try narrowing your search using `start_date` and `end_date` if
> the request is too large and returns a time out error (524)

When a date range is provided to `gfw_event()` using both `start_date`
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
usa_trawlers <- gfw_vessel_info(
  where = "flag='USA' AND geartypes='TRAWLERS'",
  search_type = "search",
  quiet = TRUE 
  )
# Set quiet = TRUE if you want the output to return silently
```

This list returns 6566 `vesselIds` belonging to 4200 vessels.

``` r
usa_trawlers$selfReportedInfo
#> # A tibble: 6,757 × 14
#>    index vesselId  ssvid shipname nShipname flag  callsign imo   messagesCounter
#>    <dbl> <chr>     <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
#>  1     1 d32af732… 3680… SUPERMA… SUPERMAN… USA   WDJ8890  <NA>           267397
#>  2     1 5446e7cd… 3680… SUPERMA… SUPERMAN… USA   <NA>     <NA>             6184
#>  3     2 47b94476… 3668… ORION    ORION     USA   <NA>     <NA>            23007
#>  4     3 9f555214… 3680… PELICAN  PELICAN   USA   WDJ8253  <NA>           445303
#>  5     3 15cea26f… 3680… PELICAN  PELICAN   USA   <NA>     <NA>              407
#>  6     4 0dddd2a8… 3673… SHAMROCK SHAMROCK  USA   WDD8722  <NA>             2720
#>  7     4 695b254f… 3673… SHAMROCK SHAMROCK  USA   <NA>     <NA>              477
#>  8     4 ac994bda… 3673… <NA>     <NA>      USA   WDD8722  <NA>             3179
#>  9     5 bc29946f… 3667… ALEX     ALEX      USA   WDA2216  <NA>           891164
#> 10     5 0e4052b1… 3667… <NA>     <NA>      USA   WDA2216  <NA>             8403
#> # ℹ 6,747 more rows
#> # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
#> #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

To fetch events for this list of vessels, we will use the `vesselId`
column and send it to the `vessels` parameter in `gfw_event()` function.

For clarity, we should try to send groups of `vesselIds` that belong to
the same vessels. For this, we can check the `index` column in the
`$selfReportedInfo` dataset.

> *Note*: `gfw_event()` can receive several `vesselIds` at a time but
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
#> # A tibble: 54 × 2
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
#> # ℹ 44 more rows
```

There are 54 `vesselIds` corresponding to those 20 vessels.

Let’s pass the vector of `vesselIds` to Events API. Now get the list of
fishing events for these trawlers in January, 2020:

``` r
fishing_events <- gfw_event(event_type = "FISHING",
                            vessels = twenty_usa_trawlers$vesselId,
                            start_date = "2020-01-01",
                            end_date = "2020-02-01")
#> [1] "Downloading 63 events from GFW"
fishing_events
#> # A tibble: 63 × 17
#>    start               end                 eventId        eventType   lat    lon
#>    <dttm>              <dttm>              <chr>          <chr>     <dbl>  <dbl>
#>  1 2020-01-15 17:46:45 2020-01-15 21:34:32 b1907b472756f… fishing    38.1  -73.9
#>  2 2020-01-25 13:58:44 2020-01-26 13:47:48 6937c9bbb199e… fishing    39.8  -72.8
#>  3 2020-01-30 23:49:26 2020-01-31 04:34:08 90c53f1ca7571… fishing    38    -73.9
#>  4 2019-12-31 01:38:26 2020-01-02 05:06:56 b630325a08b11… fishing    41.4  -68.7
#>  5 2020-01-17 09:10:03 2020-01-17 17:57:00 e5d2760a2cd5e… fishing    41.5  -70.1
#>  6 2020-01-31 07:58:03 2020-01-31 13:32:38 ce97b3eedf575… fishing    42.8 -125. 
#>  7 2020-01-09 18:32:34 2020-01-09 19:20:15 2068a73ed9b3a… fishing    38.3  -73.6
#>  8 2020-01-14 23:39:33 2020-01-15 01:16:19 a8b50bdbf3713… fishing    37.8  -74.2
#>  9 2020-01-23 06:40:00 2020-01-23 07:48:45 5d37b7e7f124d… fishing    38.0  -73.9
#> 10 2020-01-31 17:27:10 2020-01-31 23:44:46 4658cdceebbf2… fishing    38.0  -73.9
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
#>  2 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#>  3 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  4 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#>  5 35eb371c0-088a-1382-098a-c7… STARBRITE   367707710    USA         fishing    
#>  6 454a28f85-56e4-93cb-efa6-ff… BERNADETTE  366233570    USA         fishing    
#>  7 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  8 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#>  9 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#> 10 64907178b-b02a-f401-afa1-b3… SUSAN L     366211560    USA         fishing    
#> # ℹ 53 more rows
#> # ℹ 2 more variables: vessel_publicAuthorizations <list>, vessel_nextPort <lgl>
```

When no events are available, the `gfw_event()` function returns
nothing.

``` r
gfw_event(event_type = "FISHING",
          vessels = twenty_usa_trawlers$vesselId[2],
          start_date = "2020-01-01",
          end_date = "2020-01-01")
#> [1] "Your request returned zero results"
#> NULL
```

## Apparent fishing hours

The `gfw_ais_fishing_hours()` function gets a raster from the [4Wings
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
apparent the data of interest. for this area using
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

gfw_ais_fishing_hours(spatial_resolution = "LOW",
               temporal_resolution = "YEARLY",
               group_by = "FLAG",
               start_date = "2021-01-01",
               end_date = "2021-02-01",
               region_source = "USER_SHAPEFILE",
               region = test_shape)
#> # A tibble: 2,686 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1   1.4  65.6         2021 FRA              1                     1.53
#>  2   1.5  68.2         2021 TWN              1                     1.04
#>  3   2.5  68.4         2021 LKA              1                     8.69
#>  4   2    65.3         2021 LKA              1                     0.73
#>  5   0.1  65.9         2021 LKA              1                     1.08
#>  6  14.7  64.4         2021 CHN              1                    14.0 
#>  7   2.8  66.3         2021 LKA              1                     1.22
#>  8  17    64.1         2021 CHN              1                     6.52
#>  9  15.1  60.4         2021 CHN              2                    15.6 
#> 10  15.2  61.4         2021 CHN              3                    13.3 
#> # ℹ 2,676 more rows
```

### Apparent fishing hours in preloaded EEZ, RFMOs and MPAs

#### EEZ

If you want raster data from a particular EEZ, you can use the
`gfw_region_id()` function to get the EEZ id, and enter that code in the
`region` argument of `gfw_ais_fishing_hours()` instead of the region
shapefile (with `region_source = "EEZ"`):

``` r
# use EEZ function to get EEZ code of Cote d'Ivoire
code_eez <- gfw_region_id(region = "CIV", region_source = "EEZ")

gfw_ais_fishing_hours(spatial_resolution = "LOW",
                      temporal_resolution = "YEARLY",
                      group_by = "FLAG",
                      start_date = "2021-01-01",
                      end_date = "2021-10-01",
                      region = code_eez$id,
                      region_source = "EEZ")
#> # A tibble: 595 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1   1.7  -5.6         2021 BLZ              1                     0.39
#>  2   4    -3.6         2021 BES              1                     2.99
#>  3   3.1  -4           2021 FRA              1                     5.1 
#>  4   4.1  -5.7         2021 BLZ              1                     0.55
#>  5   5.2  -4.1         2021 CHN              2                    10.8 
#>  6   2.5  -5.4         2021 FRA              1                     7.45
#>  7   4.4  -3.7         2021 BES              2                     6.12
#>  8   5.3  -4           2021 SLV              3                    19   
#>  9   4    -4.2         2021 ESP              1                     3.1 
#> 10   4.1  -4           2021 GHA              1                     2.09
#> # ℹ 585 more rows
```

You could search for just one word in the name of the EEZ and then
decide which one you want:

``` r
(gfw_region_id(region = "France", region_source = "EEZ"))
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
gfw_ais_fishing_hours(spatial_resolution = "LOW",
                      temporal_resolution = "YEARLY",
                      group_by = "FLAG",
                      start_date = "2021-01-01",
                      end_date = "2021-10-01",
                      region = 5677,
                      region_source = "EEZ")
#> # A tibble: 5,618 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  49.8  -0.6         2021 NLD              7                    16.5 
#>  2  45.2  -2           2021 BEL              4                    59.3 
#>  3  42.6   3.4         2021 FRA              6                    37.8 
#>  4  45.1  -3.4         2021 ESP             20                    92   
#>  5  51.2   2.1         2021 BEL              3                    22.0 
#>  6  48.7  -4.2         2021 FRA              1                     1.01
#>  7  49.9  -1.7         2021 BEL              1                     1.71
#>  8  46.2  -3.9         2021 FRA              7                    45.4 
#>  9  44.8  -1.8         2021 ESP              9                    51.0 
#> 10  47.1  -2.6         2021 FRA             14                   174.  
#> # ℹ 5,608 more rows
```

#### Marine Protected Areas (MPAs)

A similar approach can be used to search for a specific Marine Protected
Area, in this case the Phoenix Island Protected Area (PIPA)

``` r
# use region id function to get MPA code of Phoenix Island Protected Area
code_mpa <- gfw_region_id(region = "Phoenix",
                          region_source = "MPA")
code_mpa
#> # A tibble: 2 × 2
#>   id        label                                                               
#>   <chr>     <chr>                                                               
#> 1 309888    Phoenix Islands Protected Area - Protected Area                     
#> 2 555512002 Phoenix Islands Protected Area - World Heritage Site (natural or mi…
gfw_ais_fishing_hours(spatial_resolution = "LOW",
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
#>  2  -1   -170.         2015 KOR              1                     2.39
#>  3  -2.9 -176.         2015 FSM              1                     2.77
#>  4  -2.6 -176.         2015 KOR              1                    13.9 
#>  5  -3   -176.         2015 FSM              1                     2.16
#>  6  -3.6 -176.         2015 KIR              1                     6.07
#>  7  -4.1 -176.         2015 KOR              1                     2.67
#>  8  -3.5 -176.         2015 KOR              1                     3.11
#>  9  -2.8 -176.         2015 KOR              1                    10.4 
#> 10  -4.2 -176.         2015 KOR              1                     0.05
#> # ℹ 28 more rows
```

#### Regional Fisheries Management Organizations (RFMOs)

It is also possible to filter rasters to regional fisheries management
organizations (RFMO) like `"ICCAT"`, `"IATTC"`, `"IOTC"`, `"CCSBT"` and
`"WCPFC"`.

``` r
gfw_ais_fishing_hours(spatial_resolution = "LOW",
               temporal_resolution = "DAILY",
               group_by = "FLAG",
               start_date = "2021-01-01",
               end_date = "2021-01-04",
               region = "ICCAT",
               region_source = "RFMO")
#> # A tibble: 16,878 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl> <date>       <chr>        <dbl>                    <dbl>
#>  1  38.9  26.8 2021-01-02   TUR              2                     4.35
#>  2  59     0.1 2021-01-03   GBR              2                    13.9 
#>  3  59.9  25.1 2021-01-03   FIN              2                     3   
#>  4  59.9  -2.8 2021-01-03   GBR              1                     1.11
#>  5  47.6  -3   2021-01-02   FRA              1                     2.41
#>  6  51.4  -8.9 2021-01-02   IRL              1                     0.79
#>  7  58.9  10.6 2021-01-03   SWE              1                     0.58
#>  8  38.7  26.7 2021-01-03   TUR              1                    13.4 
#>  9  15.7 -29.7 2021-01-03   JPN              1                     1.09
#> 10  11.8 -16.8 2021-01-03   KOR              1                     0.88
#> # ℹ 16,868 more rows
```

> *Note*: For a complete list of MPAs, RFMOs and EEZ, check the function
> `gfw_regions()`

### When your API request times out

For API performance reasons, the `gfw_ais_fishing_hours()` function
restricts individual queries to a single year of data. However, even
with this restriction, it is possible for API request to time out before
it completes. When this occurs, the initial `gfw_ais_fishing_hours()`
call will return an `HTTP 524 error`, and subsequent API requests using
any `gfwr` `gfw_` function will return an `HTTP 429 error` until the
original request completes:

> Error in `httr2::req_perform()`: ! HTTP 429 Too Many Requests. • Your
> application token is not currently enabled to perform more than one
> concurrent report. If you need to generate more than one report
> concurrently, contact us at <apis@globalfishingwatch.org>

Although no data was received, the request is still being processed by
the APIs and will become available when it completes. To account for
this, `gfwr` includes the `gfw_last_report()` function, which lets users
request the results of their last API request with
`gfw_ais_fishing_hours()`.

The `gfw_last_report()` function will tell you if the APIs are still
processing your request and will download the results if the request has
finished successfully. You will receive an error message if the request
finished but resulted in an error or if it’s been \>30 minutes since the
last report was generated using `gfw_ais_fishing_hours()`. For more
information, see the [Get last report generated
endpoint](https://globalfishingwatch.org/our-apis/documentation#get-last-report-generated)
documentation on the Global Fishing Watch API page.

## Reverse region id search

The `gfw_region_id()` function also works in reverse. If a region id is
passed as a `numeric` to the function as the `region`, the corresponding
region label or iso3 code can be returned. This is especially useful
when events are returned with regions.

Using the same example with twenty trawlers fishing events,
`fishing_events`, you can see the `eez` information is returned as the
numeric code in the `"eez"` column.

``` r
fishing_events <- gfw_event(event_type = "FISHING",
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
#>    eez   eventId   eventType start               end                   lat   lon
#>    <chr> <chr>     <chr>     <dttm>              <dttm>              <dbl> <dbl>
#>  1 8456  6937c9bb… fishing   2020-01-25 13:58:44 2020-01-26 13:47:48  39.8 -72.8
#>  2 8456  90c53f1c… fishing   2020-01-30 23:49:26 2020-01-31 04:34:08  38   -73.9
#>  3 8456  6b4c2844… fishing   2020-01-25 09:38:35 2020-01-25 10:34:01  40.1 -72.7
#>  4 8456  5ff97244… fishing   2020-01-18 06:54:55 2020-01-18 07:29:56  41.4 -69.3
#>  5 8456  0b0e500f… fishing   2020-01-25 12:32:16 2020-01-25 13:32:16  39.9 -73.0
#>  6 8456  c5409b54… fishing   2020-01-13 15:19:52 2020-01-13 17:47:54  41.5 -69.3
#>  7 8456  6640019a… fishing   2020-01-14 04:56:04 2020-01-14 08:13:47  41.4 -68.7
#>  8 8456  4fe0db53… fishing   2020-01-17 18:15:20 2020-01-17 23:14:40  41.5 -70.2
#>  9 8456  ea4db5be… fishing   2020-01-13 20:43:47 2020-01-14 04:08:49  41.4 -68.7
#> 10 8456  873cf3ee… fishing   2020-01-05 15:00:22 2020-01-06 00:35:34  41.4 -68.7
#> # ℹ 53 more rows
```

We can apply `gfw_region_id()` to the numeric vector to extract the
labels:

``` r
fishing_events %>% 
  mutate(eez_name = purrr::map_df(as.numeric(fishing_events$eez),
                                  ~gfw_region_id(region = .x,
                                                 region_source = "EEZ"))$label) %>% 
  dplyr::relocate(eez, eez_name)
#> # A tibble: 63 × 8
#>    eez   eez_name      eventId eventType start               end                
#>    <chr> <chr>         <chr>   <chr>     <dttm>              <dttm>             
#>  1 8456  United States 6937c9… fishing   2020-01-25 13:58:44 2020-01-26 13:47:48
#>  2 8456  United States 90c53f… fishing   2020-01-30 23:49:26 2020-01-31 04:34:08
#>  3 8456  United States 6b4c28… fishing   2020-01-25 09:38:35 2020-01-25 10:34:01
#>  4 8456  United States 5ff972… fishing   2020-01-18 06:54:55 2020-01-18 07:29:56
#>  5 8456  United States 0b0e50… fishing   2020-01-25 12:32:16 2020-01-25 13:32:16
#>  6 8456  United States c5409b… fishing   2020-01-13 15:19:52 2020-01-13 17:47:54
#>  7 8456  United States 664001… fishing   2020-01-14 04:56:04 2020-01-14 08:13:47
#>  8 8456  United States 4fe0db… fishing   2020-01-17 18:15:20 2020-01-17 23:14:40
#>  9 8456  United States ea4db5… fishing   2020-01-13 20:43:47 2020-01-14 04:08:49
#> 10 8456  United States 873cf3… fishing   2020-01-05 15:00:22 2020-01-06 00:35:34
#> # ℹ 53 more rows
#> # ℹ 2 more variables: lat <dbl>, lon <dbl>
```
