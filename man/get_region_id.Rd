% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{get_region_id}
\alias{get_region_id}
\title{Function to pull numeric EEZ code using EEZ name}
\usage{
get_region_id(region_name, region_source = "eez", key)
}
\arguments{
\item{region_name}{string or numeric, EEZ/MPA name or EEZ/MPA id}

\item{region_source}{string, source of region data ('eez' or 'mpa')}

\item{key}{string, API token}
}
\value{
dataframe, eez code and EEZ name for matching EEZs
}
\description{
Function to pull numeric EEZ code using EEZ name
}
