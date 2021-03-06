#' List objects on the current NOAA ftp archive page.
#'
#' @description Interrogate/list contents of the table on the current NOAA ftp server page.
#'
#' @param object_type Scrape names/details of type 'file','folder', or 'all'.
#' @param trim TRUE/FALSE to remove columns other than filenames.
#' @param return TRUE/FALSE to return the scraped data.
#'
#' @return A data frame containing all the filenames of object_type from the current client web page.
#' @export
#'
#' @examples
#' list_objects_onpage(object_type = "file", output_names = FALSE)
grab_objects_onpage <- function(object_type = "all",
                                trim = FALSE,
                                return = TRUE){
  if(!require("pacman")){
    install.packages("pacman")
  }
  pacman::p_load(binman,magrittr,pacman,pingr,rJava,RSelenium,tidyverse,utils,XML,xml2)
  message(paste0("Checking page with check_page_valid()","\n","..."))
  check <- check_page_valid()
  if(check == "Error"){
    stop("The current page can't be scraped.","\n",
         "The client is likely not on a page the NOAA archive or a valid subdirectory of the NOAA archive.")
  } else if(check == "Page valid"){
    message("Page is valid. Scraping.","\n","...")
  }
  if(!isTRUE(object_type == "file") && !isTRUE(object_type == "folder") && !isTRUE(object_type == "all")){
    stop("please specify object_type as one of 'file', 'folder' or 'all'")
  }
  html_table <- remDr$client$findElement(using = 'xpath', "/html/body/table/tbody") # Finds met file html table matching xpath
  Elemtxt <- html_table$getElementAttribute("outerHTML")[[1]] # gets the html attributes to a text file
  xml_table <-  read_html(Elemtxt) # Reads html details to xml table
  dump_xml <- xmlParse(xml_table) # Parses xml table
  noaa_list <- xmlToDataFrame(nodes = getNodeSet(dump_xml, "//*/tr"), stringsAsFactors = FALSE) # This line extracts the target nodes [tr] to a data frame.
  colnames(noaa_list) <- c('Name','Size','DateModified') # assigning new colnames
  # If the filesize is empty, it is a folder.
  noaa_list$Type <- ifelse(noaa_list$Size == '', 'folder', 'file')
  if(object_type == 'file'){
    object_names <- noaa_list[noaa_list$Type == 'file',]
  } else if(object_type == 'folder'){
    object_names <- noaa_list[noaa_list$Type == 'folder',]
  } else if(object_type == 'all'){
    object_names <- noaa_list
  }
  url <- as.character(remDr$client$getCurrentUrl())
  url_parts <- strsplit(url, "/+")
  noaasubdir_name <- sapply(url_parts, function(x) x[length(x)])
  message(paste0("Scraped objects from NOAA index '",noaasubdir_name,"'. Type = '",object_type,"'.","\n",
                 "There are ",nrow(object_names)," objects. Here's the head():"))
  print(head(object_names[,c(1,4)], n = 10))
  if(isTRUE(trim)){
    drop <- c("Size","DateModified","Type")
    object_names <- object_names %>%
      ungroup %>%
      select(-c(drop))
  }
  if(isTRUE(return)){
    return(object_names)
  }
}
