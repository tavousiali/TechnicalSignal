getSMAGainDf = function(df,
                        smaMinMaxLow,
                        smaMinMaxHigh,
                        drawPlot) {
  if (is.null(df)) {
    return()
  }
  if (nrow(df) == 0) {
    return()
  }
  
  dfGain = data.frame()
  maxOfSmaMinMaxLow = max(smaMinMaxLow)
  
  maxOfSmaMinMaxHigh = min(max(smaMinMaxHigh), nrow(df))
  
  for (i in smaMinMaxLow) {
    for (j in smaMinMaxHigh) {
      if (j <= maxOfSmaMinMaxHigh & j > i) {
        diff = Noavaran.Indicator.SMA(df, i) - Noavaran.Indicator.SMA(df, j)
        diffYesterday = c(NA, head(diff , -1))
        positiveSignal = diffYesterday <= 0 & diff >= 0
        negativeSignal = diffYesterday >= 0 & diff <= 0
        close = df$Close
        # date = df$Date
        
        df2 = data.frame(
          # 'diff' = diff,
          # 'diffYesterday' = diffYesterday,
          'positiveSignal' = positiveSignal,
          'negativeSignal' = negativeSignal,
          'Close' = close
          # ,'Date' = date
        )
        
        result = df2[!is.na(df2$positiveSignal) &
                       !is.na(df2$negativeSignal) &
                       ((df2$positiveSignal == T) |
                          df2$negativeSignal == T) , ]
        
        firstDay = head(df2, 1)
        lastDay = tail(df2, 1)
        
        result = addFisrtAndLastCloseDayIfRequired(result, firstDay, lastDay)
        
        #حذف روزهایی که دوبار پشت سر هم سیگنال صادر میشود
        result = result[result$positiveSignal != c(F, head(result$positiveSignal, -1)),]
        
        gainResult = calculateGain(result, firstDay$Close, lastDay$Close)
        dfGain = rbind(dfGain,
                       c(i,
                         j,
                         gainResult[1],
                         gainResult[2],
                         gainResult[3]))
      }
    }
  }
  
  if (nrow(dfGain) > 0) {
    names(dfGain) = c('i',
                      'j',
                      'Gain',
                      'GainPercent',
                      'TradeNo')
    
    # bg = gainResult
    bg = getBestGain(10, dfGain)

    if (bg$TradeNo == 0) {
      bg$i = 0
      bg$j = 0
    }

    return(bg)
  }
}

addFisrtAndLastCloseDayIfRequired = function(result, firstDay, lastDay) {
  if (nrow(result) > 0) {
    if (head(result, 1)$negativeSignal) {
      result = rbind(
        data.frame(
          # diff = 0, diffYesterday = 0,
          positiveSignal = T,
          negativeSignal = F,
          Close = firstDay$Close
          # ,Date = firstDay$Date
        ),
        result
      )
    }
    
    if (tail(result, 1)$positiveSignal) {
      result = rbind(result,
                     data.frame(
                       # diff = 0, diffYesterday = 0,
                       positiveSignal = F,
                       negativeSignal = T,
                       Close = lastDay$Close
                       # ,Date = lastDay$Date
                     ))
    }
  } else {
    result = rbind(result,
                   data.frame(
                     # diff = 0, diffYesterday = 0,
                     positiveSignal = T,
                     negativeSignal = F,
                     Close = firstDay$Close
                     # ,Date = firstDay$Date
                   ))
    result = rbind(result,
                   data.frame(
                     # diff = 0, diffYesterday = 0,
                     positiveSignal = F,
                     negativeSignal = T,
                     Close = lastDay$Close
                     # ,Date = lastDay$Date
                   ))
  }
  
  return(result)
}
