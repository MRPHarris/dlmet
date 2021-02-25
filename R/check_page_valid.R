#' Check if the current page is scrape-able via a simple scrape attempt
#'
#' @description Attempt to access the table on the current NOAA archive page in
#' order to detect whether said page is scrape-able.
#'
#' @param WebDriver Active binding object containing the active WebDriver.
#' @param show_original_error TRUE/FALSE to show details if an error is encountered.
#'
#' @return A character vector indicating whether the page is valid or not.
#' @export
#'
#'
check_page_valid <- function(WebDriver = remDr,
                             show_original_error = TRUE){
  if(!require("pacman")){
    install.packages("pacman")
  }
  pacman::p_load(binman,magrittr,pacman,pingr,rJava,RSelenium,tidyverse,utils,XML,xml2)
  currenturl <- as.character(WebDriver$client$getCurrentUrl())
  out <- tryCatch({
    suppressMessages({
      html_table <- WebDriver$client$findElement(using = 'xpath', "/html/body/table") # Finds met file html table matching xpath
      Elemtxt <- html_table$getElementAttribute("outerHTML")[[1]] # gets the html attributes to a text file
      xml_table <-  read_html(Elemtxt) # Reads html details to xml table
      dump_xml <- xmlParse(xml_table)
      return("Page valid")
    }) # Parses xml table
  },
  error = function(cond) {
    error_msg_elmnt <- WebDriver$client$findElement(using = 'xpath',"/html/body/div[1]/div[1]/div[2]/h1/span")
    error_msg_txt <- error_msg_elmnt$getElementText()
    message(paste0("URL isn't valid: ", currenturl))
    message(paste0("Reason: ", error_msg_txt))
    if(isTRUE(show_original_error)){
      message("Here's the original error message:")
      message(cond)
    }
    return("Error")
  },
  warning=function(cond) {
    message(paste0("URL caused a warning:", currenturl))
    if(isTRUE(show_original_error)){
      message("Here's the original warning message:")
      message(cond)
    }
  }
  )
}
