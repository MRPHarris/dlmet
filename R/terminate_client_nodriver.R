#' Terminate an RSelenium WebDriver client that was orphaned between sessions.
#'
#' Terminate the default RSelenium client remDr if there is no longer an active
#' binding object. Stops Java processes. Use this if the active binding object
#' was removed. Client window must be closed manually.
#'
#' @param verbose TRUE/FALSE generate query window prior to running.
#' @param ping_check TRUE/FALSE to use pingr to check the designated port after terminating Java.
#' @param port The port used for the WebDriver, to be checked if ping_check is TRUE.
#'
#' @export

terminate_client_nodriver <- function(verbose = FALSE,
                                      ping_check = FALSE,
                                      port = 4567L){
  if(!require("pacman")){
    install.packages("pacman")
  }
  pacman::p_load(binman,magrittr,pacman,pingr,rJava,RSelenium,tidyverse,utils,XML,xml2)
  if(isTRUE(verbose)){
    PromptContinue <- if(interactive()){
      askYesNo("This function will terminate any active Java processes. Proceed?",
               default = TRUE, prompts = getOption("askYesNo", gettext(c("Y/N/C"))))
    }
    if(!isTRUE(PromptContinue)){
      stop("User terminated function")
    }
  }
  message("If there is still a client window, it must be closed manually.","\n")
  java_stat <- shell('tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I /N "java.exe">NUL', mustWork = NA, intern = FALSE)
  if(java_stat == 0){
    message("Java.exe detected; terminating process") # java is kill
    system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE) # no
    javastat <- "Success"
  } else if(java_stat == 1){
    message("No java processes to terminate.")
    javastat <- "Fail"
  }
  if(isTRUE(ping_check)){
    message("Using pingr::ping_port() to check if port ",port," is now inactive")
    #From https://stackoverflow.com/questions/14357219/function-for-retrieving-own-ip-address-from-within-r
    readout <- system("ipconfig", intern = TRUE)
    Lines <- readout[grep("IPv4", readout)]
    IP <- gsub(".*? ([[:digit:]])", "\\1", Lines)
    pingres <- pingr::ping_port(destination = IP,
                                port = 4567L)
    if(suppressWarnings(is.na(all(pingres)))){
      message("Port ",port," for destination IP ",IP," inactive. Success!")
    } else if(suppressWarnings(!is.na(all(pingres)))){
      message("Port ",port," for destination IP ",IP," is active. Is this the right port? Did Java terminate?")
    }
  }
  message("Operation complete.")
}
