% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/navigate_client.R
\name{navigate_client}
\alias{navigate_client}
\title{Navigate an RSelenium WebDriver client}
\usage{
navigate_client(
  navigate_to = "ftp://arlftp.arlhq.noaa.gov/archives/",
  WebDriver = remDr
)
}
\arguments{
\item{navigate_to}{A URL to navigate to.}

\item{WebDriver}{Active binding object containing the active WebDriver.}
}
\description{
A very simple wrapper for client$navigate that navigates to a given URL.
}
