#' Terminate an RSelenium client
#'
#' Terminate the default RSelenium client remDr. Closes window, ends server,
#' stops Java process.
#'
#' @param verbose TRUE/FALSE generate query window prior to running.
#'
#' @export
terminate_client <- function(verbose = FALSE){
  if(isTRUE(verbose)){
    PromptContinue <- if(interactive()){
      askYesNo("This function will terminate the RSelenium client, along with any active Java processes. Proceed?",
               default = TRUE, prompts = getOption("askYesNo", gettext(c("Y/N/C"))))
    }
    if(!isTRUE(PromptContinue)){
      stop("User terminated function")
    }
  }
  if(exists("remDr", envir = parent.frame())){
    tryCatch(
      suppressMessages({
        remDr$client$closeWindow()
      }),
      error = function(cond) {
        message(paste0("Can't close the client window."))
        message("Here's the original error message:")
        message(cond)
        },
      warning = function(){
        message(paste0("Client window close attempt returned a warning"))
        message("Here's the original warning message:")
        message(cond)
      }
    )
    remDr$server$stop()
    message("Client window closed, server stopped.")
    message("Looking for Java.exe")
    java_stat <- shell('tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I /N "java.exe">NUL', mustWork = NA, intern = FALSE)
    if(java_stat == 0){
      message("Java.exe detected; terminating process") # java is kill
      system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE) # no
    } else if(java_stat == 1){
      message("That's odd! No java processes to terminate.")
    }
  } else{
    message("No object 'remDr' in the parent.frame()")
  }
 message(paste0("Client ended successfully"))
}
