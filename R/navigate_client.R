#' Navigate an RSelenium WebDriver client
#'
#' A very simple wrapper for client$navigate that navigates to a given URL.
#'
#' @param navigate_to A URL to navigate to.
#' @param WebDriver Active binding object containing the active WebDriver.
#'
#' @export
#'

navigate_client <- function(navigate_to = "ftp://arlftp.arlhq.noaa.gov/archives/",
                            WebDriver = remDr){
  if(!require("pacman")){
    install.packages("pacman")
  }
  pacman::p_load(binman,rJava,RSelenium,tidyverse)
  WebDriver$client$navigate(navigate_to)
}
