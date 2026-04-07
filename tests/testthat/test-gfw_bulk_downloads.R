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
      regexp = "`dataset` must be one of"
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
      regexp = "`format` must be one of"
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
      regexp = "`filters` must be a non-empty character vector with valid strings"
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
      expect_named(resp, names(mocked_resp_body), ignore.order = TRUE)

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

      expect_equal(resp$fileSize[[1]], mocked_resp_body$fileSize)
    })
  })
})

# gfw_get_bulk_report_by_id ---------------------------------------------------

## Validate id ----------------------------------------------------------------

test_that("gfw_get_bulk_report_by_id: missing id triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_bulk_report_by_id(
        id = NULL,
      ),
      regexp = "`id` is required"
    )
  })
})

test_that("gfw_get_bulk_report_by_id: empty or NA id triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_bulk_report_by_id(
        id = "",
      ),
      regexp = "`id` is required"
    )

    expect_error(
      gfw_get_bulk_report_by_id(
        id = NA_character_,
      ),
      regexp = "`id` is required"
    )
  })
})

## Validate key ---------------------------------------------------------------

test_that("gfw_get_bulk_report_by_id: NULL key triggers error", {
  expect_error(
    gfw_get_bulk_report_by_id(
      id = "adbb9b62-5c08-4142-82e0-b2b575f3e058",
      key = NULL
    ),
    regexp = "No API token found"
  )
})

test_that("gfw_get_bulk_report_by_id: empty key triggers error", {
  expect_error(
    gfw_get_bulk_report_by_id(
      id = "adbb9b62-5c08-4142-82e0-b2b575f3e058",
      key = ""
    ),
    regexp = "No API token found"
  )
})

test_that("gfw_get_bulk_report_by_id: NA envvar token triggers error", {
  withr::with_envvar(c(GFW_TOKEN = NA_character_), {
    expect_error(
      gfw_get_bulk_report_by_id(
        id = "adbb9b62-5c08-4142-82e0-b2b575f3e058",
      ),
      regexp = "No API token found"
    )
  })
})

## API request ----------------------------------------------------------------

test_that("gfw_get_bulk_report_by_id: returns bulk report tibble", {
  with_gfw_mocked_envvar({
    mocked_id <- "adbb9b62-5c08-4142-82e0-b2b575f3e058"
    mocked_url <- curl::curl_modify_url(gfw_base_url(), path = glue::glue("bulk-reports/{mocked_id}"))

    mocked_resp_body <- with_gfw_json_fixture("bulk_downloads/bulk_report_item.json")

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 200,
        url = mocked_url,
        body = mocked_resp_body
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- gfw_get_bulk_report_by_id(
        id = mocked_id,
      )

      expect_s3_class(resp, "tbl_df")
      expect_equal(nrow(resp), 1)
      expect_named(resp, names(mocked_resp_body), ignore.order = TRUE)

      expect_type(resp$id, "character")
      expect_type(resp$ownerId, "integer")
      expect_type(resp$geom, "list")
      expect_type(resp$filters, "list")

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

      expect_equal(resp$fileSize[[1]], mocked_resp_body$fileSize)
    })
  })
})

# gfw_get_bulk_report_file_download_url ---------------------------------------

## Validate id ----------------------------------------------------------------

test_that("gfw_get_bulk_report_file_download_url: missing id triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_bulk_report_file_download_url(
        id = NULL,
        file = "DATA"
      ),
      regexp = "`id` is required"
    )
  })
})

test_that("gfw_get_bulk_report_file_download_url: empty or NA id triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_bulk_report_file_download_url(
        id = "",
        file = "DATA"
      ),
      regexp = "`id` is required"
    )

    expect_error(
      gfw_get_bulk_report_file_download_url(
        id = NA_character_,
        file = "DATA"
      ),
      regexp = "`id` is required"
    )
  })
})

## Validate file ------------------------------------------------------------

test_that("gfw_get_bulk_report_file_download_url: missing file triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_bulk_report_file_download_url(
        id = "adbb9b62-5c08-4142-82e0-b2b575f3e058",
        file = NULL
      ),
      regexp = "`file` is required"
    )
  })
})

