# Validate includes -----------------------------------------------------------

test_that("get_vessel_insights: missing includes triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = NULL,
        start_date = "2020-01-01",
        end_date = "2025-03-03",
        vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f")
      ),
      regexp = "`includes` is required"
    )
  })
})

test_that("get_vessel_insights: invalid includes triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = "INVALID-INCLUDE",
        start_date = "2020-01-01",
        end_date = "2025-03-03",
        vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f")
      ),
      regexp = "Invalid `includes` value"
    )
  })
})


# Validate dates -----------------------------------------------------------

test_that("get_vessel_insights: invalid start_date triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = "FISHING",
        start_date = "2020-01",
        end_date = "2025-03-03",
        vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f")
      ),
      regexp = "must be in YYYY-MM-DD"
    )
  })
})

test_that("get_vessel_insights: invalid end_date triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = "FISHING",
        start_date = "2020-01-01",
        end_date = "2025-03",
        vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f")
      ),
      regexp = "must be in YYYY-MM-DD"
    )
  })
})

test_that("get_vessel_insights: start_date > end_date triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = "FISHING",
        start_date = "2025-03-03",
        end_date = "2020-01-01",
        vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f")
      ),
      regexp = "must be less than or equal to `end_date`."
    )
  })
})


# Validate vessels ------------------------------------------------------------

test_that("get_vessel_insights: missing vessels triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = "FISHING",
        start_date = "2020-01-01",
        end_date = "2025-03-03",
        vessels = NULL
      ),
      regexp = "`vessels` is required"
    )
  })
})

test_that("get_vessel_insights: non-character vessels triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = "FISHING",
        start_date = "2020-01-01",
        end_date = "2025-03-03",
        vessels = c(1, NA, NULL, list(), c())
      ),
      regexp = "must be a non-empty character vector"
    )
  })
})

test_that("get_vessel_insights: empty or NA or NULL vessels trigger error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = "FISHING",
        start_date = "2020-01-01",
        end_date = "2025-03-03",
        vessels = c(" ", "", NA, NULL)
      ),
      regexp = "Invalid `vessels` value"
    )
  })
})

# Validate key ----------------------------------------------------------------

test_that("get_vessel_insights: NULL key triggers error", {
  expect_error(
    get_vessel_insights(
      includes = "FISHING",
      start_date = "2020-01-01",
      end_date = "2025-03-03",
      vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f"),
      key = NULL
    ),
    regexp = "No API token found"
  )
})

test_that("get_vessel_insights: NA key triggers error", {
  expect_error(
    get_vessel_insights(
      includes = "FISHING",
      start_date = "2020-01-01",
      end_date = "2025-03-03",
      vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f"),
      key = NA_character_
    ),
    regexp = "No API token found"
  )
})

test_that("get_vessel_insights: empty string key triggers error", {
  expect_error(
    get_vessel_insights(
      includes = "FISHING",
      start_date = "2020-01-01",
      end_date = "2025-03-03",
      vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f"),
      key = ""
    ),
    regexp = "No API token found"
  )
})

test_that("get_vessel_insights: NA `GFW_TOKEN` envvar key triggers error", {
  withr::with_envvar(c(GFW_TOKEN = NA_character_), {
    expect_error(
      get_vessel_insights(
        includes = "FISHING",
        start_date = "2020-01-01",
        end_date = "2025-03-03",
        vessels = c("785101812-2127-e5d2-e8bf-7152c5259f5f")
      ),
      regexp = "No API token found"
    )
  })
})


# API request -----------------------------------------------------------------

test_that("get_vessel_insights: returns vessel insights for multiple insight types", {
  with_gfw_mocked_envvar({
    mocked_url <- curl::curl_modify_url(gfw_base_url(), path = "insights/vessels")

    mocked_req_body <- with_gfw_json_fixture("insights/vessel_insight_request_body.json")
    mocked_req_body$includes <- unlist(mocked_req_body$includes)
    mocked_req_body$vessels <- unlist(mocked_req_body$vessels)

    mocked_resp_body <- with_gfw_json_fixture("insights/vessel_insight_item.json")

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 200,
        url = mocked_url,
        body = mocked_resp_body
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- get_vessel_insights(
        includes = mocked_req_body$includes,
        start_date = mocked_req_body$start_date,
        end_date = mocked_req_body$end_date,
        vessels = mocked_req_body$vessels
      )

      expect_s3_class(resp, "tbl_df")
      expect_equal(nrow(resp), 1)
      expect_setequal(colnames(resp), names(mocked_resp_body))

      expect_true(!is.null(resp$period))
      expect_identical(resp$period[[1]], mocked_resp_body$period)

      expect_true(!is.null(resp$vesselIdsWithoutIdentity))

      expect_true(!is.null(resp$gap))
      expect_identical(resp$gap[[1]], mocked_resp_body$gap)

      expect_true(!is.null(resp$coverage))

      expect_true(!is.null(resp$apparentFishing))
      expect_identical(resp$apparentFishing[[1]], mocked_resp_body$apparentFishing)

      expect_true(!is.null(resp$vesselIdentity))
      expect_identical(resp$vesselIdentity[[1]], mocked_resp_body$vesselIdentity)
    })
  })
})
