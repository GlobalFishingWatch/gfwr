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

# null coalescing operator ----------------------------------------------------

test_that("null coalescing operator from rlang is available", {
  result <- NULL %||% 1
  expect_equal(result, 1)
})

# globalVariables -------------------------------------------------------------

test_that("globalVariables registers names without error", {
  expect_silent(globalVariables(c(".")))
  expect_silent(globalVariables(c("iso", "name")))
  expect_silent(globalVariables(c("id", "value", "data")))
})


# parse_response_error --------------------------------------------------------

mocked_transaction_id <- "46e2e628-745f2-42c8-b62f-a636987d2cd3"
mocked_unknown_transaction_id <- "unknown"

test_that("parse_response_error parses JSON 404 Not Found", {
  with_gfw_mocked_envvar({
    mocked_url <- curl::curl_modify_url(gfw_base_url(), path = "/404")

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 404,
        url = mocked_url,
        headers = list("transaction-id" = mocked_transaction_id),
        body = list(
          statusCode = 404,
          error = "Not Found",
          messages = list(
            list(
              title = "Not Found",
              detail = "Dataset with id public-global-fishing-effort:latest not found"
            )
          )
        )
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- httr2::request(mocked_url) |>
        req_error(is_error = \(.) FALSE) |>
        httr2::req_perform()
      gfw_api_error <- parse_response_error(resp)
      expect_equal(gfw_api_error$transaction_id, mocked_transaction_id)
      expect_equal(gfw_api_error$status_code, "404")
      expect_match(gfw_api_error$error, "Not Found")
      expect_length(gfw_api_error$messages, 1)
      expect_match(gfw_api_error$formatted[4], "Dataset with id public-global-fishing-effort:latest not found")
    })
  })
})

test_that("parse_response_error parses JSON 422 Unprocessable Entity", {
  with_gfw_mocked_envvar({
    mocked_url <- curl::curl_modify_url(gfw_base_url(), path = "/422")

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 422,
        url = mocked_url,
        headers = list("transaction-id" = mocked_transaction_id),
        body = list(
          statusCode = 422,
          error = "Unprocessable Entity",
          messages = list(
            list(
              title = "Query",
              detail = "Query param dataset is required"
            )
          )
        )
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- httr2::request(mocked_url) |>
        req_error(is_error = \(.) FALSE) |>
        httr2::req_perform()
      gfw_api_error <- parse_response_error(resp)
      expect_equal(gfw_api_error$transaction_id, mocked_transaction_id)
      expect_equal(gfw_api_error$status_code, "422")
      expect_match(gfw_api_error$error, "Unprocessable Entity")
      expect_length(gfw_api_error$messages, 1)
      expect_match(gfw_api_error$formatted[4], "Query param dataset is required")
    })
  })
})

test_that("parse_response_error parses JSON 403 Forbidden", {
  with_gfw_mocked_envvar({
    mocked_url <- curl::curl_modify_url(gfw_base_url(), path = "/403")

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 403,
        url = mocked_url,
        headers = list("transaction-id" = mocked_transaction_id),
        body = list(
          statusCode = 403,
          error = "Forbidden",
          messages = list(
            list(
              title = "Forbidden",
              detail = "Insufficient permissions for public-global-fishing-effort:latest datasets"
            )
          )
        )
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- httr2::request(mocked_url) |>
        req_error(is_error = \(.) FALSE) |>
        httr2::req_perform()
      gfw_api_error <- parse_response_error(resp)
      expect_equal(gfw_api_error$transaction_id, mocked_transaction_id)
      expect_equal(gfw_api_error$status_code, "403")
      expect_match(gfw_api_error$error, "Forbidden")
      expect_length(gfw_api_error$messages, 1)
      expect_match(
        gfw_api_error$formatted[4],
        "Insufficient permissions for public-global-fishing-effort:latest datasets"
      )
    })
  })
})

test_that("parse_response_error parses JSON 429 Too Many Requests", {
  with_gfw_mocked_envvar({
    mocked_url <- curl::curl_modify_url(gfw_base_url(), path = "/429")

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 429,
        url = mocked_url,
        headers = list("transaction-id" = mocked_transaction_id),
        body = list(
          statusCode = 429,
          error = "Too Many Requests",
          messages = list(
            list(
              title = "Too Many Requests",
              detail = "You can only generate one report at the same time."
            )
          )
        )
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- httr2::request(mocked_url) |>
        req_error(is_error = \(.) FALSE) |>
        httr2::req_perform()
      gfw_api_error <- parse_response_error(resp)
      expect_equal(gfw_api_error$transaction_id, mocked_transaction_id)
      expect_equal(gfw_api_error$status_code, "429")
      expect_match(gfw_api_error$error, "Too Many Requests")
      expect_length(gfw_api_error$messages, 1)
      expect_match(gfw_api_error$formatted[4], "You can only generate one report at the same time.")
    })
  })
})