test_that("gfw_get_bulk_report_file_download_url: invalid file triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_bulk_report_file_download_url(
        id = "adbb9b62-5c08-4142-82e0-b2b575f3e058",
        file = "INVALID-FILE"
      ),
      regexp = "`file` must be one of"
    )
  })
})

## Validate key ---------------------------------------------------------------

test_that("gfw_get_bulk_report_file_download_url: NULL key triggers error", {
  expect_error(
    gfw_get_bulk_report_file_download_url(
      id = "adbb9b62-5c08-4142-82e0-b2b575f3e058",
      file = "DATA",
      key = NULL
    ),
    regexp = "No API token found"
  )
})

test_that("gfw_get_bulk_report_file_download_url: empty key triggers error", {
  expect_error(
    gfw_get_bulk_report_file_download_url(
      id = "adbb9b62-5c08-4142-82e0-b2b575f3e058",
      file = "DATA",
      key = ""
    ),
    regexp = "No API token found"
  )
})

test_that("gfw_get_bulk_report_file_download_url: NA envvar token triggers error", {
  withr::with_envvar(c(GFW_TOKEN = NA_character_), {
    expect_error(
      gfw_get_bulk_report_file_download_url(
        id = "adbb9b62-5c08-4142-82e0-b2b575f3e058",
        file = "DATA"
      ),
      regexp = "No API token found"
    )
  })
})

## API request ----------------------------------------------------------------

test_that("gfw_get_bulk_report_file_download_url: returns bulk report tibble", {
  with_gfw_mocked_envvar({
    mocked_id <- "adbb9b62-5c08-4142-82e0-b2b575f3e058"
    mocked_file <- "DATA"
    mocked_url <- curl::curl_modify_url(
      gfw_base_url(),
      path = glue::glue("bulk-reports/{mocked_id}/download-file-url?file={mocked_file}")
    )

    mocked_resp_body <- with_gfw_json_fixture("bulk_downloads/bulk_report_file_item.json")

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 200,
        url = mocked_url,
        body = mocked_resp_body
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- gfw_get_bulk_report_file_download_url(
        id = mocked_id,
        file = mocked_file
      )

      expect_s3_class(resp, "tbl_df")
      expect_equal(nrow(resp), 1)
      expect_named(resp, names(mocked_resp_body), ignore.order = TRUE)

      expect_type(resp$url, "character")
      expect_identical(resp$url[[1]], mocked_resp_body$url)
    })
  })
})

# gfw_gfw_get_all_bulk_reports ------------------------------------------------

## Validate limit -------------------------------------------------------------

test_that("gfw_get_all_bulk_reports: invalid limit triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_all_bulk_reports(
        limit = "INVALID-LIMIT",
      ),
      regexp = "`limit` must be a non-negative integer value"
    )
  })
})

## Validate offset ------------------------------------------------------------

test_that("gfw_get_all_bulk_reports: invalid offset triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_all_bulk_reports(
        offset = "INVALID-OFFSET",
      ),
      regexp = "`offset` must be a non-negative integer value"
    )
  })
})

## Validate sort --------------------------------------------------------------

test_that("gfw_get_all_bulk_reports: empty or NA sort triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_all_bulk_reports(
        sort = ""
      ),
      regexp = "`sort` must be a non-empty character string"
    )

    expect_error(
      gfw_get_all_bulk_reports(
        sort = NA_character_
      ),
      regexp = "`sort` must be a non-empty character string"
    )
  })
})

test_that("gfw_get_all_bulk_reports: invalid sort triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_all_bulk_reports(
        sort = 123
      ),
      regexp = "`sort` must be a non-empty character string"
    )
  })
})

## Validate status ------------------------------------------------------------

test_that("gfw_get_all_bulk_reports: empty or NA status triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_all_bulk_reports(
        status = ""
      ),
      regexp = "`status` must be one of"
    )

    expect_error(
      gfw_get_all_bulk_reports(
        status = NA_character_
      ),
      regexp = "`status` must be a single string, not a character `NA`"
    )
  })
})

