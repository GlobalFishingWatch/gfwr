# Helpers for gfwr tests

MOCK_GFW_BASE_URL <- "https://gateway.api.mocking.globalfishingwatch.org/v3/" # nolint: object_name_linter.
MOCK_GFW_TOKEN <- "mocking_GoXcgX1YFRRph48Rv6w9aGIDQzQd7zaB" # nolint: object_name_linter.
MOCK_GFW_DATA_DIR <- tempfile("mocking_data_dir") # nolint: object_name_linter.

#' Temporarily mock the GFW API base URL for testing
#'
#' @description
#' Sets the `GFW_BASE_URL` environment variable to a test value for the
#' duration of the provided expression. This ensures API helper functions
#' never call the real Global Fishing Watch API during tests.
#'
#' @param code Code to execute with the mocked base URL.
#'
#' @return The result of `code`.
#' @keywords testing internal
#'
#' @examples
#' \dontrun{
#' with_gfw_mocked_base_url({
#'   gfw_base_url() # returns mocked URL
#' })
#' }
with_gfw_mocked_base_url <- function(code) {
  withr::with_envvar(c(GFW_BASE_URL = MOCK_GFW_BASE_URL), code)
}

#' Temporarily mock the GFW API access token for testing
#'
#' @description
#' Sets the `GFW_TOKEN` environment variable to a test value for
#' the duration of the provided expression. This ensures authentication logic
#' is tested without requiring real credentials.
#'
#' @param code Code to execute with the mocked token.
#'
#' @return The result of `code`.
#' @keywords testing internal
#'
#' @examples
#' \dontrun{
#' with_gfw_mocked_token({
#'   gfw_auth() # returns mocked token
#' })
#' }
with_gfw_mocked_token <- function(code) {
  withr::with_envvar(c(GFW_TOKEN = MOCK_GFW_TOKEN), code)
}

#' Temporarily mock the GFW data directory for testing
#'
#' @description
#' Sets the `GFW_DATA_DIR` environment variable to a temporary test
#' directory for the duration of the provided expression. The directory
#' is created if it does not already exist. This ensures file-based
#' operations do not affect real user data.
#'
#' @param code Code to execute with the mocked data directory.
#'
#' @return The result of `code`.
#' @keywords testing internal
#'
#' @examples
#' \dontrun{
#' with_gfw_mocked_data_dir({
#'   Sys.getenv("GFW_DATA_DIR") # returns mocked directory
#' })
#' }
with_gfw_mocked_data_dir <- function(code) {
  if (!dir.exists(MOCK_GFW_DATA_DIR)) {
    dir.create(MOCK_GFW_DATA_DIR, recursive = TRUE)
  }

  withr::with_envvar(c(GFW_DATA_DIR = MOCK_GFW_DATA_DIR), code)
}

#' Temporarily mock *both* the GFW API base URL and access token
#'
#' @description
#' Convenience helper combining `with_gfw_mocked_base_url()`,
#' `with_gfw_mocked_token()`, and `with_gfw_mocked_data_dir()`.
#' Most API tests need both values overridden, so this helper keeps
#' tests concise and consistent.
#'
#' @param code Code to execute in the fully mocked environment.
#'
#' @return The result of `code`.
#' @keywords testing internal
#'
#' @examples
#' \dontrun{
#' with_gfw_mocked_envvar({
#'   gfw_base_url() # returns mocked URL
#'   gfw_auth() # returns mocked token
#'   Sys.getenv("GFW_DATA_DIR") # returns mocked directory
#' })
#' }
with_gfw_mocked_envvar <- function(code) {
  if (!dir.exists(MOCK_GFW_DATA_DIR)) {
    dir.create(MOCK_GFW_DATA_DIR, recursive = TRUE)
  }

  withr::with_envvar(c(
    GFW_BASE_URL = MOCK_GFW_BASE_URL,
    GFW_TOKEN = MOCK_GFW_TOKEN,
    GFW_DATA_DIR = MOCK_GFW_DATA_DIR
  ), code)
}

#' Load a JSON fixture for testing
#'
#' @description
#' Reads a JSON file from `tests/testthat/fixtures/` and converts it
#' into an R object. This is useful for mocking API responses or
#' providing consistent test data.
#'
#' @param filename Name of the JSON file in the `fixtures` folder.
#'
#' @return An R list or data frame representing the JSON contents.
#' @keywords testing internal
#'
#' @examples
#' \dontrun{
#' fixture <- with_json_fixture("sample.json")
#' fixture$id # access elements
#' fixture$name
#' }
with_gfw_json_fixture <- function(filename) {
  fixture_path <- testthat::test_path("fixtures", filename)
  fixture_data <- jsonlite::fromJSON(fixture_path, simplifyVector = FALSE)
  return(fixture_data) # nolint: return_linter.
}

#' Load a file fixture for testing
#'
#' @description
#' Reads a file from `tests/testthat/fixtures/` as a binary data.
#' This is useful for mocking API responses or
#' providing consistent test data.
#'
#' @param filename Name of the file in the `fixtures` folder.
#'
#' @return Binary data representing the file contents.
#' @keywords testing internal
#'
#' @examples
#' \dontrun{
#' fixture <- with_gfw_file_fixture("sample.txt")
#'
#' resp <- httr2::response(
#'   status_code = status,
#'   headers = headers,
#'   body = fixture
#' )
#' }
with_gfw_file_fixture <- function(filename) {
  fixture_path <- testthat::test_path("fixtures", filename)

  file_size <- file.info(fixture_path)$size
  fixture_data <- readBin(fixture_path, what = "raw", n = file_size)

  return(fixture_data) # nolint: return_linter.
}