# gfw_auth --------------------------------------------------------------------

test_that("gfw_auth reads token from environment", {
  withr::with_envvar(c(GFW_TOKEN = "test-token"), {
    expect_equal(gfw_auth(), "test-token")
  })

  withr::with_envvar(c(GFW_TOKEN = ""), {
    expect_equal(gfw_auth(), "")
  })
})

# gfw_user_agent --------------------------------------------------------------

test_that("gfw_user_agent returns correct user agent string", {
  ua <- gfw_user_agent()
  expect_type(ua, "character")
  expect_match(ua, "^gfwr/", fixed = FALSE)
  expect_match(ua, "https://github.com/GlobalFishingWatch/gfwr")
})

# make_char -------------------------------------------------------------------

test_that("make_char converts single-element lists to character", {
  expect_equal(make_char(list("x")), "x")
  expect_equal(make_char(list(1)), "1")
})

test_that("make_char leaves vectors unchanged", {
  expect_equal(make_char(c("a", "b")), c("a", "b"))
  expect_equal(make_char(1:3), 1:3)
})

test_that("make_char works with mixed types", {
  result <- make_char(list("a", 1, TRUE))
  expect_equal(result, c("a", "1", "TRUE"))
})

# make_datetime ---------------------------------------------------------------

test_that("make_datetime converts ISO timestamps to POSIXct", {
  x <- c("2024-01-01T00:00:00", "2024-12-31T23:59:59")
  dt <- make_datetime(x)
  expect_s3_class(dt, "POSIXct")
  expect_equal(format(dt[1], "%Y-%m-%d"), "2024-01-01")
  expect_equal(attr(dt, "tzone"), "UTC")
})

# vector_to_array -------------------------------------------------------------

test_that("vector_to_array produces correctly named vector", {
  x <- c("a", "b")
  result <- vector_to_array(x, "dataset")
  expect_named(result, c("dataset[0]", "dataset[1]"))
  expect_equal(unname(result), x)
})

test_that("vector_to_array works with numeric vectors", {
  x <- c(1, 2)
  result <- vector_to_array(x, "vessel")
  expect_named(result, c("vessel[0]", "vessel[1]"))
  expect_equal(unname(result), x)
})

# sf_to_geojson ---------------------------------------------------------------

test_that("sf_to_geojson formats correctly for raster endpoint", {
  data("test_shape", package = "gfwr", envir = environment())
  result <- sf_to_geojson(test_shape, endpoint = "raster")
  expect_type(result, "character")
  expect_match(result, "^\\{\"geojson\":")
})

test_that("sf_to_geojson formats correctly for event endpoint", {
  data("test_shape", package = "gfwr", envir = environment())
  result <- sf_to_geojson(test_shape, endpoint = "event")
  expect_type(result, "character")
  expect_match(result, "^\"geometry\":")
})

test_that("sf_to_geojson throws for invalid endpoint", {
  data("test_shape", package = "gfwr", envir = environment())
  expect_error(sf_to_geojson(test_shape, endpoint = "invalid"), "Incorrect endpoint argument")
})

# pipe ------------------------------------------------------------------------

test_that("pipe operator from magrittr is available", {
  result <- 1 %>% sum()
  expect_equal(result, 1)
})

# globalVariables -------------------------------------------------------------

test_that("globalVariables calls do not error", {
  expect_silent(globalVariables(c(".")))
  expect_silent(globalVariables(c("iso", "name")))
})
