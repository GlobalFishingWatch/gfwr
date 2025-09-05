#' A sample shapefile
#'
#' An sf shapefile to show as an example of user-defined GeoJSON in [gfw_event()],
#' [gfw_ais_fishing_hours()], [gfw_ais_presence()], and [gfw_sar_presence()]
#'
#' @format A shapefile with a single polygon.
"test_shape"

#' Simplified Marine Regions v12 dataset
#'
#'A tibble with the ISO codes and names derived from
#' Marine Regions v12, to be used by [gfw_regions()] and [gfw_region_id()] to
#' extract numeric EEZ codes (`MRGID`)
#'
#' @details
#'
#' The main source data for EEZ shapefiles and information across Global Fishing
#' Watch's data and platforms is Marine Regions v12.
#'
#' The main variable of interest of this dataset is `MRGID`, the unique
#' identifier for each one of the polygons comprising Marine Regions. `MRGID`
#' is necessary to retrieve apparent fishing effort data and all event types
#' from other `gfwr` functions when `region_source = "EEZ"`
#'
#' Functions [gfw_region_id()] and [gfw_regions()] facilitate fetching region ids
#' from ISO codes and region names.
#'
#' However, the original Marine Region dataset includes several columns that can
#' refer to the ISO of the territory itself (`ISO_TER1`), the entity that has
#' sovereignty over the territory (`ISO_SOV1`) or the territories that operate
#' Joint regime areas, or claim Overlapping claims areas (`ISO_SOV1`, `ISO_SOV2`,
#' `ISO_SOV3`).
#'
#' The table `marine_regions` unifies all these ISO markers into a single column without
#' modifying the original data, in a reproducible way.
#'
#' - Joint regime and overlapping claims with no ISO receive an `NA`: `iso = NA`
#' - Territories within the 200NM with an ISO receive it: `iso = ISO_TER1`
#' - Overlapping claims with an ISO receive it: `iso = ISO_TER1`
#' - Territories within the 200NM and no ISO receive the ISO of their mainland: `iso = ISO_SOV1`
#'
#' Likewise, `marine_regions` also derives a `name` column from the different
#' names and `GEONAME` columns present in the original dataset.
#'
#' - Countries and territories within the 200NM EEZs receive their name: `name = TERRITORY1`
#' - Overlapping claims with a name receive their name: `name = TERRITORY1`
#' - Joint regimes and overlapping claims with no name receive their `GEONAME`: `name = GEONAME`
#'
#' The code implementing this synthesis can be found in the `data-raw/marine_regions.R` file.
#'
#'
#' @source Marine Regions https://www.marineregions.org/. https://doi.org/10.14284/632
#' @references Flanders Marine Institute (2023). Maritime Boundaries Geodatabase: Maritime Boundaries and Exclusive Economic Zones (200NM), version 12. Available online at https://www.marineregions.org/. https://doi.org/10.14284/632

#' @format A tibble with 285 rows and 5 columns
#' \describe{
#'   \item{`iso`}{ISO Code derived from the different ISO code columns in the Maritime Boundaries Geodatabase v12}
#'   \item{`name`}{Territory name derived from the different Name and Geoname columns in the Maritime Boundaries Geodatabase v12}
#'   \item{`MRGID`}{Original numeric id for EEZs from the Marine Boundaries Geodatabase v12. This numeric code should be used in the `region` argument when using functions
#'   [gfw_ais_fishing_hours()], [gfw_ais_presence()], and [gfw_sar_presence()] and [gfw_event()], when `region_source = "EEZ"`.}
#'   \item{`GEONAME`}{Original GEONAME field from the Maritime Boundaries Geodatabase v12}
#'   \item{`POL_TYPE`}{Original POLygon TYPE from the Maritime Boundaries Geodatabase v12. Possible value are "200NM", "Overlapping claim" and "Joint regime"}
#'  }
"marine_regions"
