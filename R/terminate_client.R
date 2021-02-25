#' Terminate an RSelenium WebDriver.
#'
#' Terminate the active WebDriver. Closes client window, ends server,
#' stops Java processes.
#'
#' @param WebDriver Active binding object containing the active WebDriver.
#' @param WebDriverName Name of the active binding object as characters.
#' @param verbose TRUE/FALSE to generate query window prior to running.
#'
#' @export
terminate_client <- function(WebDriver = remDr,
                             WebDriverName = "remDr",
                             verbose = FALSE){
  if(!require("pacman")){
    install.packages("pacman")
  }
  pacman::p_load(binman,magrittr,pacman,pingr,rJava,RSelenium,tidyverse,utils,XML,xml2)
  if(!isTRUE(exists(WebDriverName))){
    stop(message(paste0("No object named ",WebDriverName," in the Global Environment.")),"Couldn't find WebDriver")
  }
  if(isTRUE(verbose)){
    PromptContinue <- if(interactive()){
      askYesNo("This function will terminate the RSelenium client, along with any active Java processes. Proceed?",
               default = TRUE, prompts = getOption("askYesNo", gettext(c("Y/N/C"))))
    }
    if(!isTRUE(PromptContinue)){
      stop("User terminated function")
    }
  }
  closewindow <- function(){
    check <- tryCatch(
      suppressMessages({
        WebDriver$client$closeWindow() # Close window, only display tryCatch() error.
      }),
      error = function(err){
        message(paste0("Can't close the client window for ",WebDriverName,". It may not exist.")) # in case of error
        message("Error returned by rsDriver:")
        message(err)
        return("Error")
      },
      warning = function(warn){
        message(paste0("Client window close attempt returned a warning")) # in case of warn (not likely)
        message("Warning returned by rsDriver:")
        message(warn)
      }
    )
    return(check)
  }
  check <- closewindow()
  if(is.null(check)){
    windowstat <- "Success"
  } else if(!is.null(check)){
    windowstat <- "Failed"
  }
  serverstop <- WebDriver$server$stop()
  if(isTRUE(serverstop)){
    serverstat <- "Success"
  } else if(!isTRUE(serverstop)){
    message("Server ",WebDriverName," could not be stopped. It may not exist.")
    serverstat <- "Fail"
  }
  # Terminate Java for windows. No Mac support as yet.
  javastat <- terminate_java_win()
  if(isTRUE(exists(WebDriverName, envir = parent.frame()))){
    rm(list = c(WebDriverName),envir = parent.frame())
    objstat <- "Success"
  } else{
    objstat <- "Fail"
  }
  message("Summary of termination attempt for WebDriver client '",WebDriverName,"'","\n",
          "Client window close attempt:      | ",windowstat,"\n",
          "Client server stop attempt:       | ",serverstat,"\n",
          "Java process termination attempt: | ",javastat,"\n",
          "Binding object removal attempt:   | ",objstat)
}


