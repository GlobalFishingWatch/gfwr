
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
#> 1 JEALSA RIANXEIRA ESP   306118000 <chr [1]>  2019-10-15T12:47:53Z 2023-09-15T1…
#> 2 JEALSA RIANXEIRA ESP   224224000 <chr [1]>  2015-10-13T16:06:33Z 2019-10-15T0…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 4 × 4
#>   dateFrom             dateTo               ssvid     sourceCode
#>   <chr>                <chr>                <chr>     <list>    
#> 1 2019-10-15T00:00:00Z 2023-02-01T00:00:00Z 306118000 <chr [1]> 
#> 2 2018-01-09T00:00:00Z 2019-10-24T00:00:00Z 224224000 <chr [1]> 
#> 3 2012-01-01T00:00:00Z 2019-01-01T00:00:00Z 224224000 <chr [1]> 
#> 4 2014-03-11T00:00:00Z 2016-07-28T00:00:00Z 224224000 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 2 × 9
#>   vesselId  geartypes_geartype_n…¹ geartypes_geartype_s…² geartypes_geartype_y…³
#>   <chr>     <chr>                  <chr>                                   <int>
#> 1 6632c9eb… PURSE_SEINE_SUPPORT    GFW_VESSEL_LIST                          2019
#> 2 3c99c326… PURSE_SEINE_SUPPORT    GFW_VESSEL_LIST                          2015
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
#> 1 FISHING CARGO SERVICES PAN   613590000 <chr [1]>  2022-01-24T09:16:50Z 2024-0…
#> 2 FISHING CARGO SERVICES PAN   214182732 <chr [1]>  2019-02-23T11:06:32Z 2022-0…
#> 3 FISHING CARGO SERVICES PAN   616852000 <chr [1]>  2014-01-04T11:52:41Z 2019-0…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 0 × 1
#> # ℹ 1 variable: <list> <list>
#> 
#> $combinedSourcesInfo
#> # A tibble: 3 × 9
#>   vesselId  geartypes_geartype_n…¹ geartypes_geartype_s…² geartypes_geartype_y…³
#>   <chr>     <chr>                  <chr>                                   <int>
#> 1 1da8dbc2… CARRIER                GFW_VESSEL_LIST                          2022
#> 2 58cf536b… CARRIER                GFW_VESSEL_LIST                          2012
#> 3 0b7047cb… CARRIER                GFW_VESSEL_LIST                          2019
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
#> 1                        2
#> 
#> $registryInfo
#> # A tibble: 2 × 15
#>   id                    sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <chr>                 <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1 a8d00ce54b37add7f85a… <chr [6]>  2106… CYP   FRIO FO… FRIOFORW… 5BWC3    9076…
#> 2 a8d00ce54b37add7f85a… <chr [2]>  2733… RUS   FRIO FO… FRIOFORW… UCRZ     9076…
#> # ℹ 7 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <list>, lengthM <int>, tonnageGt <int>,
#> #   vesselInfoReference <chr>
#> 
#> $registryOwners
#> # A tibble: 2 × 6
#>   name    flag  ssvid     sourceCode dateFrom             dateTo              
#>   <chr>   <chr> <chr>     <list>     <chr>                <chr>               
#> 1 COLINER CYP   210631000 <chr [1]>  2014-01-01T00:16:58Z 2024-01-31T23:49:09Z
#> 2 COLINER CYP   273379740 <chr [1]>  2015-02-27T10:59:43Z 2018-03-21T07:13:09Z
#> 
#> $registryPublicAuthorizations
#> # A tibble: 2 × 4
#>   dateFrom             dateTo               ssvid     sourceCode
#>   <chr>                <chr>                <chr>     <list>    
#> 1 2022-12-19T00:00:00Z 2024-02-01T00:00:00Z 210631000 <chr [1]> 
#> 2 2020-01-01T00:00:00Z 2024-02-01T00:00:00Z 210631000 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 2 × 9
#>   vesselId  geartypes_geartype_n…¹ geartypes_geartype_s…² geartypes_geartype_y…³
#>   <chr>     <chr>                  <chr>                                   <int>
#> 1 da1cd7e1… CARRIER                GFW_VESSEL_LIST                          2015
#> 2 8c730422… CARRIER                GFW_VESSEL_LIST                          2013
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
#> 2                        1
#> 3                        2
#> 
#> $registryInfo
#> # A tibble: 4 × 15
#>   id                    sourceCode ssvid flag  shipname nShipname callsign imo  
#>   <chr>                 <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
#> 1 b82d02e5c2c11e5fe536… <chr [5]>  4417… KOR   ADRIA    ADRIA     DTBY3    8919…
#> 2 685862e0626f6234c844… <chr [5]>  5480… PHL   JOHNREY… JOHNREYN… DUQA7    8118…
#> 3 a8d00ce54b37add7f85a… <chr [6]>  2106… CYP   FRIO FO… FRIOFORW… 5BWC3    9076…
#> 4 a8d00ce54b37add7f85a… <chr [2]>  2733… RUS   FRIO FO… FRIOFORW… UCRZ     9076…
#> # ℹ 7 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
#> #   transmissionDateTo <chr>, geartypes <list>, lengthM <dbl>, tonnageGt <dbl>,
#> #   vesselInfoReference <chr>
#> 
#> $registryOwners
#> # A tibble: 4 × 6
#>   name                          flag  ssvid     sourceCode dateFrom       dateTo
#>   <chr>                         <chr> <chr>     <list>     <chr>          <chr> 
#> 1 DONGWON INDUSTRIES            KOR   441734000 <chr [2]>  2014-01-18T19… 2023-…
#> 2 TRANS PACIFIC JOURNEY FISHING PHL   548012100 <chr [3]>  2017-02-07T00… 2019-…
#> 3 COLINER                       CYP   210631000 <chr [1]>  2014-01-01T00… 2024-…
#> 4 COLINER                       CYP   273379740 <chr [1]>  2015-02-27T10… 2018-…
#> 
#> $registryPublicAuthorizations
#> # A tibble: 6 × 4
#>   dateFrom             dateTo               ssvid     sourceCode
#>   <chr>                <chr>                <chr>     <list>    
#> 1 2013-09-20T00:00:00Z 2024-01-01T00:00:00Z 441734000 <chr [1]> 
#> 2 2015-10-08T00:00:00Z 2020-07-21T00:00:00Z 441734000 <chr [1]> 
#> 3 2012-01-01T00:00:00Z 2024-02-01T00:00:00Z 548012100 <chr [1]> 
#> 4 2012-01-01T00:00:00Z 2017-10-25T00:00:00Z 548012100 <chr [1]> 
#> 5 2022-12-19T00:00:00Z 2024-02-01T00:00:00Z 210631000 <chr [1]> 
#> 6 2020-01-01T00:00:00Z 2024-02-01T00:00:00Z 210631000 <chr [1]> 
#> 
#> $combinedSourcesInfo
#> # A tibble: 8 × 9
#>   vesselId  geartypes_geartype_n…¹ geartypes_geartype_s…² geartypes_geartype_y…³
#>   <chr>     <chr>                  <chr>                                   <int>
#> 1 6583c51e… TUNA_PURSE_SEINES      COMBINATION_OF_REGIST…                   2014
#> 2 6583c51e… TUNA_PURSE_SEINES      COMBINATION_OF_REGIST…                   2014
#> 3 6583c51e… OTHER                  COMBINATION_OF_REGIST…                   2013
#> 4 6583c51e… OTHER                  COMBINATION_OF_REGIST…                   2013
#> 5 71e7da67… TUNA_PURSE_SEINES      COMBINATION_OF_REGIST…                   2017
#> 6 55889aef… TUNA_PURSE_SEINES      COMBINATION_OF_REGIST…                   2017
#> 7 da1cd7e1… CARRIER                GFW_VESSEL_LIST                          2015
#> 8 8c730422… CARRIER                GFW_VESSEL_LIST                          2013
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
          key = key
          )
