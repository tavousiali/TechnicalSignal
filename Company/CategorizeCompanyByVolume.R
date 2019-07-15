CategorizeCompanyByVolume = function() {
  volumeThreshold = settings.company.volumeThreshold
  volumeCoefficient = settings.company.volumeCoefficient
  periodTime = settings.company.volumePeriodTime
  
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
      
      if (!is.nan(m)) {
        if (m < volumeThreshold[1]) {
          stockDF = rbind(stockDF, c(comId, m, 1))
        } else if (m < volumeThreshold[2]) {
          stockDF = rbind(stockDF, c(comId, m, 2))
        } else if (m < volumeThreshold[3]) {
          stockDF = rbind(stockDF, c(comId, m, 3))
        } else if (m < volumeThreshold[4]) {
          stockDF = rbind(stockDF, c(comId, m, 4))
        } else {
          stockDF = rbind(stockDF, c(comId, m, 5))
        }
      }
      
      names(stockDF) = c('Com_ID',
                         'VolumeAverage',
                         'VolumeScale')
      
    }
  }
  
  return(stockDF)
}