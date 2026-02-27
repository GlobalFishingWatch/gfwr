# Using \`gfw_vessel_info()\`: the basics of vessel identity in Global Fishing Watch and \`gfwr\`

``` r
library(gfwr)
```

``` r
library(dplyr)
library(tidyr)
```

This vignette explains the use of
[`gfw_vessel_info()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_vessel_info.md)
as a key function to understand vessel identity and to use all the other
Global Fishing Watch API endpoints.

We discuss basic identity markers, why Vessel ID was created, the
structure of the
[`gfw_vessel_info()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_vessel_info.md)
response and how to get **`vesselId`** for use in the functions
[`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
and
[`gfw_event_stats()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event_stats.md).

### Automatic Identification System (AIS)

The Automatic Identification System (AIS) is an automatic tracking
system originally developed to help preventing collisions between
vessels at sea. Vessels broadcast AIS to alert other vessels of their
presence, but terrestrial and satellite receivers can also receive these
messages and monitor vessel movements. AIS is at the core of Global
Fishing Watch analysis pipelines, including the AIS-based fishing effort
calculation displayed on our map and available through function
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
in `gfwr`.

AIS messages include identity information about the vessel, such as ship
name, call sign, and International Maritime Organization (IMO) number,
as well as an identifier known as the Maritime Mobile Service Identity
(MMSI).

- **MMSI** are nine-digit numbers broadcasted in AIS messages. MMSIs are
  supposed to be unique for each vessel, but 1. a vessel can change
  MMSIs throughout its lifecycle–for example when it’s reflagged,
  because the first three digits refer to the flag country 2. several
  vessels can broadcast the same MMSI at the same time. This happens for
  many reasons, including the fact that data entry in AIS messages is
  manual.

- **Shipname** and **callsign** can be also transmitted in AIS messages
  but they are optional, not every AIS-broadcasting vessel transmits
  them, and their transmission can be inconsistent. Shipnames can also
  vary a lot in their spelling, requiring some fuzzy matching to detect
  if they refer to the same vessel.

- **IMO numbers** are permanent unique identifiers that follow a vessel
  from construction to scrapping. Assigned by the International Maritime
  Organization, IMO numbers are required for only a subset of industrial
  fishing vessels. IMO number can be transmitted along with MMSI in AIS
  messages but they are frequently missing.

These identity markers are often the starting point of any inquiry
around vessel identity. However, due to their characteristics, none of
these identifiers should be interpreted as the sole identity source for
a vessel. Global Fishing Watch does extensive work to analyze and gather
all the information available for a given vessel into cohesive sets.

> **Note:** MMSI is referred to as `ssvid` in our tables. `ssvid` stands
> for “source-specific vessel identity”. In this case, the source is
> AIS, and ssvid = MMSI.

### **`vesselId`**

To solve the complexity of having several vessel identifiers that can be
duplicated or missing for each vessel and that can change in time,
Global Fishing Watch developed **`vesselId`**, a vessel identity
variable that combines vessel information and is specific to a specific
time interval.

A **`vesselId`** is formed by a combination of the MMSI and the IMO
number when available, or by the MMSI, callsign and shipname transmitted
in AIS messages. Each **`vesselId`** is associated to a single MMSI at a
specific period of time, and refers to a single vessel.

On the other side, a single vessel can have several **`vesselId`** in
time, and this is why simple calls to
[`gfw_vessel_info()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_vessel_info.md)
can return tables that have many `vesselIds` and different identity
markers in time.

### Basic and advanced searches

The function
[`gfw_vessel_info()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_vessel_info.md)
allows a user to run a basic query using MMSI, callsign, shipname or IMO
number but it also allows for complex searches, using a combination of
these to retrieve the vessel of interest more accurately:

**Do a simple search using “query” and search_type = “search” (which is
the default so it can be omitted from the function call)**

``` r
gfw_vessel_info(query = 224224000, search_type = "search")
```

**Do complex search or fuzzy matching using `"where"` and
`search_type = "search"`**

