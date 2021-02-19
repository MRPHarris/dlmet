
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

<!--

testdoc

```r
devtools::install_github("MRPHarris/dlmet")
```

-->
