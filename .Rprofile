# .Rprofile for package dlmet project

# load package imports
library(pacman)
pacman::p_load(binman,
               magrittr,
               pacman,
               pingr,
               rJava,
               RSelenium,
               tidyverse,
               utils,
               XML,
               xml2)

## welcome back messages
message("Welcome back! Functions currently within package dlmet:")
print(list.files(paste0(getwd(),"/R/")))
message("dlmet package imports loaded using pacman::p_load().")
message("edit dlmet project .Rprofile with usethis::edit_r_profile(scope = 'project')")

## To-do list
message("To-do list:","\n",
        "1) create straightforward navigation function","\n",
        "2) create download functions based on e.g. download_met_gdas1()","\n",
        "3) add simple tutorial to readme.Rmd")

base_url <- "ftp://arlftp.arlhq.noaa.gov/archives/"
