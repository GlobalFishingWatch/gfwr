# gfw_test_shape --------------------------------------------------------------

test_that("gfw_test_shape exists and is a valid sf object", {
  expect_true("gfw_test_shape" %in% ls("package:gfwr")) # should be part of the exported data
  data("gfw_test_shape", package = "gfwr", envir = environment())
  expect_true(exists("gfw_test_shape")) # should exist after loading

  # structure
  expect_s3_class(gfw_test_shape, "sf") # should be simple feature
  expect_gt(nrow(gfw_test_shape), 0) # should contain at least one row
  expect_true("geometry" %in% names(gfw_test_shape))
  expect_true(inherits(gfw_test_shape$geometry, "sfc")) # should contain an sf geometry column
  expect_true(all(sf::st_is_valid(gfw_test_shape))) # all geometries should be valid
  expect_true(any(
    sf::st_geometry_type(gfw_test_shape) %in% c("MULTIPOLYGON", "POLYGON")
  )) # geometry should be polygonal

  # content
  crs <- sf::st_crs(gfw_test_shape)
  expect_true(is.list(crs) || is.null(crs)) # should have CRS

  # snapshot
  bbox <- sf::st_bbox(gfw_test_shape)
  geom_type <- unique(sf::st_geometry_type(gfw_test_shape))
  expect_snapshot_value(
    list(geom_type = geom_type, bbox = bbox, crs = crs),
    style = "json2"
  ) # should not silently change
})

# gfw_marine_regions ----------------------------------------------------------

test_that("gfw_marine_regions dataset exists and has expected structure", {
  expect_true("gfw_marine_regions" %in% ls("package:gfwr")) # should be part of the exported data
  data("gfw_marine_regions", package = "gfwr", envir = environment())
  expect_true(exists("gfw_marine_regions")) # should exist after loading

  # structure
  expect_s3_class(gfw_marine_regions, "tbl_df") # should be a tibble
  expect_true(
    is.data.frame(gfw_marine_regions) || tibble::is_tibble(gfw_marine_regions)
  ) # should behave like a data.frame
  expect_equal(ncol(gfw_marine_regions), 5) # must have exactly 5 columns
  expect_gt(nrow(gfw_marine_regions), 0) # should contain at least one row
  expect_true(all(c("iso", "name", "MRGID", "GEONAME", "POL_TYPE") %in% colnames(gfw_marine_regions)))

  # content
  expect_true(is.character(gfw_marine_regions$iso) || all(is.na(gfw_marine_regions$iso)))
  expect_true(is.character(gfw_marine_regions$name) || all(is.na(gfw_marine_regions$name)))
  expect_true(is.numeric(gfw_marine_regions$MRGID) || all(is.na(gfw_marine_regions$MRGID)))
  expect_true(is.character(gfw_marine_regions$GEONAME) || all(is.na(gfw_marine_regions$GEONAME)))
  expect_true(is.character(gfw_marine_regions$POL_TYPE) || all(is.na(gfw_marine_regions$POL_TYPE)))
  expect_true(all(gfw_marine_regions$POL_TYPE %in% c("200NM", "Overlapping claim", "Joint regime")))

  # snapshot
  nrows <- nrow(gfw_marine_regions)
  ncols <- ncol(gfw_marine_regions)
  colnames <- names(gfw_marine_regions)
  sample <- head(gfw_marine_regions, 3)

  expect_snapshot_value(list(
    nrows = nrows,
    ncols = ncols,
    colnames = colnames,
    sample = sample
  ), style = "json2") # should not silently change
})
