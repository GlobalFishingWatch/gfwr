
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `gfwr`: Access data from Global Fishing Watch APIs <img src="man/figures/gfwr_hex_rgb.png" align="right" width="200px"/>

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/450635054.svg)](https://zenodo.org/badge/latestdoi/450635054)
[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Licence](https://img.shields.io/badge/license-Apache%202-blue)](https://opensource.org/licenses/Apache-2.0)
<!-- badges: end -->

The `gfwr` R package is a simple wrapper for the Global Fishing Watch
(GFW)
[APIs](https://globalfishingwatch.org/our-apis/documentation#introduction).
It provides convenient functions to freely pull GFW data directly into R
in tidy formats.

The package currently works with the following APIs:

- [Vessels
  API](https://globalfishingwatch.org/our-apis/documentation#vessels-api):
  vessel search and identity based on AIS self reported data
- [Events
  API](https://globalfishingwatch.org/our-apis/documentation#events-api):
  encounters, loitering, port visits and fishing events based on AIS
  data
- [Map Visualization (4Wings
  API)](https://globalfishingwatch.org/our-apis/documentation#map-visualization-4wings-api):
  apparent fishing effort based on AIS data

> **Note**: See the [Terms of
> Use](https://globalfishingwatch.org/our-apis/documentation#reference-data)
> page for GFW APIs for information on our API licenses and rate limits.

## Installation

You can install the development version of `gfwr` like so:

``` r
# Check/install remotes
if (!require("remotes"))
  install.packages("remotes")

remotes::install_github("GlobalFishingWatch/gfwr")
```

Once everything is installed, you can load and use `gfwr` in your
scripts with `library(gfwr)`

``` r
library(gfwr)
```

## Authorization

The use of `gfwr` requires a GFW API token, which users can request from
the [GFW API Portal](https://globalfishingwatch.org/our-apis/tokens).
Save this token to your `.Renviron` file (using
`usethis::edit_r_environ()`) by adding a variable named `GFW_TOKEN` to
the file (`GFW_TOKEN = "PASTE_YOUR_TOKEN_HERE"`). Save the `.Renviron`
file and restart the R session to make the edit effective.

Then use the `gfw_auth()` helper function to save the information to an
object in your R workspace every time you need to extract the token and
pass it to subsequent `gfwr` functions.

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
  and `where` for advanced searchers using SQL.
  - `query` takes a single identifier that can be the MMSI, IMO,
    callsign, or shipname as input and identifies all vessels that
    match.
  - `where` search allows for the use of fuzzy matching with terms such
    as LIKE.
  - `includes` adds new information regarding the vessels. Options are
    “MATCH_CRITERIA”, “OWNERSHIP” and “AUTHORIZATIONS”

### Examples

To get information of a vessel with `MMSI = 224224000`:

``` r
get_vessel_info(query = 224224000,
                search_type = "search",
                key = key)
#> $dataset
#> # A tibble: 1 × 1
#>   dataset                                
#>   <chr>                                  
#> 1 public-global-vessel-identity:v20231026
#> 
#> $registryInfoTotalRecords
#> # A tibble: 1 × 1
#>   registryInfoTotalRecords
#>                      <int>
#> 1                        1
#> 
#> $registryInfo
#> # A tibble: 1 × 15
#>   id                    sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <chr>                 <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1 e0c9823749264a129d6b… <chr [6]>  2242… ESP   AGURTZA… AGURTZAB… EBSJ     8733…
#> # ℹ 7 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <list>, lengthM <dbl>, tonnageGt <int>,
#> #   vesselInfoReference <chr>
#> 
#> $registryOwners
#> # A tibble: 2 × 6
#>   name             flag  ssvid     sourceCode dateFrom             dateTo       
#>   <chr>            <chr> <chr>     <list>     <chr>                <chr>        
#> 1 JEALSA RIANXEIRA ESP   306118000 <chr [1]>  2019-10-15T12:47:53Z 2023-07-02T2…
#> 2 JEALSA RIANXEIRA ESP   224224000 <chr [1]>  2015-10-13T16:06:33Z 2019-10-15T0…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 0 × 1
#> # ℹ 1 variable: <list> <list>
#> 
#> $combinedSourcesInfo
#> # A tibble: 2 × 9
#>   vesselId  geartypes_geartype_n…¹ geartypes_geartype_s…² geartypes_geartype_y…³
#>   <chr>     <chr>                  <chr>                                   <int>
#> 1 3c99c326… PURSE_SEINE_SUPPORT    GFW_VESSEL_LIST                          2015
#> 2 6632c9eb… PURSE_SEINE_SUPPORT    GFW_VESSEL_LIST                          2019
#> # ℹ abbreviated names: ¹​geartypes_geartype_name, ²​geartypes_geartype_source,
#> #   ³​geartypes_geartype_yearFrom
#> # ℹ 5 more variables: geartypes_geartype_yearTo <int>,
#> #   shiptypes_shiptype_name <chr>, shiptypes_shiptype_source <chr>,
#> #   shiptypes_shiptype_yearFrom <int>, shiptypes_shiptype_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 0 × 0
```

To combine different fields and do fuzzy matching :

``` r
get_vessel_info(where = "shipname LIKE '%GABU REEFE%' OR imo = '8300949'",
                search_type = "search",
                key = key)
#> $dataset
#> # A tibble: 1 × 1
#>   dataset                                
#>   <chr>                                  
#> 1 public-global-vessel-identity:v20231026
#> 
#> $registryInfoTotalRecords
#> # A tibble: 1 × 1
#>   registryInfoTotalRecords
#>                      <int>
#> 1                        1
#> 
#> $registryInfo
#> # A tibble: 1 × 15
#>   id                    sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <chr>                 <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1 b16ca93ea690fc725e92… <chr [2]>  6135… CMR   GABU RE… GABUREEF… TJMC996  8300…
#> # ℹ 7 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <list>, lengthM <dbl>, tonnageGt <int>,
#> #   vesselInfoReference <chr>
#> 
#> $registryOwners
#> # A tibble: 3 × 6
#>   name                   flag  ssvid     sourceCode dateFrom             dateTo 
#>   <chr>                  <chr> <chr>     <list>     <chr>                <chr>  
#> 1 FISHING CARGO SERVICES PAN   613590000 <chr [1]>  2022-01-24T09:16:50Z 2023-0…
#> 2 FISHING CARGO SERVICES PAN   214182732 <chr [1]>  2019-02-23T11:06:32Z 2022-0…
#> 3 FISHING CARGO SERVICES PAN   616852000 <chr [1]>  2013-01-02T16:58:26Z 2019-0…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 0 × 1
#> # ℹ 1 variable: <list> <list>
#> 
#> $combinedSourcesInfo
#> # A tibble: 3 × 9
#>   vesselId  geartypes_geartype_n…¹ geartypes_geartype_s…² geartypes_geartype_y…³
#>   <chr>     <chr>                  <chr>                                   <int>
#> 1 58cf536b… CARRIER                GFW_VESSEL_LIST                          2012
#> 2 0b7047cb… CARRIER                GFW_VESSEL_LIST                          2019
#> 3 1da8dbc2… CARRIER                GFW_VESSEL_LIST                          2022
#> # ℹ abbreviated names: ¹​geartypes_geartype_name, ²​geartypes_geartype_source,
#> #   ³​geartypes_geartype_yearFrom
#> # ℹ 5 more variables: geartypes_geartype_yearTo <int>,
#> #   shiptypes_shiptype_name <chr>, shiptypes_shiptype_source <chr>,
#> #   shiptypes_shiptype_yearFrom <int>, shiptypes_shiptype_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 0 × 0
```

- The `id` search allows the user to specify a vector of `vessel id`

> **Note**: `vessel id` is an internal ID generated by GFW to connect
> data accross APIs and involves a combination of vessel and tracking
> data information. It can be retrieved using `get_vessel_info()` as
> shown above.

To search using `vessel id`:

``` r
get_vessel_info(ids = "8c7304226-6c71-edbe-0b63-c246734b3c01",
                search_type = "id",
                key = key)
#> $dataset
#> # A tibble: 1 × 1
#>   dataset                                
#>   <chr>                                  
#> 1 public-global-vessel-identity:v20231026
#> 
#> $registryInfoTotalRecords
#> # A tibble: 1 × 1
#>   registryInfoTotalRecords
#>                      <int>
#> 1                        3
#> 
#> $registryInfo
#> # A tibble: 3 × 15
#>   id                    sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <chr>                 <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1 a8d00ce54b37add7f85a… <chr [5]>  2106… CYP   FRIO FO… FRIOFORW… 5BWC3    9076…
#> 2 a8d00ce54b37add7f85a… <chr [2]>  2733… RUS   FRIO FO… FRIOFORW… UCRZ     9076…
#> 3 a8d00ce54b37add7f85a… <chr [2]>  3546… PAN   FRIO AE… FRIOAEGE… 3FGY4    9076…
#> # ℹ 7 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <list>, lengthM <int>, tonnageGt <int>,
#> #   vesselInfoReference <chr>
#> 
#> $registryOwners
#> # A tibble: 2 × 6
#>   name    flag  ssvid     sourceCode dateFrom             dateTo              
#>   <chr>   <chr> <chr>     <list>     <chr>                <chr>               
#> 1 COLINER CYP   210631000 <chr [1]>  2013-05-15T20:19:43Z 2023-08-31T23:45:29Z
#> 2 COLINER CYP   273379740 <chr [1]>  2015-02-27T10:59:43Z 2018-03-21T07:13:09Z
#> 
#> $registryPublicAuthorizations
#> # A tibble: 2 × 4
#>   dateFrom             dateTo               ssvid     sourceCode
#>   <chr>                <chr>                <chr>     <list>    
#> 1 2022-12-19T00:00:00Z 2023-09-01T00:00:00Z 210631000 <chr [1]> 
#> 2 2020-01-01T00:00:00Z 2023-09-01T00:00:00Z 210631000 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 3 × 9
#>   vesselId  geartypes_geartype_n…¹ geartypes_geartype_s…² geartypes_geartype_y…³
#>   <chr>     <chr>                  <chr>                                   <int>
#> 1 0cb77880… CARRIER                GFW_VESSEL_LIST                          2012
#> 2 da1cd7e1… CARRIER                GFW_VESSEL_LIST                          2015
#> 3 8c730422… CARRIER                GFW_VESSEL_LIST                          2013
#> # ℹ abbreviated names: ¹​geartypes_geartype_name, ²​geartypes_geartype_source,
#> #   ³​geartypes_geartype_yearFrom
#> # ℹ 5 more variables: geartypes_geartype_yearTo <int>,
#> #   shiptypes_shiptype_name <chr>, shiptypes_shiptype_source <chr>,
#> #   shiptypes_shiptype_yearFrom <int>, shiptypes_shiptype_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 0 × 0
```

To specify more than one `vessel id`, you can submit a vector of
identifiers:

``` r
get_vessel_info(ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01",
                        "6583c51e3-3626-5638-866a-f47c3bc7ef7c",
                        "71e7da672-2451-17da-b239-857831602eca"),
                search_type = 'id',
                key = key)
#> $dataset
#> # A tibble: 3 × 1
#>   dataset                                
#>   <chr>                                  
#> 1 public-global-vessel-identity:v20231026
#> 2 public-global-vessel-identity:v20231026
#> 3 public-global-vessel-identity:v20231026
#> 
#> $registryInfoTotalRecords
#> # A tibble: 3 × 1
#>   registryInfoTotalRecords
#>                      <int>
#> 1                        1
#> 2                        2
#> 3                        3
#> 
#> $registryInfo
#> # A tibble: 6 × 15
#>   id                    sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <chr>                 <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1 685862e0626f6234c844… <chr [5]>  5480… PHL   JOHNREY… JOHNREYN… DUQA7    8118…
#> 2 b82d02e5c2c11e5fe536… <chr [5]>  4417… KOR   ADRIA    ADRIA     DTBY3    8919…
#> 3 b82d02e5c2c11e5fe536… <chr [4]>  4417… KOR   PREMIER  PREMIER   DTBY3    8919…
#> 4 a8d00ce54b37add7f85a… <chr [5]>  2106… CYP   FRIO FO… FRIOFORW… 5BWC3    9076…
#> 5 a8d00ce54b37add7f85a… <chr [2]>  2733… RUS   FRIO FO… FRIOFORW… UCRZ     9076…
#> 6 a8d00ce54b37add7f85a… <chr [2]>  3546… PAN   FRIO AE… FRIOAEGE… 3FGY4    9076…
#> # ℹ 7 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <list>, lengthM <dbl>, tonnageGt <dbl>,
#> #   vesselInfoReference <chr>
#> 
#> $registryOwners
#> # A tibble: 5 × 6
#>   name                          flag  ssvid     sourceCode dateFrom       dateTo
#>   <chr>                         <chr> <chr>     <list>     <chr>          <chr> 
#> 1 TRANS PACIFIC JOURNEY FISHING PHL   548012100 <chr [3]>  2017-02-07T00… 2019-…
#> 2 DONGWON INDUSTRIES            KOR   441734000 <chr [2]>  2013-09-02T04… 2023-…
#> 3 DONG WON INDUSTRIES           KOR   441734000 <chr [1]>  2013-01-13T17… 2013-…
#> 4 COLINER                       CYP   210631000 <chr [1]>  2013-05-15T20… 2023-…
#> 5 COLINER                       CYP   273379740 <chr [1]>  2015-02-27T10… 2018-…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 7 × 4
#>   dateFrom             dateTo               ssvid     sourceCode
#>   <chr>                <chr>                <chr>     <list>    
#> 1 2012-01-01T00:00:00Z 2023-09-01T00:00:00Z 548012100 <chr [1]> 
#> 2 2012-01-01T00:00:00Z 2017-10-25T00:00:00Z 548012100 <chr [1]> 
#> 3 2013-09-20T00:00:00Z 2023-09-01T00:00:00Z 441734000 <chr [1]> 
#> 4 2013-07-17T00:00:00Z 2020-07-21T00:00:00Z 441734000 <chr [1]> 
#> 5 2012-01-01T00:00:00Z 2013-09-19T00:00:00Z 441734000 <chr [1]> 
#> 6 2022-12-19T00:00:00Z 2023-09-01T00:00:00Z 210631000 <chr [1]> 
#> 7 2020-01-01T00:00:00Z 2023-09-01T00:00:00Z 210631000 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 10 × 9
#>    vesselId geartypes_geartype_n…¹ geartypes_geartype_s…² geartypes_geartype_y…³
#>    <chr>    <chr>                  <chr>                                   <int>
#>  1 55889ae… TUNA_PURSE_SEINES      COMBINATION_OF_REGIST…                   2017
#>  2 71e7da6… TUNA_PURSE_SEINES      COMBINATION_OF_REGIST…                   2017
#>  3 6583c51… TUNA_PURSE_SEINES      COMBINATION_OF_REGIST…                   2013
#>  4 aca119c… OTHER                  COMBINATION_OF_REGIST…                   2012
#>  5 aca119c… OTHER                  COMBINATION_OF_REGIST…                   2012
#>  6 aca119c… TUNA_PURSE_SEINES      COMBINATION_OF_REGIST…                   2013
#>  7 aca119c… TUNA_PURSE_SEINES      COMBINATION_OF_REGIST…                   2013
#>  8 0cb7788… CARRIER                GFW_VESSEL_LIST                          2012
#>  9 da1cd7e… CARRIER                GFW_VESSEL_LIST                          2015
#> 10 8c73042… CARRIER                GFW_VESSEL_LIST                          2013
#> # ℹ abbreviated names: ¹​geartypes_geartype_name, ²​geartypes_geartype_source,
#> #   ³​geartypes_geartype_yearFrom
#> # ℹ 5 more variables: geartypes_geartype_yearTo <int>,
#> #   shiptypes_shiptype_name <chr>, shiptypes_shiptype_source <chr>,
#> #   shiptypes_shiptype_yearFrom <int>, shiptypes_shiptype_yearTo <int>
#> 
#> $selfReportedInfo
#> # A tibble: 0 × 0
```

Check the function documentation for examples about the other argument
options.

## Events API

The `get_event()` function allows you to get data on specific vessel
activities from the [GFW Events
API](https://globalfishingwatch.org/our-apis/documentation#events-api).
Event types include apparent fishing events, potential transshipment
events (two-vessel encounters and loitering by refrigerated carrier
vessels), port visits, and AIS-disabling events (“gaps”). Find more
information in our [caveat
documentation](https://globalfishingwatch.org/our-apis/documentation#data-caveat).

### Examples

Let’s say that you don’t know the `vessel id` but you have the MMSI (or
other identity information). You can use `get_vessel_info()` function
first to extract `vessel id` and then use it in the `get_event()`
function:

``` r
vessel_id <- get_vessel_info(query = 224224000, key = key)
id <- vessel_id$registryInfo$id
```

To get a list of port visits for that vessel:

``` r
get_event(event_type = 'PORT_VISIT',
          vessels = id,
          confidences = 4,
          key = key
          )
#> [1] "Your request returned zero results"
#> NULL
```

We can also use more than one `vessel id`:

``` r
get_event(event_type = 'PORT_VISIT',
          vessels = c('8c7304226-6c71-edbe-0b63-c246734b3c01', '6583c51e3-3626-5638-866a-f47c3bc7ef7c'),
          confidences = 4,
          start_date = "2020-01-01",
          end_date = "2020-02-01",
          key = key
          )
#> [1] "Downloading 3 events from GFW"
#> # A tibble: 3 × 14
#>   start               end                 id      type    lat   lon regions     
#>   <dttm>              <dttm>              <chr>   <chr> <dbl> <dbl> <list>      
#> 1 2019-12-19 23:05:31 2020-01-24 19:05:18 7cd1e3… port…  28.1 -15.4 <named list>
#> 2 2020-01-26 05:52:47 2020-01-29 14:39:33 c2f096… port…  20.8 -17.0 <named list>
#> 3 2020-01-31 02:20:08 2020-02-03 15:56:31 7c06e4… port…  28.1 -15.4 <named list>
#> # ℹ 7 more variables: eez <list>, rfmo <list>, fao <list>, boundingBox <list>,
#> #   distances <list>, vessel <list>, event_info <list>
```

Or get encounters for all vessels in a given date range:

``` r
get_event(event_type = 'ENCOUNTER',
          start_date = "2020-01-01",
          end_date = "2020-01-02",
          key = key
          )
#> [1] "Downloading 250 events from GFW"
#> # A tibble: 250 × 14
#>    start               end                 id    type    lat    lon regions     
#>    <dttm>              <dttm>              <chr> <chr> <dbl>  <dbl> <list>      
#>  1 2019-12-17 14:10:00 2020-01-02 04:10:00 8c07… enco… 67.5    15.5 <named list>
#>  2 2019-12-17 14:10:00 2020-01-02 04:10:00 8c07… enco… 67.5    15.5 <named list>
#>  3 2019-12-26 00:20:00 2020-01-07 23:50:00 59d4… enco… -1.82 -113.  <named list>
#>  4 2019-12-26 00:20:00 2020-01-07 23:50:00 59d4… enco… -1.82 -113.  <named list>
#>  5 2019-12-26 14:10:00 2020-01-03 05:30:00 60c1… enco… -1.79 -113.  <named list>
#>  6 2019-12-26 14:10:00 2020-01-03 05:30:00 60c1… enco… -1.79 -113.  <named list>
#>  7 2019-12-27 09:10:00 2020-01-06 14:00:00 2159… enco…  9.50  -99.1 <named list>
#>  8 2019-12-27 09:10:00 2020-01-06 14:00:00 2159… enco…  9.50  -99.1 <named list>
#>  9 2019-12-30 02:20:00 2020-01-13 05:40:00 87de… enco… -1.84 -111.  <named list>
#> 10 2019-12-30 02:20:00 2020-01-13 05:40:00 87de… enco… -1.84 -111.  <named list>
#> # ℹ 240 more rows
#> # ℹ 7 more variables: eez <list>, rfmo <list>, fao <list>, boundingBox <list>,
#> #   distances <list>, vessel <list>, event_info <list>
```

When a date range is provided to `get_event()` using both `start_date`
and `end_date`, any event overlapping that range will be returned,
including events that start prior to `start_date` or end after
`end_date`. If just `start_date` or `end_date` are provided, results
will include all events that end after `start_date` or begin prior to
`end_date`, respectively.

> *Note*: Because encounter events are events between two vessels, a
> single event will be represented twice in the data, once for each
> vessel. To capture this information and link the related data rows,
> the `id` field for encounter events includes an additional suffix (1
> or 2) separated by a period. The `vessel` field will also contain
> different information specific to each vessel.

As another example, let’s combine the Vessels and Events APIs to get
fishing events for a list of 20 USA-flagged trawlers:

``` r
# Download the list of USA trawlers
usa_trawlers <- get_vessel_info(
  where = "flag='USA' AND geartypes='TRAWLERS'",
  search_type = "search",
  key = key, 
  print_request = TRUE
)
#> https://gateway.api.globalfishingwatch.org/v3/vessels/search?where=flag%3D%27USA%27%20AND%20geartypes%3D%27TRAWLERS%27&datasets%5B0%5D=public-global-vessel-identity%3Alatest&includes%5B0%5D=AUTHORIZATIONS&includes%5B1%5D=OWNERSHIP&includes%5B2%5D=MATCH_CRITERIANULLlist()NULLlist()list()list()
# Pass the vector of vessel ids to Events API
usa_trawler_ids <- usa_trawlers$combinedSourcesInfo$vesselId[1:20]
```

> *Note*: `get_event()` can receive up to 20 vessel ids at a time

Now get the list of fishing events for these trawlers in January, 2020:

``` r
get_event(event_type = 'FISHING',
          vessels = usa_trawler_ids,
          start_date = "2020-01-01",
          end_date = "2020-02-01",
          key = key, 
          print_request = TRUE
          )
#> <httr2_request>
#> GET
#> https://gateway.api.globalfishingwatch.org/v3/events?datasets%5B0%5D=public-global-fishing-events%3Alatest&limit=99999&offset=0&start-date=2020-01-01&end-date=2020-02-01&vessels%5B0%5D=c698dfcc5-5c85-9329-b1ac-8b3656ea9233&vessels%5B1%5D=64907178b-b02a-f401-afa1-b3a099d7a142&vessels%5B2%5D=64907178b-b02a-f401-afa1-b3a099d7a142&vessels%5B3%5D=64907178b-b02a-f401-afa1-b3a099d7a142&vessels%5B4%5D=64907178b-b02a-f401-afa1-b3a099d7a142&vessels%5B5%5D=242fa3fbf-fa03-eb47-5855-f0880b8e7acf&vessels%5B6%5D=15cea26f5-57ad-acac-4cbf-b45cefb7ab04&vessels%5B7%5D=9f5552145-50ed-92f4-4514-5177b1a6511d&vessels%5B8%5D=bc29946f2-2b0b-9613-054a-cd59327226d9&vessels%5B9%5D=8d68317d6-6610-59c4-c99a-ef4cd41acd1a&vessels%5B10%5D=0dddd2a83-3626-24f1-0fe6-3c4d45bbb409&vessels%5B11%5D=0dddd2a83-3626-24f1-0fe6-3c4d45bbb409&vessels%5B12%5D=0dddd2a83-3626-24f1-0fe6-3c4d45bbb409&vessels%5B13%5D=0dddd2a83-3626-24f1-0fe6-3c4d45bbb409&vessels%5B14%5D=695b254f7-7e6c-ff50-dc63-55139d9e0101&vessels%5B15%5D=0108b3937-772f-d55b-aeb7-1c6113ac1722&vessels%5B16%5D=d481fe954-496a-f7fb-704a-6813d3f80a33&vessels%5B17%5D=558f4982d-dabe-e259-28fc-ea981c35ba03&vessels%5B18%5D=9417d951e-eb3e-3420-fd0a-6af9744d2797&vessels%5B19%5D=1cabdf828-80d6-1456-b8ec-bef9e3144ace
#> Body: empty
#> https://gateway.api.globalfishingwatch.org/v3/events?datasets%5B0%5D=public-global-fishing-events%3Alatest&limit=99999&offset=0&start-date=2020-01-01&end-date=2020-02-01&vessels%5B0%5D=c698dfcc5-5c85-9329-b1ac-8b3656ea9233&vessels%5B1%5D=64907178b-b02a-f401-afa1-b3a099d7a142&vessels%5B2%5D=64907178b-b02a-f401-afa1-b3a099d7a142&vessels%5B3%5D=64907178b-b02a-f401-afa1-b3a099d7a142&vessels%5B4%5D=64907178b-b02a-f401-afa1-b3a099d7a142&vessels%5B5%5D=242fa3fbf-fa03-eb47-5855-f0880b8e7acf&vessels%5B6%5D=15cea26f5-57ad-acac-4cbf-b45cefb7ab04&vessels%5B7%5D=9f5552145-50ed-92f4-4514-5177b1a6511d&vessels%5B8%5D=bc29946f2-2b0b-9613-054a-cd59327226d9&vessels%5B9%5D=8d68317d6-6610-59c4-c99a-ef4cd41acd1a&vessels%5B10%5D=0dddd2a83-3626-24f1-0fe6-3c4d45bbb409&vessels%5B11%5D=0dddd2a83-3626-24f1-0fe6-3c4d45bbb409&vessels%5B12%5D=0dddd2a83-3626-24f1-0fe6-3c4d45bbb409&vessels%5B13%5D=0dddd2a83-3626-24f1-0fe6-3c4d45bbb409&vessels%5B14%5D=695b254f7-7e6c-ff50-dc63-55139d9e0101&vessels%5B15%5D=0108b3937-772f-d55b-aeb7-1c6113ac1722&vessels%5B16%5D=d481fe954-496a-f7fb-704a-6813d3f80a33&vessels%5B17%5D=558f4982d-dabe-e259-28fc-ea981c35ba03&vessels%5B18%5D=9417d951e-eb3e-3420-fd0a-6af9744d2797&vessels%5B19%5D=1cabdf828-80d6-1456-b8ec-bef9e3144aceNULLlist()NULLlist()list()list()
#> [1] "Downloading 33 events from GFW"
#> # A tibble: 33 × 14
#>    start               end                 id    type    lat    lon regions     
#>    <dttm>              <dttm>              <chr> <chr> <dbl>  <dbl> <list>      
#>  1 2020-01-05 04:58:45 2020-01-05 06:31:45 379d… fish…  43.7 -124.  <named list>
#>  2 2020-01-08 19:39:55 2020-01-08 22:43:54 94fd… fish…  43.8 -124.  <named list>
#>  3 2020-01-09 12:30:54 2020-01-09 17:44:54 51c5… fish…  38.4  -73.5 <named list>
#>  4 2020-01-09 18:32:34 2020-01-09 19:20:15 2068… fish…  38.3  -73.6 <named list>
#>  5 2020-01-09 21:14:43 2020-01-10 10:16:36 c60e… fish…  38.1  -73.8 <named list>
#>  6 2020-01-10 12:35:22 2020-01-10 16:22:01 4f20… fish…  38.0  -73.9 <named list>
#>  7 2020-01-10 18:21:53 2020-01-12 03:13:04 6739… fish…  38.0  -73.9 <named list>
#>  8 2020-01-13 12:45:32 2020-01-13 15:38:38 46f8… fish…  38.0  -73.9 <named list>
#>  9 2020-01-13 13:20:55 2020-01-13 15:07:53 2333… fish…  43.7 -124.  <named list>
#> 10 2020-01-13 17:38:55 2020-01-13 21:52:25 ca7e… fish…  38.0  -73.9 <named list>
#> # ℹ 23 more rows
#> # ℹ 7 more variables: eez <list>, rfmo <list>, fao <list>, boundingBox <list>,
#> #   distances <list>, vessel <list>, event_info <list>
```

When no events are available, the `get_event()` function returns
nothing.

``` r
get_event(event_type = 'FISHING',
          vessels = usa_trawler_ids[2],
          start_date = "2020-01-01",
          end_date = "2020-01-01",
          key = key
          )
#> [1] "Your request returned zero results"
#> NULL
```

``` r
knitr::knit_exit()
```