test_that("parse_response_error parses HTML 413 Request Entity Too Large", {
  with_gfw_mocked_envvar({
    mocked_url <- curl::curl_modify_url(gfw_base_url(), path = "/429")

    mocked_resp <- function(req) {
      httr2::response(
        status_code = 200,
        url = mocked_url,
        headers = list("Content-Type" = "text/html", "transaction-id" = mocked_transaction_id),
        body = charToRaw(paste0(
          "<html><head><title>413 Request Entity Too Large</title></head>",
          "<body><h1>Error: Request Entity Too Large</h1>",
          "<h2>Your client issued a request that was too large.</h2></body></html>",
          sep = " "
        ))
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- httr2::request(mocked_url) |>
        req_error(is_error = \(.) FALSE) |>
        httr2::req_perform()
      gfw_api_error <- parse_response_error(resp)
      expect_equal(gfw_api_error$transaction_id, mocked_transaction_id)
      expect_equal(gfw_api_error$status_code, "413")
      expect_match(gfw_api_error$error, "Request Entity Too Large")
      expect_length(gfw_api_error$messages, 1)
      expect_match(gfw_api_error$formatted[4], "Your client issued a request that was too large")
    })
  })
})

test_that("parse_response_error parses multiple error messages", {
  with_gfw_mocked_envvar({
    mocked_url <- curl::curl_modify_url(gfw_base_url(), path = "/multi-messages")

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 422,
        url = mocked_url,
        headers = list("transaction-id" = mocked_transaction_id),
        body = list(
          statusCode = 422,
          error = "Unprocessable Entity",
          messages = list(
            list(
              title = "Query",
              detail = "Query param dataset is required"
            ),
            list(
              title = "region-id",
              detail = "region-id query param is required"
            )
          )
        )
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- httr2::request(mocked_url) |>
        req_error(is_error = \(.) FALSE) |>
        httr2::req_perform()
      gfw_api_error <- parse_response_error(resp)
      expect_equal(gfw_api_error$transaction_id, mocked_transaction_id)
      expect_equal(gfw_api_error$status_code, "422")
      expect_match(gfw_api_error$error, "Unprocessable Entity")
      expect_length(gfw_api_error$messages, 2)
      expect_match(gfw_api_error$formatted[4], "Query param dataset is required")
      expect_match(gfw_api_error$formatted[5], "region-id query param is required")
    })
  })
})


test_that("parse_response_error parses transaction-id header", {
  scenarios <- list(
    # header names
    list(name = "lower-key", key = "transaction-id", val = mocked_transaction_id, expected = mocked_transaction_id),
    list(name = "capital-key", key = "Transaction-Id", val = mocked_transaction_id, expected = mocked_transaction_id),
    list(name = "upper-key", key = "TRANSACTION-ID", val = mocked_transaction_id, expected = mocked_transaction_id),
    list(name = "invalid-key", key = "invalid", val = mocked_transaction_id, expected = mocked_unknown_transaction_id),
    # header values
    list(name = "missing-val", key = "transaction-id", val = NULL, expected = mocked_unknown_transaction_id),
    list(name = "null-val", key = "transaction-id", val = NA_character_, expected = mocked_unknown_transaction_id),
    list(name = "empty-val", key = "transaction-id", val = "", expected = mocked_unknown_transaction_id),
    list(name = "space-val", key = "transaction-id", val = " ", expected = mocked_unknown_transaction_id),
    list(
      name = "spaced-val", key = "transaction-id", val = paste0(" ", mocked_transaction_id, " "),
      expected = mocked_transaction_id
    )
  )

  purrr::walk(scenarios, function(s) {
    with_gfw_mocked_envvar({
      mocked_url <- curl::curl_modify_url(gfw_base_url(), path = paste0("/test-transaction-id-", s$name))

      mocked_headers <- list()
      mocked_headers[[s$key]] <- s$val

      mocked_resp <- function(req) {
        httr2::response_json(
          status_code = 422,
          url = mocked_url,
          headers = mocked_headers,
          body = list(
            statusCode = 422,
            error = "Unprocessable Entity",
            messages = list(
              list(
                title = "Query",
                detail = "Query param dataset is required"
              )
            )
          )
        )
      }

      httr2::with_mocked_responses(mocked_resp, {
        resp <- httr2::request(mocked_url) |>
          req_error(is_error = \(.) FALSE) |>
          httr2::req_perform()
        gfw_api_error <- parse_response_error(resp)
        expect_equal(gfw_api_error$transaction_id, s$expected, info = paste0("Failed on scenario: ", s$name))
      })
    })
  })
})
