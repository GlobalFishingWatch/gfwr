# Making fishing activity maps with \`gfwr\`

## Overview

A powerful feature of `gfwr` is the ability to get data for making
custom maps of human activity at sea, such as apparent fishing effort,
at-sea transshipment, and port visits. The
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
function provides gridded (e.g. raster) data from GFW’s [4Wings Map
Visualization
API](https://globalfishingwatch.org/our-apis/documentation#map-visualization-4wings-api)
and is useful for making heatmaps, while the
[`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
function supplies vector data (mostly point locations) from the GFW
[Events
API](https://globalfishingwatch.org/our-apis/documentation#events-api)
for individual vessel events.

> This vignette demonstrates how to use and combine multiple `gfwr`
> functions to make a variety of maps of fishing vessel activity.
> Specifically, this vignette will show how to use the
> [`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
> function to make heatmaps of apparent fishing effort, and the
> [`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
> function to visualize the locations of specific events. It will
> demonstrate how to request data for specific regions using `gfwr`’s
> built-in options, as well as how to use a custom region provided by
> the user.

### Setup

To get started, first load the `gfwr` package.

``` r
library(gfwr)
```

    #> ℹ Loading gfwr

Make sure your API key is set up in your `.Renviron` file (see the
[Authorization](#authorization) section of the `gfwr` README)

For this vignette, we’ll also use some `tidyverse` packages for data
wrangling and plotting, as well as `sf` for creating and manipulating
spatial data and `rnaturalearth` to add reference data to our maps.

``` r
library(dplyr)
library(tidyr)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(glue)
library(ggplot2)
```

To make our maps a little nicer, let’s define a custom `ggplot2` theme
and a color palette for our heatmaps of apparent fishing effort.

``` r
# Map theme with dark background
map_theme <- ggplot2::theme_minimal() + 
  ggplot2::theme(
    panel.border = element_blank(), 
    legend.position = "bottom", legend.box = "vertical", 
    legend.key.height = unit(3, "mm"), 
    legend.key.width = unit(20, "mm"),
    legend.text = element_text(color = "#848b9b", size = 8), 
    legend.title = element_text(face = "bold", color = "#363c4c", size = 8, hjust = 0.5), 
    plot.title = element_text(face = "bold", color = "#363c4c", size = 10), 
    plot.subtitle = element_text(color = "#363c4c", size = 10), 
    axis.title = element_blank(), 
    axis.text = element_text(color = "#848b9b", size = 6)
    )

# Palette for fishing activity
map_effort_light <- c("#ffffff", "#eeff00", "#3b9088","#0c276c")
```

We’ll also define a common date range to use for querying data.

``` r
start_date <- '2021-01-01'
end_date <- '2021-03-31'
```

## Making heatmaps of apparent fishing effort with `gfw_ais_fishing_hours()`

The `gfwr` function
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
provides aggregated gridded (e.g. raster) data for AIS-based apparent
fishing effort. It was designed to provide data for a specific region,
offering users the ability to select from multiple built-in region types
by specifying a specific Exclusive Economic Zone (EEZ), Marine Protected
Area (MPA), or Regional Fisheries Management Organization (RFMO).

The list of available regions for each type, and their `label` and `id`,
can be accessed with the
[`gfw_regions()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_regions.md)
function.

``` r
eez_regions <- gfw_regions(region_source = 'EEZ')
```

``` r
eez_regions
#> # A tibble: 285 × 5
#>    iso   label                          id GEONAME                      POL_TYPE
#>    <chr> <chr>                       <dbl> <chr>                        <chr>   
#>  1 ASM   American Samoa               8444 United States Exclusive Eco… 200NM   
#>  2 SHN   Ascension                    8379 British Exclusive Economic … 200NM   
#>  3 COK   Cook Islands                 8446 New Zealand Exclusive Econo… 200NM   
#>  4 FLK   Falkland / Malvinas Islands  8389 Overlapping claim Falkland … Overlap…
#>  5 PYF   French Polynesia             8440 French Exclusive Economic Z… 200NM   
#>  6 PCN   Pitcairn                     8439 British Exclusive Economic … 200NM   
#>  7 SHN   Saint Helena                 8380 British Exclusive Economic … 200NM   
#>  8 WSM   Samoa                        8445 Samoan Exclusive Economic Z… 200NM   
#>  9 TON   Tonga                        8448 Tongan Exclusive Economic Z… 200NM   
#> 10 SHN   Tristan da Cunha             8382 British Exclusive Economic … 200NM   
#> # ℹ 275 more rows
```

`gfwr` also includes the
[`gfw_region_id()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_region_id.md)
function to get the `label` and `id` for a specific region using the
`region` argument. For EEZs, the `region` corresponds to the ISO3 code.
Note that, for some countries, the ISO3 code will return multiple
regions. For RFMOs, `region` corresponds to the RFMO abbreviation
(e.g. `"ICCAT"`) and for MPAs it refers to the full name of the MPA. The
[`gfw_region_id()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_region_id.md)
function also works in reverse. If a region `id` is passed as a
`numeric` to the function as the `region`, the corresponding region
`label` can be returned. This is especially useful when events are
returned with region ids and you want the more descriptive label. See
[here](https://globalfishingwatch.org/faqs/reference-layer-sources/) for
more information about the regions used by GFW.

Let’s start by making a map of apparent fishing effort in the Italian
EEZ. The
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
function requires we provide the `id` of a specific region (or a
shapefile, but more on that later). We could look up the Italian EEZ
`id` in the `eez_regions` table we just created, but let’s use
[`gfw_region_id()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_region_id.md).

``` r
# Use gfw_region_id function to get EEZ code for Italy
ita_eez_code <- gfw_region_id(region = "ITA", region_source = "EEZ")
```

    #> # A tibble: 1 × 5
    #>   iso3  label    id GEONAME                         POL_TYPE
    #>   <chr> <chr> <dbl> <chr>                           <chr>   
    #> 1 ITA   Italy  5682 Italian Exclusive Economic Zone 200NM

The
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
function allows users to specify multiple criteria to customize the data
they download, including the date range, spatial and temporal
resolution, and grouping variables. See the documentation for
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
or the [GFW
APIs](https://globalfishingwatch.org/our-apis/documentation#report-url-parameters-for-both-post-and-get-requests)
for more info about these parameter options.

In this case, let’s request data during our time range at 100th degree
resolution and grouped by flag State:

``` r
# Download data for the Italian EEZ
eez_fish_df <- gfw_ais_fishing_hours(
  spatial_resolution = "HIGH",
  temporal_resolution = "YEARLY",
  group_by = "FLAG",
  start_date = start_date,
  end_date = end_date,
  region = ita_eez_code$id,
  region_source = "EEZ"
  )
```

    #> # A tibble: 69,557 × 6
    #>      Lat   Lon `Time Range` flag  `Vessel IDs` `Apparent Fishing Hours`
    #>    <dbl> <dbl>        <dbl> <chr>        <dbl>                    <dbl>
    #>  1  38.6  15.7         2021 ITA              5                    22.1 
    #>  2  42.3  15.3         2021 ITA              4                     4.31
    #>  3  38.1  12.3         2021 ITA              2                     1.34
    #>  4  37.3  13.4         2021 ITA              3                     3.22
    #>  5  43.6  13.7         2021 ITA              9                    12.8 
    #>  6  42.2  16.1         2021 ITA              3                     2.7 
    #>  7  42.3  10.6         2021 ITA              1                     1.07
    #>  8  42.2  11.6         2021 ITA              8                    19.1 
    #>  9  42.8  14.2         2021 ITA              7                    15.0 
    #> 10  39.2  17.3         2021 ITA              1                     0.55
    #> # ℹ 69,547 more rows

Because the data includes fishing by all flag states, to make a map of
all activity, we first need to summarize activity by grid cell.

``` r
eez_fish_all_df <- eez_fish_df %>% 
  group_by(Lat, Lon) %>% 
  summarize(fishing_hours = sum(`Apparent Fishing Hours`, na.rm = T))
#> `summarise()` has regrouped the output.
#> ℹ Summaries were computed grouped by Lat and Lon.
#> ℹ Output is grouped by Lat.
#> ℹ Use `summarise(.groups = "drop_last")` to silence this message.
#> ℹ Use `summarise(.by = c(Lat, Lon))` for per-operation grouping
#>   (`?dplyr::dplyr_by`) instead.
```

Now we can use `ggplot2` to plot the data.

``` r
eez_fish_all_df %>% 
  filter(fishing_hours >= 1) %>%
  ggplot() +
  geom_tile(aes(x = Lon,
                y = Lat,
                fill = fishing_hours)) +
  geom_sf(data = ne_countries(returnclass = "sf", scale = "medium")) +
  coord_sf(xlim = c(min(eez_fish_all_df$Lon),max(eez_fish_all_df$Lon)),
           ylim = c(min(eez_fish_all_df$Lat),max(eez_fish_all_df$Lat))) +
  scale_fill_gradientn(
    trans = 'log10',
    colors = map_effort_light, 
    na.value = NA,
    labels = scales::comma) +
  labs(title = "Apparent fishing hours in the Italian EEZ",
       subtitle = glue("{start_date} to {end_date}"),
       fill = "Fishing hours") +
  map_theme
```

![A map of apparent fishing effort in the Italian EEZ. The scale is
logarithmic and the fishing effort is concentrated around ports along
the Adriatic and the Tyrrhenian Seas and the southern coast of
Sicily](fishing_activity_maps_files/figure-html/ita_plot-1.png)

As another example, let’s request low resolution apparent fishing effort
data within the jurisdiction of the Indian Ocean Tuna Commission (IOTC),
grouped yearly by gear type:

``` r
# Download data for the IOTC
iotc_fish_df <- gfw_ais_fishing_hours(
  spatial_resolution = "LOW",
  temporal_resolution = "YEARLY",
  group_by = "GEARTYPE",
  start_date = start_date,
  end_date = end_date,
  region = "IOTC",
  region_source = "RFMO"
  )
```

    #> # A tibble: 106,054 × 6
    #>      Lat   Lon `Time Range` geartype         `Vessel IDs` Apparent Fishing Hou…¹
    #>    <dbl> <dbl>        <dbl> <chr>                   <dbl>                  <dbl>
    #>  1   2.3  63.7         2021 drifting_longli…            2                   3.74
    #>  2  15.8  61.7         2021 fishing                     1                   7.49
    #>  3 -33.6  99.7         2021 drifting_longli…            3                  28.2 
    #>  4 -14.6  61           2021 set_longlines               5                 104.  
    #>  5  -7.3  65.4         2021 drifting_longli…            1                   3.02
    #>  6 -20.6  55.9         2021 fishing                     1                   3.99
    #>  7 -21.1  55           2021 tuna_purse_sein…            1                   5.01
    #>  8   7.6  77.9         2021 fishing                     1                  14.9 
    #>  9   4.4 100           2021 trawlers                    2                   2.08
    #> 10 -16.8  79.8         2021 drifting_longli…            1                   1.46
    #> # ℹ 106,044 more rows
    #> # ℹ abbreviated name: ¹​`Apparent Fishing Hours`

This time, instead of aggregating all activity, let’s plot the activity
of a specific gear type:

``` r
iotc_p1 <- iotc_fish_df %>% 
  filter(geartype == 'drifting_longlines') %>% 
  filter(`Apparent Fishing Hours` >= 1) %>% 
  ggplot() +
  geom_tile(aes(x = Lon,
                y = Lat,
                fill = `Apparent Fishing Hours`)) +
  geom_sf(data = ne_countries(returnclass = "sf", scale = "medium")) +
  coord_sf(xlim = c(min(iotc_fish_df$Lon),max(iotc_fish_df$Lon)),
           ylim = c(min(iotc_fish_df$Lat),max(iotc_fish_df$Lat))) +
  scale_fill_gradientn(
    transform = 'log10',
    breaks = c(1,10,100),
    colors = map_effort_light, 
    na.value = NA,
    labels = scales::comma) +
  labs(title = "Apparent fishing hours in the IOTC by drifting longlines",
       subtitle = glue("{start_date} to {end_date}"),
       fill = "Fishing hours") +
  map_theme
 
iotc_p1 
```

![A map of apparent fishing hours in the IOTC RFMO by drifting
longlines. ](fishing_activity_maps_files/figure-html/iotc_raster-1.png)

### When your API request times out

For API performance reasons, the
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
function restricts individual queries to a single year of data. However,
even with this restriction, it is possible for API request to time out
before it completes. When this occurs, the initial
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
call will return an error, and subsequent API requests using any `gfwr`
`gfw_` function will return an HTTP 429 error until the original request
completes:

> Error in
> [`httr2::req_perform()`](https://httr2.r-lib.org/reference/req_perform.html):
> ! HTTP 429 Too Many Requests. • Your application token is not
> currently enabled to perform more than one concurrent report. If you
> need to generate more than one report concurrently, contact us at
> apis@globalfishingwatch.org

Although no data was received, the request is still being processed by
the APIs and will become available when it completes. To account for
this, `gfwr` includes the
[`gfw_last_report()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_last_report.md)
function, which let’s users request the results of their last API
request with
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md).

The
[`gfw_last_report()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_last_report.md)
function will tell you if the APIs are still processing your request and
will download the results if the request has finished successfully. You
will receive an error message if the request finished but resulted in an
error or if it’s been \>30 minutes since the last report was generated
using
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md).
For more information, see the [Get last report generated
endpoint](https://globalfishingwatch.org/our-apis/documentation#get-last-report-generated)
documentation on the GFW API page.

If you’re struggling with this issue, we suggest breaking your request
into smaller individual requests and then binding the results in R.

## Plotting vessel events

The
[`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
function provides spatial data about the location of specific vessel
activities. There are currently five available event types
(`"FISHING"`,`"ENCOUNTER"`,`"LOITERING"`, `"PORT VISIT"`, and `"GAP"`)
and the `vessel-types` argument allow users to request events for
different categories of vessels (e.g. `"FISHING"`, `"CARRIER"`,
`"CARGO"`, etc.). There are also a few event-specific arguments for
specifying things like encounter types and confidence levels. For more
details, see the
[`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
function documentation and the [GFW API
documentation](https://globalfishingwatch.org/our-apis/documentation#data-caveat).

In this example, we will use
[`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
to request encounter events between fishing vessels and refrigerated
carrier vessels. We’ll restrict events to those within the jurisdiction
of the Indian Ocean Tuna Commission (IOTC) using the `region` and
`region_source` arguments like we did in the previous example.

``` r
# using same example as above
encounters_df <- gfw_event(event_type = "ENCOUNTER",
                           encounter_types = "CARRIER-FISHING",
                           start_date = start_date,
                           end_date = end_date,
                           region = "IOTC",
                           region_source = "RFMO") 
#> [1] "Downloading 178 events from GFW"
```

Encounters events have two rows per event to represent both vessels.
Because each row shares the same event ID (`eventId`), we can extract
the `eventId` and select one row per `eventId` to remove duplicate
positions. We’ll also use the `lon` and `lat` coordinates to create a
`sf` object for each encounter event.

``` r
encounters_sf_df <- encounters_df %>% 
  tidyr::separate(eventId, c("eventId","vessel_number")) %>% 
  filter(vessel_number == 1) %>% 
  sf::st_as_sf(coords = c("lon","lat"), crs = 4326) %>% 
  select(eventId, eventType, geometry)
```

To assist with plotting, let’s get the bounding box of the encounter
events.

``` r
enc_bbox <- st_bbox(encounters_sf_df)
```

Now let’s add the encounters layer to our previous map of drifting
longline effort in the IOTC and use the bounding box to restrict the
plot to the area with encounters.

``` r
iotc_p1 +
  geom_sf(data = encounters_sf_df, 
          aes(color = eventType), 
          alpha = 0.7, size = 1) +
  coord_sf(xlim = enc_bbox[c(1,3)],
           ylim = enc_bbox[c(2,4)]) +
  labs(title = 'Apparent fishing hours in the IOTC by drifting longlines and fishing vessel encounter events with carrier vessels',
       color = 'Event type')
#> Coordinate system already present.
#> ℹ Adding new coordinate system, which will replace the existing one.
```

![A map of apparent fishing hours in the IOTC by drifting longlines and
fishing vessels
encounters](fishing_activity_maps_files/figure-html/iotc_plot_1-1.png)

## Making maps for custom regions

The
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
and
[`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
functions also allow users to download data within a custom region by
providing a GeoJSON polygon. To facilitate this, the
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
and
[`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md)
functions allow users to pass a `sf` object to the `region` argument.

To demonstrate this, we’ll first create a tibble of coordinates defining
an arbitrary polygon and convert to an `sf` object.

``` r
my_shp <- tibble(
  lon = c(-96,-96,-66,-66,-96),
  lat = c(-24,4,4,-24,-24)
  ) %>% 
  sf::st_as_sf(coords = c("lon","lat"), crs = 4326) %>% 
  summarize(geometry = st_combine(geometry)) %>% 
  st_cast("POLYGON")
```

Plot the `sf` object to confirm it was created successfully.

``` r
ggplot() +
  geom_sf(data = ne_countries(returnclass = "sf", scale = "small")) +
  geom_sf(
    data = my_shp, 
    fill = NA,
    color = 'red') +
  map_theme
```

![A world map with all countries and a red bounding box in the area
surrounding Ecuador, Peru and the north of Chile.
](fishing_activity_maps_files/figure-html/plot_shp-1.png)

Let’s create a `sf` bounding box object for our region to use for
plotting later. Although our shape is a simple rectangle in this
example, this is helpful when using more complex regions.

``` r
my_shp_bbox <- st_bbox(my_shp)
```

Now we’re ready to request data in our custom region from
[`gfw_ais_fishing_hours()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_ais_fishing_hours.md)
and
[`gfw_event()`](https://globalfishingwatch.github.io/gfwr/reference/gfw_event.md).

``` r
my_raster_df <- gfw_ais_fishing_hours(spatial_resolution = "LOW",
                                      temporal_resolution = "YEARLY",
                                      group_by = "GEARTYPE",
                                      start_date = start_date,
                                      end_date = end_date,
                                      region = my_shp,
                                      region_source = "USER_SHAPEFILE")
```

For events, we’ll request high-confidence port visits by fishing vessels

``` r
my_port_events_df <- gfw_event(event_type = "PORT_VISIT",
                               confidences = 4,
                               vessel_types = "FISHING",
                               start_date = start_date,
                               end_date = end_date,
                               region = my_shp,
                               region_source = "USER_SHAPEFILE") 
#> [1] "Downloading 4154 events from GFW"
```

and loitering events by refrigerated cargo vessels

``` r
my_loitering_events_df <- gfw_event(event_type = "LOITERING",
                                    vessel_types = "CARRIER",
                                    start_date = start_date,
                                    end_date = end_date,
                                    region = my_shp,
                                    region_source = "USER_SHAPEFILE") 
#> [1] "Downloading 50 events from GFW"
```

As before, let’s summarize the raster to plot all fishing activity by
fishing vessels

``` r
my_raster_all_df <- my_raster_df %>% 
  group_by(Lat, Lon) %>% 
  summarize(fishing_hours = sum(`Apparent Fishing Hours`, na.rm = T))
#> `summarise()` has regrouped the output.
#> ℹ Summaries were computed grouped by Lat and Lon.
#> ℹ Output is grouped by Lat.
#> ℹ Use `summarise(.groups = "drop_last")` to silence this message.
#> ℹ Use `summarise(.by = c(Lat, Lon))` for per-operation grouping
#>   (`?dplyr::dplyr_by`) instead.
```

and combine our two event datasets and create `sf` objects for each
event.

``` r
my_events_sf <- my_port_events_df %>% 
  select(eventId, lon, lat, eventType) %>% 
  bind_rows(
    my_loitering_events_df %>% 
      select(eventId, lon, lat, eventType)
  ) %>% 
  sf::st_as_sf(coords = c("lon","lat"), crs = 4326) %>% 
  dplyr::select(eventId, eventType, geometry)
```

Finally, let’s plot the fishing effort raster and overlay the loitering
events and port visits.

``` r
my_raster_all_df %>% 
  filter(fishing_hours > 1) %>% 
  ggplot() +
  geom_tile(aes(x = Lon,
                y = Lat,
                fill = fishing_hours)) +
  geom_sf(data = my_events_sf,
          aes(color = eventType),
          alpha = 0.7) +
  geom_sf(data = ne_countries(returnclass = 'sf', scale = 'medium')) +
  coord_sf(xlim = my_shp_bbox[c(1,3)],
           ylim = my_shp_bbox[c(2,4)]) +
  scale_fill_gradientn(
    transform = 'log10',
    colors = map_effort_light, 
    na.value = NA) +
  labs(
    title = 'Fishing hours, loitering events, and port visits',
    subtitle = glue("{start_date} to {end_date}"),
    fill = 'Fishing hours',
    color = 'Event type'
  ) +
  map_theme
```

![Apparent fishing hours in the area of interest around Ecuador, Peru
and the north of Chile, in yellow, red dots indicating loitering events
and blue dots indicating port
visits.](fishing_activity_maps_files/figure-html/loitering_ports_fishing_map-1.png)
