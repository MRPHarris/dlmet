#' Terminate Java on a Windows operating system.
#'
#' @param status TRUE/FALSE to return success/fail of termination attempt.
#'
#' @noRd
terminate_java_win <- function(status = TRUE){
  java_stat <- shell('tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I /N "java.exe">NUL', mustWork = NA, intern = FALSE)
  if(java_stat == 0){
    message("Java.exe detected; terminating process") # java is kill
    system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE) # no
    javastat <- "Success"
  } else if(java_stat == 1){
    message("No java processes to terminate.")
    javastat <- "Fail"
  }
  if(isTRUE(status)){
    return(javastat)
  }
}
