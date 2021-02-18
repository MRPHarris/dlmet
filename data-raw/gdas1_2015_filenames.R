##### 2015 subset of gdas1 file names #####

## Get data, set vars
# gdas1 filenames were scraped from the NOAA ftp server at
# ftp://arlftp.arlhq.noaa.gov/archives/gdas1 on 18/02/2021 using early version of
# get_met_filenames()
gdas1_fnames <- read.csv("data-raw/gdas1_filenames_180221.csv")
year <- 2015
met_type <- "gdas1"

## Subset. Taken from get_met_filenames().
DataNew <- gdas1_fnames[-(1:12), ] # creates df of gdas1 full list from NOAA, minus the first 10 rows.
DataNew <- DataNew[-((nrow(DataNew)-3):(nrow(DataNew))), , drop = TRUE]
Year_placeholder <- year %% 100
target_year_s <- formatC(Year_placeholder, width = 2, format = "d", flag = "0") # modify format to preserve leading 0 in case of 20-- dates
DL_Fnames <- ifelse(grepl(target_year_s,DataNew$Filename),DataNew$Filename,'')
DL_Fnames <- as.data.frame(matrix(DL_Fnames))
colnames(DL_Fnames) <- c('Filename')
DL_Fnames <- DL_Fnames[!(DL_Fnames$Filename == ''),]
DL_Fnames <- as.data.frame(matrix(DL_Fnames))
gdas1_2015_filenames <- DL_Fnames

## usethis
usethis::use_data(gdas1_2015_filenames, overwrite = TRUE)
