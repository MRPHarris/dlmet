#' Scrape the filenames of the designated met type from the NOAA ftp server.
#'
#' @description Use RSelenium and Google Chrome to initiate a remote server, navi
#' gate to the NOAA ftp server, and scrape the file names of the specified met type.
#'
#' @param met_type type of NOAA met data (character string; either "gdas1" or "reanalysis").
#' @param target_year year of data frame subset, if any.
#' @param verbose TRUE/FALSE for window prompt to continue with function.
#'
#' @return A data frame containing all the filenames in the specified NOAA ftp met directory.
#' @return A data frame containing filenames from the target_year (if !is.NA).
#' @export
#'
#' @examples
#' get_met_filenames(met_type = "reanalysis", target_year = "2020")
get_met_filenames <- function(met_type = "gdas1",
                              target_year = NA,
                              verbose = TRUE,
                              chromepath = "C:/Program Files/Google/Chrome/Application/"){
  # met data availability/param checks
  if(!isTRUE(met_type == "gdas1") && !isTRUE(met_type == "reanalysis")){
    stop("gdas1 and reanalysis are the only met_types currently supported.")
  }
  if(!is.na(target_year)){
    if((met_type == "gdas1") & (target_year <= 2004)){
      stop("There are no gdas1 files available prior to 2005. Please try again with a target_year >= 2005")
    } else if((met_type == "reanalysis") & (target_year <= 1947)){
      stop("There are no reanalysis files available prior to 1948. Please try again with a target_year >= 1948")
    }
  }
  ### Initial yes/no prompt
  if(isTRUE(verbose)){
    PromptContinue <- if(interactive()){
      askYesNo("Use RSelenium to scrape met file names for the target year? This will terminate active rsDriver and java instances."
               , default = TRUE, prompts = getOption("askYesNo", gettext(c("Y/N/C"))))
    }
    if(!isTRUE(PromptContinue)){
      stop("User terminated function")
    }
    message(paste0("User gave go-ahead. Scraping ", met_type," file names with RSelenium + Chrome..."))
  }
  ### where were you when java was terminated
  message("Looking for Java.exe")
  java_stat <- shell('tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I /N "java.exe">NUL', mustWork = NA, intern = FALSE)
  if(java_stat == 0){
    message("Java.exe detected; terminating process") # java is kill
    system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE) # no
  } else if(java_stat == 1){
    message("No previous Java processes to terminate.")
  }
  ### Terminate rsDriver instances in the workspace.
  try(if(exists("remDr", envir = parent.frame())){
    remDr$client$closeWindow()
    remDr$server$stop()
    rm(remDr,envir = parent.frame())
  })
  ### Fire up the remote server in chrome using whatever version is installed.
  chromeversion <- toString(dir(path = chromepath)) %>%
    str_extract(., '^\\d+\\.\\d+\\.\\d+\\.') %>%
    str_replace_all(., '\\.', '\\\\.')
  chromedriver <-  str_extract_all(toString(list_versions("chromedriver")), paste0(chromeversion, '\\d+'), simplify = TRUE) %>%
    as.numeric_version(.) %>%
    min(.)
  remDr <- rsDriver(browser = "chrome", port = 4567L, geckover = NULL,
                    chromever =  toString(chromedriver), iedrver = "latest",
                    phantomver = NULL) # This triggers a chrome instance with RSelenium.
  ### Navigate to link
  if(met_type == "gdas1"){
    link <- "ftp://arlftp.arlhq.noaa.gov/archives/gdas1"
  } else if (met_type == "reanalysis"){
    link <- "ftp://arlftp.arlhq.noaa.gov/archives/reanalysis"
  }
  remDr$client$navigate(link)
  ### Do the scraping
  met_html_table <- remDr$client$findElement(using = 'xpath', "/html/body/table/tbody") # Finds met file html table matching xpath
  met_Elemtxt <- met_html_table$getElementAttribute("outerHTML")[[1]] # gets the html attributes to a text file
  met_xml_table <-  read_html(met_Elemtxt) # Reads html details to xml table
  dump_xml <- xmlParse(met_xml_table) # Parses xml table
  noaa_met_list <- xmlToDataFrame(nodes = getNodeSet(dump_xml, "//*/tr"), stringsAsFactors = FALSE) # This line extracts the target nodes [tr] to a data frame.
  colnames(noaa_met_list) <- c('Filename','FileSize','ModifiedDate') # assigning new colnames
  noaa_met_list <<- noaa_met_list
  assign(paste0("noaa_",met_type,"_filenames"),noaa_met_list,envir = parent.frame())
  rm(noaa_met_list, envir = parent.frame())
  ### Terminating remote driver
  remDr$client$closeWindow()
  remDr$server$stop()
  message("=======","\n","Java + rsDriver process kill status:")
  system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
  message("=======")
  ### Subset for target year (if specified)
  if(!is.na(target_year)){
    if(met_type == "gdas1"){
      DataNew <- noaa_met_list[-(1:12), , drop = TRUE] # creates df of gdas1 full list from NOAA, minus the first 12 rows.
      DataNew <- DataNew[-((nrow(DataNew)-3):(nrow(DataNew))), , drop = TRUE]
      Year_placeholder <- target_year %% 100
      target_year_s <- formatC(Year_placeholder, width = 2, format = "d", flag = "0") # modify format to preserve leading 0 in case of noughties dates
    } else if(met_type == "reanalysis"){
      DataNew <- noaa_met_list[-(1:4), , drop = FALSE] # creates df of reanalysis list from NOAA, minus the first 4 rows.
      DataNew <- DataNew[-((nrow(DataNew)-3):(nrow(DataNew))), , drop = TRUE] # drops last 3 rows as well
      target_year_s <- target_year
    }
    DL_Fnames <- ifelse(grepl(target_year_s,DataNew$Filename),DataNew$Filename,'')
    DL_Fnames <- as.data.frame(matrix(DL_Fnames))
    colnames(DL_Fnames) <- c('Filename')
    DL_Fnames <- DL_Fnames[!(DL_Fnames$Filename == ''),]
    DL_Fnames <- as.data.frame(matrix(DL_Fnames))
    DL_Fnames <<- DL_Fnames
    assign(paste0(met_type,"_", target_year, "_Filenames"), DL_Fnames, envir = parent.frame())
    rm(DL_Fnames, envir = parent.frame())
    message("Process complete!","\n", "The full list of ",met_type," met files, along with file sizes and upload dates, is stored in noaa_gdas1_filenames","\n",
            "The list of files associated with the target year can be found in ,",met_type," ",target_year,"_filenames.")
  } else if(is.na(target_year)){
    message("Process complete! The full list of ",met_type," met files, along with file sizes and upload dates, is stored in noaa_gdas1_filenames")
  }

}
