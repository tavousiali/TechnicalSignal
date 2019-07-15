CategorizeCompanyByValue = function() {
  source("Settings.R")
  ValueThreshold = settings.company.valueThreshold
  ValueCoefficient = settings.company.valueCoefficient
  periodTime = settings.company.valuePeriodTime
  
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
      
      if (!is.nan(m)) {
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
      }
      
      names(stockDF) = c('Com_ID',
                         'ValueAverage',
                         'ValueScale')
      
    }
  }
  
  return(stockDF)
}