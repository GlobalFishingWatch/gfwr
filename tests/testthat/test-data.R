# test_shape ------------------------------------------------------------------

test_that("test_shape exists and is a valid sf object", {
  expect_true("test_shape" %in% ls("package:gfwr")) # should be part of the exported data
  data("test_shape", package = "gfwr", envir = environment())
  expect_true(exists("test_shape")) # should exist after loading

  # structure
  expect_s3_class(test_shape, "sf") # should be simple feature
  expect_gt(nrow(test_shape), 0) # should contain at least one row
  expect_true("geometry" %in% names(test_shape))
  expect_true(inherits(test_shape$geometry, "sfc")) # should contain an sf geometry column
  expect_true(all(sf::st_is_valid(test_shape))) # all geometries should be valid
  expect_true(any(sf::st_geometry_type(test_shape) %in% c("MULTIPOLYGON", "POLYGON"))) # geometry should be polygonal

  # content
  crs <- sf::st_crs(test_shape)
  expect_true(is.list(crs) || is.null(crs)) # should have CRS

  # snapshot
  bbox <- sf::st_bbox(test_shape)
  geom_type <- unique(sf::st_geometry_type(test_shape))
  expect_snapshot_value(
    list(geom_type = geom_type, bbox = bbox, crs = crs),
    style = "json2"
  ) # should not silently change
})

# marine_regions --------------------------------------------------------------

test_that("marine_regions dataset exists and has expected structure", {
  expect_true("marine_regions" %in% ls("package:gfwr")) # should be part of the exported data
  data("marine_regions", package = "gfwr", envir = environment())
  expect_true(exists("marine_regions")) # should exist after loading

  # structure
  expect_s3_class(marine_regions, "tbl_df") # should be a tibble
  expect_true(is.data.frame(marine_regions) || tibble::is_tibble(marine_regions)) # should behave like a data.frame
  expect_equal(ncol(marine_regions), 5) # must have exactly 5 columns
  expect_gt(nrow(marine_regions), 0) # should contain at least one row
  expect_true(all(c("iso", "name", "MRGID", "GEONAME", "POL_TYPE") %in% colnames(marine_regions)))

  # content
  expect_true(is.character(marine_regions$iso) || all(is.na(marine_regions$iso)))
  expect_true(is.character(marine_regions$name) || all(is.na(marine_regions$name)))
  expect_true(is.numeric(marine_regions$MRGID) || all(is.na(marine_regions$MRGID)))
  expect_true(is.character(marine_regions$GEONAME) || all(is.na(marine_regions$GEONAME)))
  expect_true(is.character(marine_regions$POL_TYPE) || all(is.na(marine_regions$POL_TYPE)))
  expect_true(all(marine_regions$POL_TYPE %in% c("200NM", "Overlapping claim", "Joint regime")))

  # snapshot
  nrows <- nrow(marine_regions)
  ncols <- ncol(marine_regions)
  colnames <- names(marine_regions)
  sample <- head(marine_regions, 3)

  expect_snapshot_value(list(
    nrows = nrows,
    ncols = ncols,
    colnames = colnames,
    sample = sample
  ), style = "json2") # should not silently change
})
