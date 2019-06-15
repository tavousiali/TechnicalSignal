getSMAGainDf = function(df, smaMinMaxLow, smaMinMaxHigh, drawPlot, comId) {
  dfGain = data.frame()
  maxOfSmaMinMaxLow = max(smaMinMaxLow)
  
  maxOfSmaMinMaxHigh = max(smaMinMaxHigh)
  
  if (nrow(df) > maxOfSmaMinMaxHigh) {
    for (i in smaMinMaxLow) {
      sma = Noavaran.Indicator.SMA(df, i)
      if (!is.null(sma)) {
        df[[paste0('sma_', i)]] = sma
      } else {
        maxOfSmaMinMaxLow = i - 1
        
        break()
      }
    }
    
    for (i in smaMinMaxHigh) {
      sma = Noavaran.Indicator.SMA(df, i)
      if (!is.null(sma)) {
        df[[paste0('sma_', i)]] = sma
      } else {
        maxOfSmaMinMaxHigh = i - 1
        
        break()
      }
    }
    
    for (i in smaMinMaxLow) {
      if (i <= maxOfSmaMinMaxLow) {
        for (j in smaMinMaxHigh) {
          if (j <= maxOfSmaMinMaxHigh & j > i) {
            diff = df[paste0('sma_', i)] - df[paste0('sma_', j)]
            diffYesterday = rbind(NA, head(diff ,-1))
            positiveSignal = diffYesterday < 0 & diff > 0
            negativeSignal = diffYesterday > 0 & diff < 0
            close = df$Close
            
            df2 = cbind(diff, diffYesterday, positiveSignal, negativeSignal, close)
            colnames(df2) = c('diff', 'diffYesterday', 'positiveSignal', 'negativeSignal', 'Close')
            
            result = df2[!is.na(df2$diffYesterday) & ((df2$positiveSignal == T) | df2$negativeSignal == T) ,]
            
            gainResult = calculateGain(result, head(df$Close, 1), tail(df$Close, 1))
            dfGain = rbind(dfGain, c(i, j, gainResult[1], gainResult[2], gainResult[3], gainResult[4], gainResult[5]))
            
          }
        }
      }
    }
    
    names(dfGain) = c('i', 'j', 'Gain', 'GainPercent', 'TotalGain', 'TotalGainPercent', 'TradeNo')
    
    #TODO
    #باید بررسی شود که چرا رسم چارت کار نمیکند
    if (drawPlot == T) {
      plotGainDf(dfGain)
    }
    
    bg = getBestGain(100, dfGain)
    
    bg = cbind(comId, bg)
    
    #colnames(bg)[which(names(bg) == "comId")] <- "comId"
    
    return(bg)
  }
}
