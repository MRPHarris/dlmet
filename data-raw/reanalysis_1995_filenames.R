##### 1995 subset of reanalysis file names #####

## Get data, set vars
# reanalysis filenames were scraped from the NOAA ftp server at
# ftp://arlftp.arlhq.noaa.gov/archives/reanalysis on 18/02/2021 using early version of
# get_met_filenames()
reanalysis_fnames <- read.csv("data-raw/reanalysis_filenames_180221.csv")
year <- 1995
met_type <- "reanalysis"

## Subset. Taken from get_met_filenames().
DataNew <- reanalysis_fnames[-(1:4), ] # creates df of reanalysis full list from NOAA, minus the first 10 rows.
DataNew <- DataNew[-((nrow(DataNew)-3):(nrow(DataNew))), , drop = TRUE]
Year_placeholder <- year
target_year_s <- formatC(Year_placeholder, width = 2, format = "d", flag = "0") # modify format to preserve leading 0 in case of 20-- dates
DL_Fnames <- ifelse(grepl(target_year_s,DataNew$Filename),DataNew$Filename,'')
DL_Fnames <- as.data.frame(matrix(DL_Fnames))
colnames(DL_Fnames) <- c('Filename')
DL_Fnames <- DL_Fnames[!(DL_Fnames$Filename == ''),]
DL_Fnames <- as.data.frame(matrix(DL_Fnames))
reanalysis_2015_filenames <- DL_Fnames

## usethis
usethis::use_data(reanalysis_2015_filenames, overwrite = TRUE)
