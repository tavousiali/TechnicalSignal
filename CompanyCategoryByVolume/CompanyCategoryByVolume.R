library(DBI)
library(odbc)
library(NoavaranIndicators, lib = "C:/Program Files/R/R-3.5.2/library")
library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
source("Util/TimeOfExecution.R")

truncateTable = function() {
  library(DBI)
  library(odbc)
  con <- dbConnect(
    odbc(),
    Driver = "SQL Server",
    Server = "EAGLE30",
    Database = "FinancialAnalysisDB",
    UID = "dit",
    PWD = "@shahin9814",
    #rstudioapi::askForPassword(""),
    Port = 1433,
    encoding = 'UTF-8'
  )
  
  dbSendQuery(
    con,
    "IF EXISTS (SELECT TOP 1 ([Com_ID]) FROM [FinancialAnalysisDB].[DIT].[Tbl18_TechnicalSignal_CompanyCategoryByVolume])
    DELETE [FinancialAnalysisDB].[DIT].[Tbl18_TechnicalSignal_CompanyCategoryByVolume]"
  )
}

CompanyCategoryByVolume = function(periodTime,
                                   volumeThreshold,
                                   volumeCoefficient,
                                   deleteOldData) {
  stockDF = data.frame()
  for (i in 1:nrow(Noavaran.Companies)) {
    #for (i in 1:20) {
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    comId = Noavaran.Companies$Com_ID[i]
    
    if (!is.null(thisSymbolDataframe)) {
      tailDf = tail(thisSymbolDataframe$Volume, periodTime)
      xm <- mean(tailDf)
      m = mean(tailDf[which(!(
        tailDf > xm * volumeCoefficient |
          tailDf < xm / volumeCoefficient
      ))])
      if (m < volumeThreshold[1]) {
        stockDF = rbind(stockDF, c(comId, 1))
      } else if (m < volumeThreshold[2]) {
        stockDF = rbind(stockDF, c(comId, 2))
      } else if (m < volumeThreshold[3]) {
        stockDF = rbind(stockDF, c(comId, 3))
      } else if (m < volumeThreshold[4]) {
        stockDF = rbind(stockDF, c(comId, 4))
      } else {
        stockDF = rbind(stockDF, c(comId, 5))
      }
      
      names(stockDF) = c('Com_ID',
                         'Type')
      
    }
  }
  
  con <- dbConnect(
    odbc(),
    Driver = "SQL Server",
    Server = "EAGLE30",
    Database = "FinancialAnalysisDB",
    UID = "dit",
    PWD = "@shahin9814",
    #rstudioapi::askForPassword(""),
    Port = 1433,
    encoding = 'UTF-8'
  )
  
  if (deleteOldData) {
    truncateTable()
  }
  
  table_id <-
    Id(schema = "DIT", table = "Tbl18_TechnicalSignal_CompanyCategoryByVolume")
  
  dbWriteTable(
    conn = con,
    name = table_id,
    value = stockDF,
    append = TRUE
  )
}

volumeThreshold = c(10 ^ 5, 10 ^ 6, 10 ^ 7, 10 ^ 8)
volumeCoefficient = 5
periodTime = 60
timeOfExecution(CompanyCategoryByVolume,
                periodTime,
                volumeThreshold,
                volumeCoefficient,
                T)
