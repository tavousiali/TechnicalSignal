#detach("package:NoavaranSymbols", unload = TRUE)
library(NoavaranIndicators, lib = "C:/Program Files/R/R-3.5.2/library")
library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
library(TTR)
source("Util/CalculateGain.R")
source("Util/TimeOfExecution.R")
source("Util/PlotGainDf.R")
source("Util/GetBestGain.R")
source("MACD/GetMacdGainDf.R")

#####
maLow = 1:18
maHigh = 15:52
signalma = 3:33
getMacdGainDf(tail(Noavaran.Symbols.KHSAPA, 500), maLow, maHigh, signalma, T, 'Symbol')

#timeOfExecution(tail(Noavaran.Symbols.KHSAPA, 500), maLow, maHigh, signalma, T, 'Symbol')
#####

bestMACDGainForAllSymbol = function() {
  stockDF = data.frame()
  #for (i in 1:nrow(Noavaran.Companies)) {
  for (i in 1:10) {
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    comId = Noavaran.Companies$Com_ID[i]
    
    maLow = 1:18
    maHigh = 15:52
    signalma = 3:33
    bg = getMacdGainDf(tail(thisSymbolDataframe, 500), maLow, maHigh, signalma, F, symbolName)
    
    stockDF = rbind(stockDF, bg)
  }
  
  library(xlsx)
  write.xlsx(stockDF, "D:/MACDResult.xlsx")
  View(stockDF)
  return(stockDF)
}

timeOfExecution(bestMACDGainForAllSymbol)
