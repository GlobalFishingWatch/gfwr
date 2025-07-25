## code to prepare `marine_regions` dataset
## This script assumes that the file
# World_EEZ_v12_20231025_gpkg/eez_v12.gpkg
## from the Marine Regions v12 database is located inside the data-raw folder
## (not included in the repository because of its size)
## Downloaded from: https://www.marineregions.org/download_file.php?name=World_EEZ_v12_20231025_gpkg.zip

library(dplyr)
library(sf)
# raw marine regions data
eeza <- sf::read_sf("./data-raw/World_EEZ_v12_20231025_gpkg/eez_v12.gpkg")
mr <- eeza %>% sf::st_drop_geometry()

mr_name <- mr %>% mutate(name = case_when(
  # Joint regimes are named joint regimes
  POL_TYPE == "Joint regime" ~ GEONAME,
  # Overlapping claims that are named keep their name
  POL_TYPE %in% c("Overlapping claim") & stringr::str_detect(string = mr$GEONAME, "claim ") ~ TERRITORY1,
  # Overlapping claims that are not named are named overlapping claims
  POL_TYPE %in% c("Overlapping claim") & stringr::str_detect(string = mr$GEONAME, "claim:") ~ GEONAME,
  # Areas belonging to the EEZ of a main country keep their name
  POL_TYPE == "200NM" ~ TERRITORY1)) %>% relocate(name)


mr_name_iso <- mr_name %>% mutate(iso = case_when(
  # Joint regimes are named joint regimes, they have no ISO
  POL_TYPE == "Joint regime" ~ NA,
  # Overlapping claims that are named keep their name and their ISO when available
  POL_TYPE %in% c("Overlapping claim") & stringr::str_detect(string = mr_name$GEONAME, "claim ") ~ ISO_TER1,
  # Overlapping claims that are not named are named overlapping claims and have NO ISO
  POL_TYPE %in% c("Overlapping claim") & stringr::str_detect(string = mr_name$GEONAME, "claim:") ~ NA,
  # Areas belonging to the EEZ of a main country keep their name and the country's ISO
  POL_TYPE == "200NM" & !is.na(ISO_TER1) ~ ISO_TER1,
  # Areas belonging to the EEZ of a main country but with no ISO get their mainland country's ISO
  POL_TYPE == "200NM" & is.na(ISO_TER1) ~ ISO_SOV1)) %>%
  relocate(iso)

marine_regions <- mr_name_iso %>%
  select(iso, name, MRGID, GEONAME, POL_TYPE)

usethis::use_data(marine_regions, overwrite = TRUE)
