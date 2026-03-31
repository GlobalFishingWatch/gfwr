# gfw_create_bulk_report ------------------------------------------------------

## Validate name --------------------------------------------------------------

test_that("gfw_create_bulk_report: missing name triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_create_bulk_report(
        name = NULL,
        dataset = "public-fixed-infrastructure-data:latest",
        format = "JSON"
      ),
      regexp = "`name` is required"
    )
  })
})

test_that("gfw_create_bulk_report: empty or NA name triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_create_bulk_report(
        name = "",
        dataset = "public-fixed-infrastructure-data:latest",
        format = "JSON"
      ),
      regexp = "`name` is required"
    )

    expect_error(
      gfw_create_bulk_report(
        name = NA_character_,
        dataset = "public-fixed-infrastructure-data:latest",
        format = "JSON"
      ),
      regexp = "`name` is required"
    )
  })
})

## Validate dataset -----------------------------------------------------------

test_that("gfw_create_bulk_report: missing dataset triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_create_bulk_report(
        name = "test",
        dataset = NULL,
        format = "JSON"
      ),
      regexp = "`dataset` is required"
    )
  })
})

test_that("gfw_create_bulk_report: invalid dataset triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_create_bulk_report(
        name = "test",
        dataset = "INVALID-DATASET",
        format = "JSON"
      ),
      regexp = "Invalid `dataset` value"
    )
  })
})

## Validate format ------------------------------------------------------------

test_that("gfw_create_bulk_report: missing format triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_create_bulk_report(
        name = "test",
        dataset = "public-fixed-infrastructure-data:latest",
        format = NULL
      ),
      regexp = "`format` is required"
    )
  })
})

test_that("gfw_create_bulk_report: invalid format triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_create_bulk_report(
        name = "test",
        dataset = "public-fixed-infrastructure-data:latest",
        format = "INVALID-FORMAT"
      ),
      regexp = "Invalid `format` value"
    )
  })
})

## Validate filters -----------------------------------------------------------

test_that("gfw_create_bulk_report: invalid filters type triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_create_bulk_report(
        name = "test",
        dataset = "public-fixed-infrastructure-data:latest",
        format = "JSON",
        filters = list("label = 'oil'")
      ),
      regexp = "`filters` must be a non-empty character vector"
    )
  })
})

test_that("gfw_create_bulk_report: empty or NA filters trigger error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_create_bulk_report(
        name = "test",
        dataset = "public-fixed-infrastructure-data:latest",
        format = "JSON",
        filters = c("", NA)
      ),
      regexp = "Invalid `filters` value"
    )
  })
})

## Validate key ---------------------------------------------------------------

test_that("gfw_create_bulk_report: NULL key triggers error", {
  expect_error(
    gfw_create_bulk_report(
      name = "test",
      dataset = "public-fixed-infrastructure-data:latest",
      format = "JSON",
      key = NULL
    ),
    regexp = "No API token found"
  )
})

test_that("gfw_create_bulk_report: empty key triggers error", {
  expect_error(
    gfw_create_bulk_report(
      name = "test",
      dataset = "public-fixed-infrastructure-data:latest",
      format = "JSON",
      key = ""
    ),
    regexp = "No API token found"
  )
})

test_that("gfw_create_bulk_report: NA envvar token triggers error", {
  withr::with_envvar(c(GFW_TOKEN = NA_character_), {
    expect_error(
      gfw_create_bulk_report(
        name = "test",
        dataset = "public-fixed-infrastructure-data:latest",
        format = "JSON"
      ),
      regexp = "No API token found"
    )
  })
})

## API request ----------------------------------------------------------------

test_that("gfw_create_bulk_report: returns bulk report tibble", {
  with_gfw_mocked_envvar({
    mocked_url <- curl::curl_modify_url(gfw_base_url(), path = "bulk-reports")

    mocked_req_body <- with_gfw_json_fixture("bulk_downloads/bulk_report_create_request_body.json")

    mocked_resp_body <- with_gfw_json_fixture("bulk_downloads/bulk_report_item.json")

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 200,
        url = mocked_url,
        body = mocked_resp_body
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- gfw_create_bulk_report(
        name = mocked_req_body$name,
        dataset = mocked_req_body$dataset,
        format = mocked_req_body$format,
        filters = unlist(mocked_req_body$filters)
      )

      expect_s3_class(resp, "tbl_df")
      expect_equal(nrow(resp), 1)
      expect_setequal(colnames(resp), names(mocked_resp_body))

      expect_identical(resp$id[[1]], mocked_resp_body$id)
      expect_identical(resp$name[[1]], mocked_resp_body$name)
      expect_identical(resp$filepath[[1]], mocked_resp_body$filepath)
      expect_identical(resp$format[[1]], mocked_resp_body$format)
      expect_identical(resp$status[[1]], mocked_resp_body$status)
      expect_identical(resp$filters[[1]], mocked_resp_body$filters)

      expect_true(!is.null(resp$geom))
      expect_identical(resp$geom[[1]]$dataset, mocked_resp_body$geom$dataset)
      expect_identical(resp$geom[[1]]$id, mocked_resp_body$geom$id)

      expect_identical(resp$ownerId[[1]], mocked_resp_body$ownerId)
      expect_identical(resp$ownerType[[1]], mocked_resp_body$ownerType)

      expect_identical(resp$createdAt[[1]], mocked_resp_body$createdAt)
      expect_identical(resp$updatedAt[[1]], mocked_resp_body$updatedAt)

      expect_identical(as.double(resp$fileSize[[1]]), as.double(mocked_resp_body$fileSize))
    })
  })
})
