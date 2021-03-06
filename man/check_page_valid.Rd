% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_page_valid.R
\name{check_page_valid}
\alias{check_page_valid}
\title{Check if the current page is scrape-able via a simple scrape attempt}
\usage{
check_page_valid(WebDriver = remDr, show_original_error = TRUE)
}
\arguments{
\item{WebDriver}{Active binding object containing the active WebDriver.}

\item{show_original_error}{TRUE/FALSE to show details if an error is encountered.}
}
\value{
A character vector indicating whether the page is valid or not.
}
\description{
Attempt to access the table on the current NOAA archive page in
order to detect whether said page is scrape-able.
}
