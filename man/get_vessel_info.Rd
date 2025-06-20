% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_vessel_info.R
\name{get_vessel_info}
\alias{get_vessel_info}
\title{Base function to get vessel information from API and convert response to tibble}
\usage{
get_vessel_info(
  query = NULL,
  where = NULL,
  search_type = "search",
  ids = NULL,
  includes = c("AUTHORIZATIONS", "OWNERSHIP", "MATCH_CRITERIA"),
  match_fields = NULL,
  registries_info_data = c("ALL"),
  key = gfw_auth(),
  quiet = FALSE,
  print_request = FALSE,
  ...
)
}
\arguments{
\item{query}{When \code{search_type = "search"}, a length-1 vector with the identity
variable of interest, MMSI, IMO, call sign or ship name.}

\item{where}{When \code{search_type = "search"}, an SQL expression to find the vessel of interest.}

\item{search_type}{Type of vessel search to perform. Can be \code{"search"} (the default)
or \code{"id"}. (Note:\code{"advanced"} and \code{"basic"} are no longer in use as of gfwr 2.0.0.).}

\item{ids}{When \code{search_type = "id"}, a vector with the \code{vesselId} of interest.}

\item{includes}{Enhances the response with new information, defaults to include all.
\describe{
\item{\code{"OWNERSHIP"}}{returns ownership information}
\item{\code{"AUTHORIZATIONS"}}{lists public authorizations for that vessel}
\item{\code{"MATCH_CRITERIA"}}{adds information about the reason why a vessel is returned}
}}

\item{match_fields}{Optional. Allows to filter by \code{matchFields} levels.
Possible values: \code{"SEVERAL_FIELDS"}, \code{"NO_MATCH"}, \code{"ALL"}. Incompatible with \code{where}.}

\item{registries_info_data}{when \code{search_type == "id"}, gets all the registry
objects, only the delta or the latest.
\describe{
\item{\code{"NONE"}}{The API will return the most recent object only}
\item{\code{"DELTA"}}{The API will return only the objects when the vessel
changed one or more identity properties}
\item{\code{"ALL"}}{The \code{registryInfo} array will return all objects we have in the vessel database}
}}

\item{key}{Character, API token. Defaults to \code{\link[=gfw_auth]{gfw_auth()}}.}

\item{quiet}{Boolean. Whether to print the number of events returned by the
request and progress. Default is FALSE.}

\item{print_request}{Boolean. Whether to print the request, for debugging
purposes. When contacting the GFW team it will be useful to send this string.}

\item{...}{Other parameters, see API documentation.}
}
\description{
Base function to get vessel information from API and convert response to tibble
}
\details{
When \code{search_type = "search"} the search takes basic identity features like
MMSI, IMO, callsign, shipname as inputs, using parameter \code{"query"}. For more advanced
SQL searches, use parameter \code{"where"}. You can combine logic operators like \code{AND},
\code{OR}, \code{=}, \code{>=} , <, \code{LIKE} (for fuzzy matching). The \code{id} search allows the user
to search using a GFW \code{vesselId}.
}
\examples{
\dontrun{
library(gfwr)
# Simple searches, using includes
get_vessel_info(query = 224224000, search_type = "search",
key = gfw_auth())
# Advanced search with where instead of query:
get_vessel_info(where = "ssvid = '441618000' OR imo = '9047271'",
search_type = "search", key = gfw_auth())
 # Vessel id search
 get_vessel_info(search_type = "id",
 ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01",
 "6583c51e3-3626-5638-866a-f47c3bc7ef7c"), key = gfw_auth())
 all <- get_vessel_info(search_type = "id",
 ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
 registries_info_data = c("ALL"), key = gfw_auth())
 none <- get_vessel_info(search_type = "id",
 ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
 registries_info_data = c("NONE"), key = gfw_auth())
 delta <- get_vessel_info(search_type = "id",
 ids = c("8c7304226-6c71-edbe-0b63-c246734b3c01"),
 registries_info_data = c("DELTA"),
 key = gfw_auth())
 }
}
