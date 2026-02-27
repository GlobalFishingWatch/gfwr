# gfw_base_url ----------------------------------------------------------------

test_that("gfw_base_url returns trimmed environment value when set", {
  withr::with_envvar(c(GFW_BASE_URL = "https://gateway.api.mocking.globalfishingwatch.org/v3/"), {
    expect_equal(gfw_base_url(), "https://gateway.api.mocking.globalfishingwatch.org/v3/")
  })

  withr::with_envvar(c(GFW_BASE_URL = "  https://gateway.api.mocking.globalfishingwatch.org/v3/  "), {
    expect_equal(gfw_base_url(), "https://gateway.api.mocking.globalfishingwatch.org/v3/")
  })
})

test_that("gfw_base_url returns default URL when environment variable is empty or whitespace", {
  withr::with_envvar(c(GFW_BASE_URL = ""), {
    expect_equal(gfw_base_url(), "https://gateway.api.globalfishingwatch.org/v3/")
  })

  withr::with_envvar(c(GFW_BASE_URL = "   "), {
    expect_equal(gfw_base_url(), "https://gateway.api.globalfishingwatch.org/v3/")
  })

  withr::with_envvar(c(GFW_BASE_URL = NULL), {
    expect_equal(gfw_base_url(), "https://gateway.api.globalfishingwatch.org/v3/")
  })

  withr::with_envvar(c(GFW_BASE_URL = NA), {
    expect_equal(gfw_base_url(), "https://gateway.api.globalfishingwatch.org/v3/")
  })
})

test_that("gfw_base_url returns mocked base URL with `with_gfw_mocked_base_url` helper", {
  with_gfw_mocked_base_url({
    expect_equal(gfw_base_url(), MOCK_GFW_BASE_URL)
  })
})

test_that("gfw_base_url returns mocked base URL with `with_gfw_mocked_envvar` helper", {
  with_gfw_mocked_envvar({
    expect_equal(gfw_base_url(), MOCK_GFW_BASE_URL)
  })
})

# gfw_auth --------------------------------------------------------------------

test_that("gfw_auth returns token from environment when set", {
  withr::with_envvar(c(GFW_TOKEN = "test-token"), {
    expect_equal(gfw_auth(), "test-token")
  })
})

test_that("gfw_auth returns empty string when token is unset or empty", {
  withr::with_envvar(c(GFW_TOKEN = ""), {
    expect_equal(gfw_auth(), "")
  })

  withr::with_envvar(c(GFW_TOKEN = NA_character_), {
    expect_equal(gfw_auth(), "")
  })
})

test_that("gfw_auth returns mocked token with `with_gfw_mocked_token` helper", {
  with_gfw_mocked_token({
    expect_equal(gfw_auth(), MOCK_GFW_TOKEN)
  })
})

test_that("gfw_auth returns mocked token with `with_gfw_mocked_envvar` helper", {
  with_gfw_mocked_envvar({
    expect_equal(gfw_auth(), MOCK_GFW_TOKEN)
  })
})

# gfw_user_agent --------------------------------------------------------------

test_that("gfw_user_agent returns a correctly formatted user agent string", {
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

test_that("make_char leaves multi-element lists unchanged", {
  expect_equal(make_char(list(c("a", "b"))), list(c("a", "b")))
})

test_that("make_char leaves atomic vectors unchanged", {
  expect_equal(make_char(c("a", "b")), c("a", "b"))
  expect_equal(make_char(1:3), 1:3)
})

test_that("make_char handles mixed-type lists correctly", {
  result <- make_char(list("a", 1, TRUE))
  expect_equal(result, c("a", "1", "TRUE"))
})

# make_datetime ---------------------------------------------------------------

test_that("make_datetime converts ISO-8601 timestamps to UTC POSIXct", {
  x <- c("2024-01-01T00:00:00", "2024-12-31T23:59:59")
  dt <- make_datetime(x)
  expect_s3_class(dt, "POSIXct")
  expect_equal(format(dt, "%Y-%m-%dT%H:%M:%S"), x)
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

test_that("vector_to_array works with single-element characters", {
  x <- "a"
  result <- vector_to_array(x, "event")
  expect_named(result, c("event[0]"))
  expect_equal(unname(result), x)
})

test_that("vector_to_array works with single-element numerics", {
  x <- 1
  result <- vector_to_array(x, "event")
  expect_named(result, c("event[0]"))
  expect_equal(unname(result), x)
})

# sf_to_geojson ---------------------------------------------------------------

test_that("sf_to_geojson formats correctly for raster endpoint", {
  data("gfw_test_shape", package = "gfwr", envir = environment())
  result <- sf_to_geojson(gfw_test_shape, endpoint = "raster")
  expect_type(result, "character")
  expect_match(result, "^\\{\"geojson\":\\{", fixed = FALSE)
})

test_that("sf_to_geojson formats correctly for event endpoint", {
  data("gfw_test_shape", package = "gfwr", envir = environment())
  result <- sf_to_geojson(gfw_test_shape, endpoint = "event")
  expect_type(result, "character")
  expect_match(result, "^\"geometry\":\\{", fixed = FALSE)
})

test_that("sf_to_geojson throws for invalid endpoint", {
  data("gfw_test_shape", package = "gfwr", envir = environment())
  expect_error(sf_to_geojson(gfw_test_shape, endpoint = "invalid"), "Incorrect endpoint argument")
})

# pipe operator ---------------------------------------------------------------

test_that("pipe operator from magrittr is available", {
  result <- 1 %>% sum()
  expect_equal(result, 1)
})

# globalVariables -------------------------------------------------------------

test_that("globalVariables registers names without error", {
  expect_silent(globalVariables(c(".")))
  expect_silent(globalVariables(c("iso", "name")))
  expect_silent(globalVariables(c("id", "value", "data")))
})
