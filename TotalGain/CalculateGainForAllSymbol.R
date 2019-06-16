library(DBI)
library(odbc)
library(NoavaranIndicators, lib = "C:/Program Files/R/R-3.5.2/library")
library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
source("TotalGain/CalculateGain.R")
source("TotalGain/GetTotalGainDf.R")
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
    "IF EXISTS (SELECT TOP 1 ([Com_ID]) FROM [FinancialAnalysisDB].[DIT].[Tbl18_TechnicalSignalTotalGain])
    DELETE [FinancialAnalysisDB].[DIT].[Tbl18_TechnicalSignalTotalGain]"
  )
}

CalculateGainForAllSymbol = function(deleteOldData) {
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
      bg = getTotalGainDf(tail(thisSymbolDataframe, 500), comId)
      
      if (!is.null(bg)) {
        stockDF = rbind(stockDF, bg)
      }
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
    Id(schema = "DIT", table = "Tbl18_TechnicalSignalTotalGain")
  
  dbWriteTable(
    conn = con,
    name = table_id,
    value = stockDF,
    append = TRUE
  )
}

timeOfExecution(CalculateGainForAllSymbol, T)
