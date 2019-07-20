installPackages = function(list.of.packages) {
  new.packages <-
    list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
  if (length(new.packages))
    install.packages(new.packages)
  
  if (!'NoavaranSymbols' %in% installed.packages()) {
    install.packages("E:/R/R Packages/NoavaranSymbols", lib = settings.packagePath, repos = NULL, type = "source")
  }
  if (!'NoavaranIndicators' %in% installed.packages()) {
    install.packages("E:/R/R Packages/NoavaranIndicators", lib = settings.packagePath, repos = NULL, type = "source")
  }
}

libraryPackage = function() {
  library(foreach)
  library(doParallel)
  library(DBI)
  library(odbc)
  library(log4r)
  library(dplyr)
  library(plotly)
}
