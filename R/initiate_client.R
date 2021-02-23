#' Initialise an RSelenium WebDriver client with Chrome
#'
#' Start up a remote WebDriver with RSelenium. Option to terminate immediately.
#'
#' @param WebDriverName Name of the webdriver to be created.
#' @param chromepath Directory of google chrome Application folder.
#' @param terminate TRUE/FALSE terminate client immediately after starting.
#' @param verbose TRUE/FALSE generate query window prior to running.
#' @param init_url URL that the client will navigate to upon launching. NOAA archive by default.
#'
#' @export
initiate_client <- function(WebDriverName = "remDr",
                            chromepath = 'C:/Program Files/Google/Chrome/Application/',
                            terminate = FALSE,
                            verbose = FALSE,
                            port = 4567L,
                            init_url = "ftp://arlftp.arlhq.noaa.gov/archives/"){
  if(!require("pacman")){
    install.packages("pacman")
  }
  pacman::p_load(binman,magrittr,pacman,pingr,rJava,RSelenium,tidyverse,utils,XML,xml2)
  if(isTRUE(verbose)){
    PromptContinue <- if(interactive()){
      askYesNo("This function will check if RSelenium is functioning. It will kill any active Java processes. Proceed?",
                default = TRUE, prompts = getOption("askYesNo", gettext(c("Y/N/C"))))
    }
    if(!isTRUE(PromptContinue)){
      stop("User terminated function")
    }
  }
  # Terminate prior java processes
  message("Looking for Java.exe")
  java_stat <- shell('tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I /N "java.exe">NUL', mustWork = NA, intern = FALSE)
  if(java_stat == 0){
    message("Java.exe detected; terminating process") # java is kill
    system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE) # no
  } else if(java_stat == 1){
    message("No previous Java processes to terminate.")
  }
  # Fire up the WebDriver
  chromeversion <- toString(dir(path = chromepath)) %>%
    str_extract(., '^\\d+\\.\\d+\\.\\d+\\.') %>%
    str_replace_all(., '\\.', '\\\\.')
  chromedriver <-  str_extract_all(toString(list_versions("chromedriver")), paste0(chromeversion, '\\d+'), simplify = TRUE) %>%
    as.numeric_version(.) %>%
    min(.)
  # Terminate if that's the go
  if(isTRUE(terminate)){
    remDr <- rsDriver(browser = "chrome", port = port, geckover = NULL, # This triggers a chrome instance with RSelenium.
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
    if(WebDriverName != "remDr"){
      assign(WebDriverName, remDr, envir = parent.frame())
      rm(remDr, envir = parent.frame())
    }
    message(paste0("Client ",WebDriverName," started successfully! You can now use it to navigate from ",init_url,"."))
  }
}
