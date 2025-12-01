# Validate includes -----------------------------------------------------------

test_that("get_vessel_insights: missing includes triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = NULL,
        start_date = "2020-01-01",
        end_date = "2025-03-03",
        vessels = list(
          list(
            dataset_id = "public-global-vessel-identity:latest",
            vessel_id = "785101812-2127-e5d2-e8bf-7152c5259f5f"
          )
        )
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
        vessels = list(
          list(
            dataset_id = "public-global-vessel-identity:latest",
            vessel_id = "785101812-2127-e5d2-e8bf-7152c5259f5f"
          )
        )
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
        vessels = list(
          list(
            dataset_id = "public-global-vessel-identity:latest",
            vessel_id = "785101812-2127-e5d2-e8bf-7152c5259f5f"
          )
        )
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
        vessels = list(
          list(
            dataset_id = "public-global-vessel-identity:latest",
            vessel_id = "785101812-2127-e5d2-e8bf-7152c5259f5f"
          )
        )
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
        vessels = list(
          list(
            dataset_id = "public-global-vessel-identity:latest",
            vessel_id = "785101812-2127-e5d2-e8bf-7152c5259f5f"
          )
        )
      ),
      regexp = "must be <= `end_date`"
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

test_that("get_vessel_insights: invalid vessels dataset_id triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = "FISHING",
        start_date = "2020-01-01",
        end_date = "2025-03-03",
        vessels = list(
          list(
            dataset_id = NULL,
            vessel_id = "785101812-2127-e5d2-e8bf-7152c5259f5f"
          )
        )
      ),
      regexp = "must be a list with non-empty `dataset_id` and `vessel_id`"
    )
  })
})

test_that("get_vessel_insights: invalid vessels vessel_id triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      get_vessel_insights(
        includes = "FISHING",
        start_date = "2020-01-01",
        end_date = "2025-03-03",
        vessels = list(
          list(
            dataset_id = "public-global-vessel-identity:latest",
            vessel_id = NULL
          )
        )
      ),
      regexp = "must be a list with non-empty `dataset_id` and `vessel_id`"
    )
  })
})

# Validate key ----------------------------------------------------------------

test_that("get_vessel_insights: invalid key triggers error", {
  expect_error(
    get_vessel_insights(
      includes = "FISHING",
      start_date = "2020-01-01",
      end_date = "2025-03-03",
      vessels = list(
        list(
          dataset_id = "public-global-vessel-identity:latest",
          vessel_id = "785101812-2127-e5d2-e8bf-7152c5259f5f"
        )
      ),
      key = NA
    ),
    regexp = "No API token found"
  )
})

test_that("get_vessel_insights: invalid key triggers error", {
  withr::with_envvar(c(GFW_TOKEN = NA), {
    expect_error(
      get_vessel_insights(
        includes = "FISHING",
        start_date = "2020-01-01",
        end_date = "2025-03-03",
        vessels = list(
          list(
            dataset_id = "public-global-vessel-identity:latest",
            vessel_id = "785101812-2127-e5d2-e8bf-7152c5259f5f"
          )
        )
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
      expect_true(!is.null(resp$period))
      expect_true(!is.null(resp$period$startDate))
      expect_true(!is.null(resp$period$endDate))
      expect_true(!is.null(resp$gap))
      expect_true(!is.null(resp$gap$datasets))
      expect_true(!is.null(resp$gap$historicalCounters))
      expect_true(!is.null(resp$gap$periodSelectedCounters))
      expect_true(!is.null(resp$gap$aisOff))
      expect_true(!is.null(resp$coverage))
      expect_true(!is.null(resp$coverage$blocks))
      expect_true(!is.null(resp$coverage$blocksWithPositions))
      expect_true(!is.null(resp$coverage$percentage))
      expect_true(!is.null(resp$apparentFishing))
      expect_true(!is.null(resp$apparentFishing$datasets))
      expect_true(!is.null(resp$apparentFishing$historicalCounters))
      expect_true(!is.null(resp$apparentFishing$periodSelectedCounters))
      expect_true(!is.null(resp$apparentFishing$eventsInRfmoWithoutKnownAuthorization))
      expect_true(!is.null(resp$apparentFishing$eventsInNoTakeMpas))
      expect_true(!is.null(resp$vesselIdentity))
      expect_true(!is.null(resp$vesselIdentity$datasets))
      expect_true(!is.null(resp$vesselIdentity$iuuVesselList))
    })
  })
})