#> [1] "Downloading 34 events from GFW"
#> # A tibble: 34 × 14
#>    start               end                 id    type    lat    lon regions     
#>    <dttm>              <dttm>              <chr> <chr> <dbl>  <dbl> <list>      
#>  1 2020-01-05 04:58:45 2020-01-05 06:31:45 379d… fish…  43.7 -124.  <named list>
#>  2 2020-01-07 05:10:47 2020-01-07 08:57:13 72d1… fish…  28.1  -93.9 <named list>
#>  3 2020-01-08 19:39:55 2020-01-08 22:43:54 94fd… fish…  43.8 -124.  <named list>
#>  4 2020-01-09 12:30:54 2020-01-09 17:44:54 51c5… fish…  38.4  -73.5 <named list>
#>  5 2020-01-09 18:32:34 2020-01-09 19:20:15 2068… fish…  38.3  -73.6 <named list>
#>  6 2020-01-09 21:14:43 2020-01-10 10:16:36 c60e… fish…  38.1  -73.8 <named list>
#>  7 2020-01-10 12:35:22 2020-01-10 16:22:01 4f20… fish…  38.0  -73.9 <named list>
#>  8 2020-01-10 18:21:53 2020-01-12 03:13:04 6739… fish…  38.0  -73.9 <named list>
#>  9 2020-01-13 12:45:32 2020-01-13 15:38:38 46f8… fish…  38.0  -73.9 <named list>
#> 10 2020-01-13 13:20:55 2020-01-13 15:07:53 2333… fish…  43.7 -124.  <named list>
#> # ℹ 24 more rows
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

