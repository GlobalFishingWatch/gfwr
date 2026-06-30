# Helpers for gfwr tests

MOCK_GFW_BASE_URL <- "https://gateway.api.mocking.globalfishingwatch.org/v3/" # nolint: object_name_linter.
MOCK_GFW_TOKEN <- "mocking_GoXcgX1YFRRph48Rv6w9aGIDQzQd7zaB" # nolint: object_name_linter.

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

#' Temporarily mock *both* the GFW API base URL and access token
#'
#' @description
#' Convenience helper combining `with_gfw_mocked_base_url()` and
#' `with_gfw_mocked_token()`. Most API tests need both values
#' overridden, so this helper keeps tests concise and consistent.
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
#' })
#' }
with_gfw_mocked_envvar <- function(code) {
  withr::with_envvar(c(
    GFW_BASE_URL = MOCK_GFW_BASE_URL,
    GFW_TOKEN = MOCK_GFW_TOKEN
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
