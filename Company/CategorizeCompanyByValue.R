library(DBI)
library(odbc)
library(NoavaranIndicators, lib = "C:/Program Files/R/R-3.5.2/library")
library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
source("Util/TimeOfExecution.R")

CategorizeCompanyByValue = function() {
  
  ValueThreshold = c(10 ^ 8, 10 ^ 9, 10 ^ 10, 10 ^ 11)
  ValueCoefficient = 5
  periodTime = 60
  
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
      tailDf = tail(thisSymbolDataframe$Value, periodTime)
      xm <- mean(tailDf)
      m = mean(tailDf[which(!(
        tailDf > xm * ValueCoefficient |
          tailDf < xm / ValueCoefficient
      ))])
      if (m < ValueThreshold[1]) {
        stockDF = rbind(stockDF, c(comId, m, 1))
      } else if (m < ValueThreshold[2]) {
        stockDF = rbind(stockDF, c(comId, m, 2))
      } else if (m < ValueThreshold[3]) {
        stockDF = rbind(stockDF, c(comId, m, 3))
      } else if (m < ValueThreshold[4]) {
        stockDF = rbind(stockDF, c(comId, m, 4))
      } else {
        stockDF = rbind(stockDF, c(comId, m, 5))
      }
      
      names(stockDF) = c('Com_ID',
                         'ValueAverage',
                         'ValueScale')
      
    }
  }
  
  return(stockDF)
}

# stockdf = CategorizeCompanyByValue()
# View(stockdf[order(stockdf$ValueAverage),])
# View(stockdf)
