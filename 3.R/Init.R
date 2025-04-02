## Rtools is required to build R packages if it was not currently installed , download and install RTools.
## download and install RTool from https://cran.rstudio.com/bin/windows/Rtools/
## download and install RTool
## ??? above

## check the library path of R
.libPaths()
## for management and debug, keep library in one path like
.libPaths("C:/Program Files/R/R-4.4.2/library")

## Load useful libraries
## Install Multiple Packages at Once
install.packages(
  c("dplyr", "ggplot2", "tidyverse","fixest","DBI","RMySQL"),
  lib="C:/Program Files/R/R-4.4.2/library")
# install package for testing 
install.packages("AER",lib="C:/Program Files/R/R-4.4.2/library")
install.packages("RPostgres",lib="C:/Program Files/R/R-4.4.2/library")
## The urbnmapr package is available on GitHub, not CRAN. 
## To use it, you’ll need to install it from GitHub using the devtools package
install.packages("remotes",lib="C:/Program Files/R/R-4.4.2/library")
remotes::install_github("UrbanInstitute/urbnmapr")
## Binsreg:Special functions for binned scatter plots
install.packages("binsreg",lib="C:/Program Files/R/R-4.4.2/library")

## yaml config file
install.packages("yaml",lib="C:/Program Files/R/R-4.4.2/library")



