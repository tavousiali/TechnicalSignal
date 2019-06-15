getMacdGainDf = function(df,
                         maLow,
                         maHigh,
                         signalma,
                         drawPlot,
                         comId) {
  if (nrow(df) > 60) {
    dfGain = data.frame()
    
    for (i in maLow) {
      for (j in maHigh) {
        if (j > i) {
          for (k in signalma) {
            macd = Noavaran.Indicator.MACD(df, i, j, k)
            if (!is.null(macd)) {
              diff = macd$MACD_macd - macd$MACD_signal
              diffYesterday = c(NA, head(diff ,-1))
              positiveSignal = diffYesterday < 0 & diff > 0
              negativeSignal = diffYesterday > 0 & diff < 0
              close = df$Close
              df2 = data.frame(diff,
                               diffYesterday,
                               positiveSignal,
                               negativeSignal,
                               close)
              colnames(df2) = c('diff',
                                'diffYesterday',
                                'positiveSignal',
                                'negativeSignal',
                                'Close')
              result = df2[!is.na(df2$diffYesterday) &
                             ((df2$positiveSignal == T) |
                                df2$negativeSignal == T) ,]
              gainResult = calculateGain(result, head(df$Close, 1), tail(df$Close, 1))
              dfGain = rbind(
                dfGain,
                c(
                  i,
                  j,
                  k,
                  gainResult[1],
                  gainResult[2],
                  gainResult[3],
                  gainResult[4],
                  gainResult[5]
                )
              )
            }
          }
        }
      }
    }
    
    names(dfGain) = c('i',
                      'j',
                      'k',
                      'Gain',
                      'GainPercent',
                      'TotalGain',
                      'TotalGainPercent',
                      'TradeNo')
    
    bg = getBestGain(100, dfGain)
    
    bg = cbind(comId, bg)
    
    #colnames(bg)[which(names(bg) == "symbolName")] <- "Symbol Name"
    
    return(bg)
  }
  
}