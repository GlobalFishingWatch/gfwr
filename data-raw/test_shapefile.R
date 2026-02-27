## code to prepare test shapefile
#read geojson to sf
library(geojsonsf)
library(sf)
gfw_test_shape <- geojson_sf("data-raw/NI.geojson")
#this will be an example to use sf_to_geojson
#NI_tagged <- sf_to_geojson(NI)
usethis::use_data(gfw_test_shape)

