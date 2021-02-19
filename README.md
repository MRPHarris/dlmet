
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dlmet

<!-- badges: start -->
<!-- badges: end -->

**dlmet** is an **R** package that streamlines bulk downloading of files
from the NOAA ftp archive server. Typically when a user seeks to
download a piece of data from the NOAA archive
(“<ftp://arlftp.arlhq.noaa.gov/archives/>”), they navigate to the file
in question using a web browser and select individual files for
download. Downloading multiple files in this manner can be very tedious.

The **dlmet** package speeds up this process considerably. Using two to
three functions in a simple workflow, users can download large groups of
files from any directory within the NOAA archive. In using
**RSelenium**, **dlmet** ensures that file names are current, and allows
the user to download files outside of my original scope for this package
(met data for use with HYSPLIT).

This package was intended for downloading large volumes of Global Data
Assimilation System meteorological data files for use in the HYSPLIT
model via [splitr](https://github.com/rich-iannone/splitr). However, the
functions are flexible; anyone seeking a way to easily download large
amounts of NOAA data from the archive should be able to apply this
package in a straighforward manner.

## Installation

**dlmet** requires a few things to work. **R** must be installed, along
with **java** and **Google Chrome**.

**dlmet** is hosted on github, and can be insalled via the **devtools**
package.

``` r
devtools::install_github("MRPHarris/dlmet")
```

A package for scraping and downloading files from the NOAA ftp server
with RSelenium

<!--## Installation

You can install the released version of dlmet from [CRAN](https://CRAN.R-project.org) with:

#``` r
#install.packages("dlmet")
#```

## Example

This is a basic example which shows you how to solve a common problem:

#```{r example}
#library(dlmet)
### basic example code
#```

What is special about using `README.Rmd` instead of just `README.md`? You can include R chunks like so:

#```{r cars}
#summary(cars)
#```

You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this. You could also use GitHub Actions to re-render `README.Rmd` every time you push. An example workflow can be found here: <https://github.com/r-lib/actions/tree/master/examples>.

You can also embed plots, for example:

#```{r pressure, echo = FALSE}
#plot(pressure)
#```

In that case, don't forget to commit and push the resulting figure files, so they display on GitHub and CRAN.

-->
