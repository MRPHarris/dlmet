#' Get the current URL of active the WebDriver client
#'
#' A very simple wrapper for client$getCurrentURL that returns the current URL
#'
#' @param WebDriver Active binding object containing the active WebDriver.
#'
#' @export
#'
#' @example
#' navigate_client("https://www.bbc.com/")

current_URL <- function(WebDriver = remDr){
  return(as.character(WebDriver$client$getCurrentUrl()))
}