## Map Visualization API

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
- The `geojson` region or region code (such as an EEZ code) to filter
  the raster
- The source for the specified region (currently, `EEZ`, `MPA`, `RFMO`
  or `USER_JSON`)

### Examples

Here’s an example where we enter the geojson data manually:

``` r

region_json = '{"geojson":{"type":"Polygon","coordinates":[[[-76.11328125,-26.273714024406416],[-76.201171875,-26.980828590472093],[-76.376953125,-27.527758206861883],[-76.81640625,-28.30438068296276],[-77.255859375,-28.767659105691244],[-77.87109375,-29.152161283318918],[-78.486328125,-29.45873118535532],[-79.189453125,-29.61167011519739],[-79.892578125,-29.6880527498568],[-80.595703125,-29.61167011519739],[-81.5625,-29.382175075145277],[-82.177734375,-29.07537517955835],[-82.705078125,-28.6905876542507],[-83.232421875,-28.071980301779845],[-83.49609375,-27.683528083787756],[-83.759765625,-26.980828590472093],[-83.84765625,-26.35249785815401],[-83.759765625,-25.64152637306576],[-83.583984375,-25.16517336866393],[-83.232421875,-24.447149589730827],[-82.705078125,-23.966175871265037],[-82.177734375,-23.483400654325635],[-81.5625,-23.241346102386117],[-80.859375,-22.998851594142906],[-80.15625,-22.917922936146027],[-79.453125,-22.998851594142906],[-78.662109375,-23.1605633090483],[-78.134765625,-23.40276490540795],[-77.431640625,-23.885837699861995],[-76.9921875,-24.28702686537642],[-76.552734375,-24.846565348219727],[-76.2890625,-25.48295117535531],[-76.11328125,-26.273714024406416]]]}}'

get_raster(
  spatial_resolution = 'LOW',
  temporal_resolution = 'YEARLY',
  group_by = 'FLAG',
  date_range = '2021-01-01,2021-12-31',
  region = region_json,
  region_source = 'USER_JSON',
  key = key
  )
```