test_that("gfw_get_all_bulk_reports: invalid status triggers error", {
  with_gfw_mocked_envvar({
    expect_error(
      gfw_get_all_bulk_reports(
        status = "INVALID-STATUS"
      ),
      regexp = "`status` must be one of"
    )
  })
})

## Validate key ---------------------------------------------------------------

test_that("gfw_get_all_bulk_reports: NULL key triggers error", {
  expect_error(
    gfw_get_all_bulk_reports(
      status = "done",
      key = NULL
    ),
    regexp = "No API token found"
  )
})

test_that("gfw_get_all_bulk_reports: empty key triggers error", {
  expect_error(
    gfw_get_all_bulk_reports(
      status = "done",
      key = ""
    ),
    regexp = "No API token found"
  )
})

test_that("gfw_get_all_bulk_reports: NA envvar token triggers error", {
  withr::with_envvar(c(GFW_TOKEN = NA_character_), {
    expect_error(
      gfw_get_all_bulk_reports(
        status = "done"
      ),
      regexp = "No API token found"
    )
  })
})

## API request ----------------------------------------------------------------

test_that("gfw_get_all_bulk_reports: returns bulk reports tibble", {
  with_gfw_mocked_envvar({
    mocked_params <- with_gfw_json_fixture("bulk_downloads/bulk_report_list_request_params.json")
    mocked_url <- curl::curl_modify_url(
      gfw_base_url(),
      path = "bulk-reports",
      query = mocked_params
    )

    mocked_item <- with_gfw_json_fixture("bulk_downloads/bulk_report_item.json")
    mocked_resp_body <- list(entries = list(mocked_item))

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 200,
        url = mocked_url,
        body = mocked_resp_body
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- gfw_get_all_bulk_reports(
        limit = mocked_params$limit,
        offset = mocked_params$offset,
        sort = mocked_params$sort,
        status = mocked_params$status
      )

      expect_s3_class(resp, "tbl_df")
      expect_equal(nrow(resp), 1)
      expect_named(resp, names(mocked_item), ignore.order = TRUE)

      expect_type(resp$id, "character")
      expect_type(resp$ownerId, "integer")
      expect_type(resp$geom, "list")
      expect_type(resp$filters, "list")

      expect_identical(resp$id[[1]], mocked_item$id)
      expect_identical(resp$name[[1]], mocked_item$name)
      expect_identical(resp$filepath[[1]], mocked_item$filepath)
      expect_identical(resp$format[[1]], mocked_item$format)
      expect_identical(resp$status[[1]], mocked_item$status)
      expect_identical(resp$filters[[1]], mocked_item$filters)

      expect_true(!is.null(resp$geom))
      expect_identical(resp$geom[[1]]$dataset, mocked_item$geom$dataset)
      expect_identical(resp$geom[[1]]$id, mocked_item$geom$id)

      expect_identical(resp$ownerId[[1]], mocked_item$ownerId)
      expect_identical(resp$ownerType[[1]], mocked_item$ownerType)

      expect_identical(resp$createdAt[[1]], mocked_item$createdAt)
      expect_identical(resp$updatedAt[[1]], mocked_item$updatedAt)

      expect_equal(resp$fileSize[[1]], mocked_item$fileSize)
    })
  })
})

test_that("gfw_get_all_bulk_reports: empty entries returns empty tibble", {
  with_gfw_mocked_envvar({
    mocked_params <- with_gfw_json_fixture("bulk_downloads/bulk_report_list_request_params.json")

    mocked_resp_body <- list(entries = list())

    mocked_url <- curl::curl_modify_url(
      gfw_base_url(),
      path = "bulk-reports",
      query = mocked_params
    )

    mocked_resp <- function(req) {
      httr2::response_json(
        status_code = 200,
        url = mocked_url,
        body = mocked_resp_body
      )
    }

    httr2::with_mocked_responses(mocked_resp, {
      resp <- gfw_get_all_bulk_reports(
        status = mocked_params$status
      )

      expect_s3_class(resp, "tbl_df")
      expect_equal(nrow(resp), 0)
    })
  })
})
