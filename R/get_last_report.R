#'
#' Base function to get status of last report generated
#'
#' @name get_last_report
#' @param key Authorization token. Can be obtained with `gfw_auth()` function
#' @importFrom httr2 request
#' @importFrom httr2 req_headers
#' @importFrom httr2 req_error
#' @importFrom httr2 req_perform
#' @importFrom httr2 resp_body_json
#' @importFrom httr2 req_user_agent
#' @importFrom httr2 resp_body_raw
#' @importFrom utils unzip
#' @importFrom readr read_csv
#'
#' @export
#'
#' @description
#' Function to check the status of the last API request sent with get_raster().
#'
#' @details
#' The `get_last_report()` function will tell you if the APIs are still processing your request and
#' will download the results if the request has finished successfully. You will receive an error message
#' if the request finished but resulted in an error or if it's been >30 minutes since the last report was
#' generated using `get_raster()`.
#'
#' For more information, see the https://globalfishingwatch.org/our-apis/documentation#get-last-report-generated.
#'
#' @examples
#' \dontrun{
#' get_last_report(key = gfw_auth())
#' }
#'
get_last_report <- function(key) {

  # Format request
  endpoint <- httr2::request("https://gateway.api.globalfishingwatch.org/v3/4wings/last-report") %>%
    httr2::req_headers(Authorization = paste("Bearer",
                                             key,
                                             sep = " ")) %>%
    httr2::req_user_agent(gfw_user_agent()) %>%
    httr2::req_error(body = parse_response_error)

    # Perform request
    response <- req_perform(endpoint)

  tryCatch(
    {

      # If response type is zip, it's the completed report
      if(response$headers$`content-type` == 'application/zip') {

        # Process raw response to extract zip file
        response <- response %>%
          httr2::resp_body_raw(.)

        # save zip and get .csv file name
        temp <- tempfile()
        writeBin(response, temp)
        names <- utils::unzip(temp, list = TRUE)$Name

        # unzip zip file and extract .csv
        file <- unz(temp, names[grepl(".csv$", names)])
        return(readr::read_csv(file))

        }

      else if(response$headers$`content-type` == 'application/json'){

        response <- response %>%
          httr2::resp_body_json()

        return(response)

        }

    },
    error = function(cond) {
      # response <- response() %>% httr2::resp_body_json()
      message("Here's the original error message:")
      message(conditionMessage(cond))
      # Choose a return value in case of error
      NA
    },
    warning = function(cond) {
      message(paste("Request caused a warning:", url))
      message("Here's the original warning message:")
      message(conditionMessage(cond))
      # Choose a return value in case of warning
      NULL
    }
  )
}
