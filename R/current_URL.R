#' Get the current URL of active the WebDriver client
#'
#' A very simple wrapper for client$getCurrentURL that returns the current URL
#'
#' @param WebDriver Active binding object containing the active WebDriver.
#'
#' @export
#'

current_URL <- function(WebDriver = remDr){
  if(!require("pacman")){
    install.packages("pacman")
  }
  pacman::p_load(binman,rJava,RSelenium,tidyverse)
  return(as.character(WebDriver$client$getCurrentUrl()))
}
