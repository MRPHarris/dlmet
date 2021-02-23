#' Download files from a list of file names.
#'
#' @description Download files using a list returned by other dlmet functions.
#'
#' @param filenames a matrix or dataframe containing the filenames of the files to be downloaded.
#' @param page_url the URL of the page from which the files are to be downloaded
#' @param dl_directory the destination folder. Where do you want the files to go?
#' @param verbose TRUE/FALSE display prompt to continue with operation.
#' @param suppress_download_popups TRUE/FALSE to stop download.file popups
#'
#' @export
#'

dlmet_download <- function(filenames,
                           page_url,
                           dl_directory,
                           verbose = TRUE,
                           suppress_download_popups = FALSE){
  # 'full dataframe' including name, size, date, type. If yes, get filesize of download operation.
  if(isTRUE(is.data.frame(filenames))){
    cnames_checkagainst <- c("Name","Size","DateModified","Type")
    if(all(names(filenames) == cnames_checkagainst)){
      fulldf <- TRUE
      get_true_fsizes <- function(filenames = filenames){
        filedetails <- data.frame(matrix(NA,nrow = length(as.matrix(filenames[,1])),3))
        filedetails[,1] <- as.numeric(sapply(strsplit(filenames[,2], " "), "[[", 1))
        filedetails[,2] <- sapply(strsplit(filenames[,2], " "), "[[", 2)
        filedetails[,3][filedetails[,2] == "GB"] <- as.numeric(filedetails[,1][filedetails[,2] == "GB"]*1000)
        filedetails[,3][filedetails[,2] == "MB"] <- as.numeric(filedetails[,1][filedetails[,2] == "MB"])
        filedetails[,3][filedetails[,2] == "kB"] <- as.numeric((filedetails[,1][filedetails[,2] == "kB"])/1000)
        filedetails[,3][filedetails[,2] == "B"] <- as.numeric(((filedetails[,1][filedetails[,2] == "B"])/1000)/1000)
        colnames(filedetails) <- c("SizeValue","SizeType","SizeMB")
        return(filedetails)
      }
      filedetails <- get_true_fsizes(filename = filenames)
      total_filesize <- sum(filedetails$SizeMB)
      if(total_filesize <= 1){
      } else {
        total_filesize <- round(total_filesize, 2)
      }
      if(total_filesize > 1000){
        total_filesize <- round(total_filesize/1000,2)
        total_filesize <- as.character(paste0(total_filesize," GB"))
      } else {

        total_filesize <- as.character(paste0(total_filesize," MB"))
      }
    } else {
      fulldf <- FALSE
    }
  }
  # Initial go/no go. Includes likely filesize of download if a full df is passed to function.
  if(isTRUE(verbose)){
    if(isTRUE(fulldf)){
      PromptContinue <- askYesNo(msg = paste0("This action will attempt to download ",as.numeric(nrow(filenames))," files, totalling ",total_filesize,". Proceed?"),
                                 default = TRUE, prompts = getOption("askYesNo", gettext(c("Y/N/C"))))
    } else if(!isTRUE(fulldf)){
      PromptContinue <- askYesNo("This action will attempt to download ",as.numeric(length(as.matrix(filenames)))," files. Proceed?",
                                 default = TRUE, prompts = getOption("askYesNo", gettext(c("Y/N/C"))))
    }
    if(!isTRUE(PromptContinue)){
      stop("User terminated function.")
    }
    message("User gave go-ahead. Fetching files...")
  }
  ## Prepare filenames_mat for download loop. Coerce to matrix filenames_mat.
  if(is.data.frame(filenames)){
    if(isTRUE(ncol(filenames) == 1)){
      filenames_mat <- as.matrix(filenames)
    } else if(isTRUE(ncol(filenames) > 1)){
      filenames_mat <- as.matrix(filenames[,1])
    }
  } else if(is.matrix(filenames)){
    filenames_mat <- filenames
  } else if(is.character(filenames)){
    filenames_mat <- as.matrix(filenames)
  }
  if(!is.matrix(filenames) && !is.data.frame(filenames) && !is.character(filenames)){
    stop("Invalid 'filenames' object type/class. 'filenames' must be a dataframe (names in first column), matrix, or character vector.")
  }
  # Ensure both the URL and dl_directory end in a slash. Add one if not.
  # from https://stackoverflow.com/questions/7963898/extracting-the-last-n-characters-from-a-string-in-r
  substr_last <- function(string, n){
    substr(string, nchar(string)-n+1, nchar(string))
  }
  if(substr_last(page_url,1) != "/"){
    page_url <- paste0(page_url,"/")
  }
  if(substr_last(dl_directory,1) != "/"){
    dl_directory <- paste0(dl_directory,"/")
  }
  # Download loop
  it_list <- vector(mode = "list", length = length(filenames_mat)) # iteration list object to be safe
  dl_status <- data.frame(matrix(NA,nrow = length(filenames_mat),ncol = 2))
  colnames(dl_status) <- c("filename","status")
  for(i in seq_along(it_list)){
    message("Attempting to download file ",i,"/",length(filenames_mat))
    file_name <- filenames_mat[i,1]
    url_it <-  paste0(page_url,file_name)
    dl_status[i,1] <- file_name
    destfile_it <- paste0(dl_directory,file_name)
    # Download attempt. Catches errors, stores them to dl_status
    out <- tryCatch({
      # Thanks to this legend: https://stackoverflow.com/questions/12193779/how-to-write-trycatch-in-r
      download.file(url = url_it, destfile = destfile_it, quiet = suppress_download_popups, mode = "wb")
      },
      error = function(e) {
        message(paste0("There was an issue downloading the file ", file_name, "\n", "Error message:"))
        message(e)
        return("Error")
        },
      warning = function(w) {
        message(paste0("Download for ",file_name," caused a warning.", "\n", "Warning message:"))
        message(w)
        return("Warning")
        }, finally = {} # leaving this empty.
      )
    ## Print message according to result of download attempt. Store in dl_status.
    if(isTRUE(out != "Error") && isTRUE(out != "Warning")){
      dl_status[i,2] <- "Success"
      message(paste0("------ \n",i,"/",length(filenames_mat), " Complete: ",file_name," downloaded","\n","------"))
    } else if (out == "Error"){
      dl_status[i,2] <- out
      message(paste0("------ \n",i,"/",length(filenames_mat), " FAILED: Error in download attempt for ",file_name,"\n","------"))
    } else if (out == "Warning"){
      dl_status[i,2] <- out
      message(paste0("------ \n",i,"/",length(filenames_mat), " WARNING: file ",file_name,"may not have been downloaded.","\n","------"))
    }
  } # End download loop.
  message("Download operation complete. Status of individual downloads stored as download_status_log") # Finishing up.
  assign(paste0("download_log",format(Sys.time(),'_%Y%m%d_%H%M%S')), dl_status, envir = parent.frame())
}
