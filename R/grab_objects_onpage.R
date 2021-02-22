#' List objects on the current NOAA ftp archive page.
#'
#' @description Interrogate/list contents of the table on the current NOAA ftp server page.
#'
#' @param object_type get object names/details of type 'file','folder', or 'all'.
#' @param output_names TRUE/FALSE store object details as data frame.
#' @param trim TRUE/FALSE remove columns from output df other than filenames
#'
#' @return A data frame containing all the filenames of object_type in the specified NOAA ftp directory.
#' @export
#'
#' @examples
#' list_objects_onpage(object_type = "folder", output_names = FALSE)
grab_objects_onpage <- function(object_type = "all",
                                output_names = TRUE,
                                for_download = TRUE,
                                trim = FALSE){
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
  if(isTRUE(output_names)){
    if(isTRUE(trim)){
      drop <- c("Size","DateModified","Type")
      object_names <- gdas1_all_names %>%
        ungroup %>%
        select(-c(drop))
    }
    object_names <<- object_names
    assign(paste0(noaasubdir_name,"_",object_type,"_names"),object_names,envir = parent.frame())
    rm(object_names, envir = parent.frame())
    message("Object details stored as ",noaasubdir_name,"_",object_type,"_names")
  }
}
