library(DBI)
library(odbc)
library(NoavaranIndicators, lib = "C:/Program Files/R/R-3.5.2/library")
library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
source("TotalGain/CalculateGain.R")
source("TotalGain/GetTotalGainDf.R")
source("Util/TimeOfExecution.R")
source("Util/ConnectionString.R")
source("Settings.R")

CalculateGainForAllSymbol = function(deleteOldData) {
  stockDF = data.frame()
  for (i in 1:nrow(Noavaran.Companies)) {
  #for (i in 1:200) {
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    comId = Noavaran.Companies$Com_ID[i]
    
    df = thisSymbolDataframe[thisSymbolDataframe$Date > settings.totalGain.totalGainFromTo[1] & thisSymbolDataframe$Date < settings.totalGain.totalGainFromTo[2], ]
    if (!is.null(df)) {
      bg = getTotalGainDf(df, comId)
      
      if (!is.null(bg)) {
        stockDF = rbind(stockDF, bg)
      }
    }
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

timeOfExecution(CalculateGainForAllSymbol)