``` r
gfw_vessel_info(where = "imo = '8300949'")
gfw_vessel_info(where = "imo = '8300949' AND ssvid = '214182732'")
gfw_vessel_info(where = "shipname LIKE '%GABU REEFE%' OR imo = '8300949'")
```

Importantly, **the response will return all the information it has for
the vessel that matches the combination of identity markers requested,
not only the ones requested**.

This means that the function does not “filter” the results as requested
in the function call. Instead, the function returns all the `vesselIds`
belonging to the same vessel.

> **Note**: The same logic does not apply to
> [`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md):
> calls to
> [`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
> using a single `vesselId` will return events only for the requested
> `vesselId`.

### Use examples

Let’s go back to the simple search. To get information of a vessel using
its MMSI, IMO number, callsign or name, the search can be done directly
using the number or the string. For example, to look for a vessel with
`MMSI = 224224000`, the number is enough:

``` r
mmsi_search <- gfw_vessel_info(224224000)
# 1 total vessels
```

The response from the API is a list with seven elements:

``` r
names(mmsi_search)
# [1] "dataset"                      "registryInfoTotalRecords"    
# [3] "registryInfo"                 "registryOwners"              
# [5] "registryPublicAuthorizations" "combinedSourcesInfo"         
# [7] "selfReportedInfo"
```

The content of the original AIS messages transmitted by the vessel
appears in `$selfReportedInfo`:

``` r
mmsi_search$selfReportedInfo
# # A tibble: 2 × 14
#   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
# 1     1 6632c9eb8… 3061… AGURTZA… AGURTZAB… BES   PJBL     8733…          418581
# 2     1 3c99c326d… 2242… AGURTZA… AGURTZAB… ESP   EBSJ     8733…          135057
# # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
# #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
```

As you can see, this vessel returns a dataframe with two rows. One
corresponds to our original search, where ssvid (MMSI) equals 224224000.

The second line has a different ssvid, but the same name and IMO number.

The two lines correspond to the same vessel, and as you can see from the
fields `transmissionDateFrom` and `transmissionDateTo`, `flag`, and
`ssvid`, the vessel operated with a Spain flag (ESP) and one ssvid
between 2015 and 2019, then it was reflagged and operated with a BES
flag (from Bonaire, Sint Eustatius and Saba) between 2019 and 2023. The
change in ssvid reflects the reflagging operation because the first
three digits of MMSI correspond to the flag country.

Variable `matchFields` reports that the matching was done using
`"SEVERAL_FIELDS"`.

``` r
mmsi_search$selfReportedInfo %>% 
  select(vesselId, ssvid, flag, contains("Date"))
# # A tibble: 2 × 5
#   vesselId                   ssvid flag  transmissionDateFrom transmissionDateTo
#   <chr>                      <chr> <chr> <chr>                <chr>             
# 1 6632c9eb8-8009-abdb-baf9-… 3061… BES   2019-10-15T12:16:54Z 2023-11-30T18:22:…
# 2 3c99c326d-dd2e-175d-626f-… 2242… ESP   2015-10-13T15:47:16Z 2019-10-15T12:10:…
```

This is a simple case, in which the successive **`vesselId`** do not
overlap in time and most identifiers match, in spite of some changes.

For some vessels, variables `transmissionDateFrom` and
`transmissionDateTo` can overlap and other fields can be different.

#### Using **`vesselId`** in other functions

**`vesselId`** can be extracted from `$selfReportedInfo$vesselId`, but
it is highly recommended to take a look at the response and confirm
which of the values returned as `vesselId` should be selected.

Before picking a **`vesselId`** to use in other functions, it is useful
to examine:

- which **`vesselId`** corresponds to the time interval of interest
- if other identifiers are matching, indicating there is enough
  confidence that different **`vesselId`** refer to the vessels of
  interest
- the number of messages transmitted, in `messagesCounter`. Sometimes
  very few positions are transmitted for a short time interval and that
  **`vesselId`** can be treated as an exception

You can use the selected **`vesselId`** to get any events related to the
vessel of interest in other functions.

Let’s find encounter events for all the `vesselIds` from the previous
search:

``` r
id <- mmsi_search$selfReportedInfo$vesselId
id
# [1] "6632c9eb8-8009-abdb-baf9-b67d65f20510"
# [2] "3c99c326d-dd2e-175d-626f-a3c488a4342b"
events <- gfw_event(event_type = "ENCOUNTER", vessels = id) 
# [1] "Downloading 2 events from GFW"
events
# # A tibble: 2 × 17
#   start               end                 eventId          eventType   lat   lon
#   <dttm>              <dttm>              <chr>            <chr>     <dbl> <dbl>
# 1 2020-09-14 08:30:00 2020-09-14 11:50:00 da911addfabd3ce… encounter  8.01 -20.8
# 2 2021-04-19 09:40:00 2021-04-19 12:50:00 5cdd7f497291e06… encounter  3.08 -12.2
# # ℹ 11 more variables: regions <list>, boundingBox <list>, distances <list>,
# #   vesselId <chr>, vessel_name <chr>, vessel_ssvid <chr>, vessel_flag <chr>,
# #   vessel_type <chr>, vessel_publicAuthorizations <list>,
# #   vessel_nextPort <list>, event_info <list>
```

In our example, Global Fishing Watch analyses report that the vessel had
2 encounters.

### Registry data

Vessel registries carry important vessel identity information, like
vessel characteristics, registration history, licenses to fish in
certain areas, and vessel ownership data. Global Fishing Watch compiles
vessel information from over 40 public vessel registries and matches
this information with the AIS-transmitted identity fields to provide a
better overview of a vessel’s identity.

This information is requested by parameter `"includes"` and returned in
the element

- `$registryInfoTotalRecords` (number of records in registries),

``` r
mmsi_search$registryInfoTotalRecords
# # A tibble: 1 × 1
#   registryInfoTotalRecords
#                      <int>
# 1                        1
```

- `$registryInfo` the actual information in the registry, including
  identity, vessel characteristics and dates of transmission

``` r
mmsi_search$registryInfo
# # A tibble: 1 × 17
#   index recordId        sourceCode ssvid flag  shipname nShipname callsign imo  
#   <dbl> <chr>           <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
# 1     1 e0c9823749264a… <chr [7]>  2242… ESP   AGURTZA… AGURTZAB… EBSJ     8733…
# # ℹ 8 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
# #   transmissionDateTo <chr>, geartypes <chr>, lengthM <int>, tonnageGt <dbl>,
# #   vesselInfoReference <chr>, extraFields <list>
```

- `$registryOwners` with their name, country of origin, ssvid of the
  vessel and dates of ownership. Sometimes the vessel can change
  identities and flags but its owners remain the same, and sometimes
  changes in identity correspond to changes in ownership.

``` r
mmsi_search$registryOwners
# # A tibble: 0 × 2
# # ℹ 2 variables: index <dbl>, <list> <list>
```

- `$registryPublicAuthorizations` of the response and the respective
  organizations

``` r
mmsi_search$registryPublicAuthorizations %>%
  tidyr::unnest(sourceCode)
# # A tibble: 3 × 5
#   index dateFrom             dateTo               ssvid     sourceCode
#   <dbl> <chr>                <chr>                <chr>     <chr>     
# 1     1 2019-01-01T00:00:00Z 2019-10-01T00:00:00Z 224224000 ICCAT     
# 2     1 2012-01-01T00:00:00Z 2019-01-01T00:00:00Z 224224000 IOTC      
# 3     1 2019-10-15T00:00:00Z 2023-02-01T00:00:00Z 306118000 ICCAT
```

### Matching AIS and registries: case examples

In the best of cases, AIS messages match registry information and the
whole identity of the vessel can be reconstructed. Here are two examples
with registry and AIS data not overlapping in time.

This vessel has a single `vesselId` throughout its entire history:

``` r
one_vesselId <- gfw_vessel_info(where = "ssvid='701024000'")
# 1 total vessels

#see AIS-based identities
one_vesselId$selfReportedInfo
# # A tibble: 1 × 14
#   index vesselId   ssvid shipname nShipname flag  callsign imo   messagesCounter
#   <dbl> <chr>      <chr> <chr>    <chr>     <chr> <chr>    <chr>           <int>
# 1     1 8e930bac5… 7010… ATLANTI… ATLANTIC… ARG   LW3233   8615…         8381263
# # ℹ 5 more variables: positionsCounter <int>, sourceCode <list>,
# #   matchFields <chr>, transmissionDateFrom <chr>, transmissionDateTo <chr>
#check registry info:
one_vesselId$registryInfo %>%
  dplyr::relocate(transmissionDateFrom, transmissionDateTo) #changing column order for visualization
# # A tibble: 1 × 17
#   transmissionDateFrom transmissionDateTo  index recordId sourceCode ssvid flag 
#   <chr>                <chr>               <dbl> <chr>    <list>     <chr> <chr>
# 1 2012-01-04T05:00:00Z 2025-12-31T22:04:4…     1 4550252… <chr [2]>  7010… ARG  
# # ℹ 10 more variables: shipname <chr>, nShipname <chr>, callsign <chr>,
# #   imo <chr>, latestVesselInfo <lgl>, geartypes <chr>, lengthM <dbl>,
# #   tonnageGt <int>, vesselInfoReference <chr>, extraFields <list>
```

This other vessel has had more than one `vesselId` based on AIS, but the
history is easy to reconstruct:

``` r
multiple_vesselIds <- gfw_vessel_info(where = "ssvid='412217989'") 
# 1 total vessels
# see AIS-based identities:
multiple_vesselIds$selfReportedInfo %>%
  relocate(transmissionDateFrom, transmissionDateTo) 
# # A tibble: 3 × 14
#   transmissionDateFrom transmissionDateTo   index vesselId        ssvid shipname
#   <chr>                <chr>                <dbl> <chr>           <chr> <chr>   
# 1 2021-11-29T06:20:07Z 2025-01-03T03:26:57Z     1 b373b6306-6d0e… 4122… HAO YAN…
# 2 2014-03-29T00:32:05Z 2021-11-27T20:13:55Z     1 305097c65-5323… 4122… JIN LIA…
# 3 2012-08-01T01:47:23Z 2014-03-29T00:14:05Z     1 95a173191-11f9… 4316… HAKKO M…
# # ℹ 8 more variables: nShipname <chr>, flag <chr>, callsign <chr>, imo <chr>,
# #   messagesCounter <int>, positionsCounter <int>, sourceCode <list>,
# #   matchFields <chr>
#check registry info:
multiple_vesselIds$registryInfo 
# # A tibble: 1 × 17
#   index recordId        sourceCode ssvid flag  shipname nShipname callsign imo  
#   <dbl> <chr>           <list>     <chr> <chr> <chr>    <chr>     <chr>    <chr>
# 1     1 bdd48f4144f4fd… <chr [6]>  4122… JPN   HAOYANG… HAOYANG77 BAWB     9038…
# # ℹ 8 more variables: latestVesselInfo <lgl>, transmissionDateFrom <chr>,
# #   transmissionDateTo <chr>, geartypes <chr>, lengthM <dbl>, tonnageGt <dbl>,
# #   vesselInfoReference <chr>, extraFields <list>
```

However, sometimes a vessel found in AIS has no registry information and
the registry fields come back empty. It is also possible that a search
returns a vessel with no matching AIS information and no registry.

## Read more:

- Park et al. (2023). Tracking elusive and shifting identities of the
  global fishing fleet
  [link](https://www.science.org/doi/full/10.1126/sciadv.abp8200) for a
  more detailed account of Global Fishing Watch identity work.
- <https://globalfishingwatch.org/datasets-and-code-vessel-identity/>
- <https://globalfishingwatch.org/data/spoofing-one-identity-shared-by-multiple-vessels/>