If you want raster data from a particular EEZ, you can use the
`get_region_id()` function to get the EEZ id, enter that code in the
`region` argument of `get_raster()` instead of the geojson data
(ensuring you specify the `region_source` as `'EEZ'`:

``` r
# use EEZ function to get EEZ code of Cote d'Ivoire
code_eez <- get_region_id(region_name = 'CIV', region_source = 'EEZ', key = key)

get_raster(spatial_resolution = 'LOW',
           temporal_resolution = 'YEARLY',
           group_by = 'FLAG',
           date_range = '2021-01-01,2021-10-01',
           region = code_eez$id,
           region_source = 'EEZ',
           key = key)
#> Rows: 611 Columns: 6
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): flag
#> dbl (5): Lat, Lon, Time Range, Vessel IDs, Apparent Fishing Hours
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 611 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1   4.7  -6.3         2021 CHN              1                    32.0 
#>  2   2.8  -5.7         2021 ESP              1                     0.17
#>  3   1.4  -6.9         2021 BLZ              1                     0.88
#>  4   4.4  -4.4         2021 SEN              1                     1.4 
#>  5   5.3  -4           2021 BES              4                    67.0 
#>  6   5.2  -4           2021 CHN              9                  6704.  
#>  7   4.6  -3.9         2021 SLV              2                     5.97
#>  8   4.6  -3.7         2021 BES              1                     0.27
#>  9   4.5  -4.1         2021 FRA              2                     3.64
#> 10   4.4  -4.2         2021 SEN              1                     0.97
#> # ℹ 601 more rows
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

# Let's say we're interested in the French Exclusive Economic Zone, 5677
get_raster(spatial_resolution = 'LOW',
           temporal_resolution = 'YEARLY',
           group_by = 'FLAG',
           date_range = '2021-01-01,2021-10-01',
           region = 5677,
           region_source = 'EEZ',
           key = key)
#> Rows: 5660 Columns: 6
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): flag
#> dbl (5): Lat, Lon, Time Range, Vessel IDs, Apparent Fishing Hours
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 5,660 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  42.6   9.5         2021 FRA              1                    26.3 
#>  2  47.5  -3.9         2021 FRA             79                  5129.  
#>  3  46.7  -3.1         2021 FRA             54                  1423.  
#>  4  45.8  -1.6         2021 FRA             27                   341.  
#>  5  45.1  -1.3         2021 FRA             30                   970.  
#>  6  44.8  -2.2         2021 FRA             23                   438.  
#>  7  45    -1.2         2021 FRA             17                   277.  
#>  8  44.7  -1.3         2021 FRA             26                  2384.  
#>  9  50.9   1.4         2021 FRA             30                   831.  
#> 10  50.8   1.3         2021 BEL              1                     5.92
#> # ℹ 5,650 more rows
```

A similar approach can be used to search for a specific Marine Protected
Area, in this case the Phoenix Island Protected Area (PIPA)

``` r
# use region id function to get MPA code of Phoenix Island Protected Area
code_mpa <- get_region_id(region_name = 'Phoenix', region_source = 'MPA', key = key)

get_raster(spatial_resolution = 'LOW',
           temporal_resolution = 'YEARLY',
           group_by = 'FLAG',
           date_range = '2015-01-01,2015-06-01',
           region = code_mpa$id[1],
           region_source = 'MPA',
           key = key)
#> Rows: 40 Columns: 6
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): flag
#> dbl (5): Lat, Lon, Time Range, Vessel IDs, Apparent Fishing Hours
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 40 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
#>  1  -4.7 -176.         2015 KIR              1                     0.36
#>  2  -3.7 -173.         2015 KOR              1                     1.49
#>  3  -3.9 -173.         2015 KOR              1                     0.01
#>  4  -2.3 -176.         2015 TWN              1                    10.8 
#>  5  -2.3 -176.         2015 TWN              1                     1.71
#>  6  -2.9 -176.         2015 FSM              1                     2.77
#>  7  -3.9 -176.         2015 KOR              1                     4.88
#>  8  -4   -176.         2015 KOR              1                     1.37
#>  9  -4.1 -176.         2015 KOR              1                     2.67
#> 10  -1.7 -172.         2015 KOR              1                     0.78
#> # ℹ 30 more rows
```

It is also possible to filter rasters to one of the five regional
fisheries management organizations (RFMO) that manage tuna and tuna-like
species. These include `"ICCAT"`, `"IATTC"`,`"IOTC"`, `"CCSBT"` and
`"WCPFC"`.

``` r
get_raster(spatial_resolution = 'LOW',
           temporal_resolution = 'DAILY',
           group_by = 'FLAG',
           date_range = '2021-01-01,2021-01-15',
           region = 'ICCAT',
           region_source = 'RFMO',
           key = key)
#> Rows: 117094 Columns: 6
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr  (1): flag
#> dbl  (4): Lat, Lon, Vessel IDs, Apparent Fishing Hours
#> date (1): Time Range
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 117,094 × 6
#>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
#>    <dbl> <dbl> <date>       <chr>        <dbl>                    <dbl>
#>  1  68.7 -51.4 2021-01-08   GRL              1                     0.25
#>  2  68.8 -51.2 2021-01-05   GRL              1                     4.78
#>  3  68.8 -51.2 2021-01-04   GRL              2                     0.73
#>  4  28.4 -96   2021-01-03   USA              1                     4.35
#>  5  28.5 -95.8 2021-01-09   USA              1                     5.27
#>  6  28.5 -95.7 2021-01-03   USA              5                    20.3 
#>  7  28.5 -95.7 2021-01-09   USA              1                     2.93
#>  8  28.5 -95.7 2021-01-11   USA              1                     4.05
#>  9  28.5 -95.6 2021-01-09   USA              1                     0.32
#> 10  28.4 -95.9 2021-01-03   USA              3                     7.05
#> # ℹ 117,084 more rows
```

The `get_region_id()` function also works in reverse. If a region id is
passed as a `numeric` to the function as the `region_name`, the
corresponding region label or iso3 can be returned. This is especially
useful when events are returned with regions.

``` r
# using same example as above
get_event(event_type = 'FISHING',
          vessels = usa_trawler_ids,
          start_date = "2020-01-01",
          end_date = "2020-02-01",
          include_regions = TRUE,
          key = key
          ) %>%
  # extract EEZ id code
  dplyr::mutate(eez = as.character(purrr::map(purrr::map(regions, purrr::pluck, 'eez'),
                                              paste0, collapse = ','))) %>%
  dplyr::select(id, type, start, end, lat, lon, eez) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(eez_name = get_region_id(region_name = as.numeric(eez),
                                         region_source = 'EEZ',
                                         key = key)$label)
#> [1] "Downloading 34 events from GFW"
#> # A tibble: 34 × 8
#> # Rowwise: 
#>    id           type  start               end                   lat    lon eez  
#>    <chr>        <chr> <dttm>              <dttm>              <dbl>  <dbl> <chr>
#>  1 379d452b49e… fish… 2020-01-05 04:58:45 2020-01-05 06:31:45  43.7 -124.  8456 
#>  2 72d1e4f6bf3… fish… 2020-01-07 05:10:47 2020-01-07 08:57:13  28.1  -93.9 8456 
#>  3 94fdf957151… fish… 2020-01-08 19:39:55 2020-01-08 22:43:54  43.8 -124.  8456 
#>  4 51c5140b261… fish… 2020-01-09 12:30:54 2020-01-09 17:44:54  38.4  -73.5 8456 
#>  5 2068a73ed9b… fish… 2020-01-09 18:32:34 2020-01-09 19:20:15  38.3  -73.6 8456 
#>  6 c60e52370d4… fish… 2020-01-09 21:14:43 2020-01-10 10:16:36  38.1  -73.8 8456 
#>  7 4f20b44a59b… fish… 2020-01-10 12:35:22 2020-01-10 16:22:01  38.0  -73.9 8456 
#>  8 6739137b68e… fish… 2020-01-10 18:21:53 2020-01-12 03:13:04  38.0  -73.9 8456 
#>  9 46f8debd1e5… fish… 2020-01-13 12:45:32 2020-01-13 15:38:38  38.0  -73.9 8456 
#> 10 23330ffa0e1… fish… 2020-01-13 13:20:55 2020-01-13 15:07:53  43.7 -124.  8456 
#> # ℹ 24 more rows
#> # ℹ 1 more variable: eez_name <chr>
```

## Contributing

We welcome all contributions to improve the package! Please read our
[Contribution
Guide](https://github.com/GlobalFishingWatch/gfwr/blob/main/Contributing.md)
and reach out!
