#' Initialise an RSelenium client with Chrome
#'
#' Start up a remote server with RSelenium. This will check to confirm
#' everything is working properly. Option terminate immediately.
#'
#' @param verbose TRUE/FALSE generate query window prior to running.
#' @param chromepath directory of google chrome install.
#' @param terminate TRUE/FALSE terminate client immediately after starting.
#' @param init_url URL that the client will navigate to upon launching.
#'
#' @export
initiate_client <- function(verbose = FALSE,
                            chromepath = 'C:/Program Files/Google/Chrome/Application/',
                            terminate = FALSE,
                            init_url = "ftp://arlftp.arlhq.noaa.gov/archives/"){
  if(isTRUE(verbose)){
    PromptContinue <- if(interactive()){
      askYesNo("This function will check if RSelenium is functioning. It will kill any active Java processes. Proceed?",
                default = TRUE, prompts = getOption("askYesNo", gettext(c("Y/N/C"))))
    }
    if(!isTRUE(PromptContinue)){
      stop("User terminated function")
    }
  }
  message("Looking for Java.exe")
  java_stat <- shell('tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I /N "java.exe">NUL', mustWork = NA, intern = FALSE)
  if(java_stat == 0){
    message("Java.exe detected; terminating process") # java is kill
    system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE) # no
  } else if(java_stat == 1){
    message("No previous Java processes to terminate.")
  }
  chromeversion <- toString(dir(path = chromepath)) %>%
    str_extract(., '^\\d+\\.\\d+\\.\\d+\\.') %>%
    str_replace_all(., '\\.', '\\\\.')
  chromedriver <-  str_extract_all(toString(list_versions("chromedriver")), paste0(chromeversion, '\\d+'), simplify = TRUE) %>%
    as.numeric_version(.) %>%
    min(.)
  if(isTRUE(terminate)){
    remDr <- rsDriver(browser = "chrome", port = 4567L, geckover = NULL, # This triggers a chrome instance with RSelenium.
                       chromever =  toString(chromedriver), iedrver = "latest",
                       phantomver = NULL)
    try(if(exists("remDr", envir = environment())){
      remDr$client$closeWindow()
      remDr$server$stop()
      system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
      message("======","\n",
              "Everything seems to be working alright.")
    })
  } else {
    remDr <<- rsDriver(browser = "chrome", port = 4567L, geckover = NULL, # This triggers a chrome instance with RSelenium.
                       chromever =  toString(chromedriver), iedrver = "latest",
                       phantomver = NULL)
    remDr$client$navigate(init_url)
    message(paste0("Client started successfully! You can now use it to navigate ",init_url,"."))
  }
}
