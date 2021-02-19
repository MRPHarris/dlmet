#' Check if the current page is scrape-able via a simple scrape attempt
#'
#' @description Attempt to access the table on the current NOAA archive page in
#' order to detect whether said page is scrape-able.
#'
#' @param show_original_error if an error is triggered, show the details?
#'
#' @return A character vector indicating whether the page is valid or not.
#' @export
#'
#' @examples
#' check_page_valid(show_original_error = TRUE)
#'
check_page_valid <- function(show_original_error = FALSE){
  currenturl <- as.character(remDr$client$getCurrentUrl())
  out <- tryCatch({
    suppressMessages({
      html_table <- remDr$client$findElement(using = 'xpath', "/html/body/table") # Finds met file html table matching xpath
      Elemtxt <- html_table$getElementAttribute("outerHTML")[[1]] # gets the html attributes to a text file
      xml_table <-  read_html(Elemtxt) # Reads html details to xml table
      dump_xml <- xmlParse(xml_table)
      return("Page valid")
    }) # Parses xml table
  },
  error = function(cond) {
    error_msg_elmnt <- remDr$client$findElement(using = 'xpath',"/html/body/div[1]/div[1]/div[2]/h1/span")
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
