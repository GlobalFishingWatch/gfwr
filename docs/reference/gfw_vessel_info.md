# Base function to get vessel information from API and convert response to tibble

Base function to get vessel information from API and convert response to
tibble

## Usage

``` r
gfw_vessel_info(
  query = NULL,
  where = NULL,
  search_type = "search",
  ids = NULL,
  includes = c("AUTHORIZATIONS", "OWNERSHIP", "MATCH_CRITERIA"),
  match_fields = NULL,
  registries_info_data = c("ALL"),
  key = gfw_auth(),
  quiet = FALSE,
  print_request = FALSE,
  ...
)
```

## Arguments

- query:

  When `search_type = "search"`, a length-1 vector with the identity
  variable of interest, MMSI, IMO, call sign or ship name.

- where:

  When `search_type = "search"`, an SQL expression to find the vessel of
  interest.

- search_type:

  Type of vessel search to perform. Can be `"search"` (the default) or
  `"id"`. (Note:`"advanced"` and `"basic"` are no longer in use as of
  gfwr 2.0.0.).

- ids:

  When `search_type = "id"`, a vector with the `vesselId` of interest.

- includes:

  Enhances the response with new information, defaults to include all.

  `"OWNERSHIP"`

  :   returns ownership information

  `"AUTHORIZATIONS"`

  :   lists public authorizations for that vessel

  `"MATCH_CRITERIA"`

  :   adds information about the reason why a vessel is returned

- match_fields:

  Optional. Allows to filter by `matchFields` levels. Possible values:
  `"SEVERAL_FIELDS"`, `"NO_MATCH"`, `"ALL"`. Incompatible with `where`.

- registries_info_data:

  when `search_type == "id"`, gets all the registry objects, only the
  delta or the latest.

  `"NONE"`

  :   The API will return the most recent object only

  `"DELTA"`

  :   The API will return only the objects when the vessel changed one
      or more identity properties

  `"ALL"`

  :   The `registryInfo` array will return all objects we have in the
      vessel database

- key:

  Character, API token. Defaults to
  [`gfw_auth()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_auth.md).

- quiet:

  Boolean. Whether to print the number of events returned by the request
  and progress. Default is FALSE.

- print_request:

  Boolean. Whether to print the request, for debugging purposes. When
  contacting the GFW team it will be useful to send this string.

- ...:

  Other parameters, see API documentation.

## Details

When `search_type = "search"` the search takes basic identity features
like MMSI, IMO, callsign, shipname as inputs, using parameter `"query"`.
For more advanced SQL searches, use parameter `"where"`. You can combine
logic operators like `AND`, `OR`, `=`, `>=` , \<, `LIKE` (for fuzzy
matching). The `id` search allows the user to search using a GFW
`vesselId`.

## Examples

``` r
if (FALSE) { # \dontrun{
library(gfwr)

# Simple searches, using includes

gfw_vessel_info(query = 224224000, search_type = "search")

# Advanced search with where instead of query:

gfw_vessel_info(where = "ssvid = '441618000' OR imo = '9047271'",
search_type = "search")

 # Vessel id search

 gfw_vessel_info(search_type = "id",
 ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01",
 "6583c51e3-3626-5638-866a-f47c3bc7ef7c"))

 all <- gfw_vessel_info(search_type = "id",
 ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
 registries_info_data = c("ALL"))

 none <- gfw_vessel_info(search_type = "id",
 ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
 registries_info_data = c("NONE"))

 delta <- gfw_vessel_info(search_type = "id",
 ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
 registries_info_data = c("DELTA"))

 } # }
```
