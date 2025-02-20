getSMAGainDf = function(df,
                        smaMinMaxLow,
                        smaMinMaxHigh,
                        drawPlot,
                        firstPublishSuplyDay) {
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
        #browser()
        diff = NoavaranIndicators::Indicator.SMA(df, i) - NoavaranIndicators::Indicator.SMA(df, j)
        diffYesterday = c(NA, head(diff ,-1))
        positiveSignal = diffYesterday <= 0 & diff >= 0
        negativeSignal = diffYesterday >= 0 & diff <= 0
        close = df$Close
        date = df$Date
        
        df2 = data.frame(
          # 'diff' = diff,
          # 'diffYesterday' = diffYesterday,
          'positiveSignal' = positiveSignal,
          'negativeSignal' = negativeSignal,
          'Close' = close,
          'Date' = date
        )
        
        # خط زیر برای سهم هایی مثل دتهران مشکل درست میشود. زیرا که این سهم در طول بازه دو ساله، فقط سه روز معامله شده است. و پس از افزودن ۹۰ روز،
        #فقط ۳۶ روز دیگر به آن اضافه ده و پس از آن باید همین ۳۶ روز از آن کم شود. و نه ۹۰ روز. به همین دلیل اگر بخواهیم از خط زیر استفاده
        #کنیم، باید آن را تصحیح کرده و آن تعداد روزی که اضافه میشود را کم کنیم.
        #df2 = tail(df2, nrow(df2) - max(settings.sma.smaMinMaxHigh))
        #ولی به جای کد بالا،  از کد زیر استفاده میکنیم.
        df2 = df2[df2$Date >= settings.sma.fromTo[1],]
        
        result = df2[!is.na(df2$positiveSignal) &
                       !is.na(df2$negativeSignal) &
                       ((df2$positiveSignal == T) |
                          df2$negativeSignal == T) ,]
        
        firstDay = head(df2, 1)
        lastDay = tail(df2, 1)
        
        result = addFisrtAndLastCloseDayIfRequired(result, firstDay, lastDay, firstPublishSuplyDay)
        
        #اگر اولین سیگنال، سیگنال فروش بود، از آن صرف نظر میکنیم
        if (head(result, 1)$negativeSignal) {
          result = result[-1, ]
        }
        #حذف روزهایی که دوبار پشت سر هم سیگنال صادر میشود
        result = result[result$positiveSignal != c(F, head(result$positiveSignal,-1)), ]
        
        tryCatch({
          gainResult = calculateGainSMA(result)
          dfGain = rbind(dfGain,
                         c(i,
                           j,
                           gainResult[1],
                           gainResult[2],
                           gainResult[3]))
        }, error = function(e) {
          print(paste0('Error in: DfRows=', nrow(df), ' i=', i, ' j=', j))
        })
        
        
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
    bg = getBestGain(settings.maxTradeNo, dfGain)
    
    if (!is.null(bg)) {
      if (nrow(bg) > 0) {
        if (bg$TradeNo == 0) {
          bg$i = 0
          bg$j = 0
        }
      }
    }
    return(bg)
  }
}

addFisrtAndLastCloseDayIfRequired = function(result,
                                             firstDay,
                                             lastDay,
                                             firstPublishSuplyDay) {
  if (nrow(result) > 0) {
    if (as.Date(firstPublishSuplyDay) == firstDay$Date) {
      result = rbind(
        data.frame(
          # diff = 0, diffYesterday = 0,
          positiveSignal = T,
          negativeSignal = F,
          Close = firstDay$Close,
          Date = firstDay$Date
        ),
        result
      )
    }
    
    if (tail(result, 1)$positiveSignal) {
      result = rbind(
        result,
        data.frame(
          # diff = 0, diffYesterday = 0,
          positiveSignal = F,
          negativeSignal = T,
          Close = lastDay$Close,
          Date = lastDay$Date
        )
      )
    }
  } else {
    result = rbind(
      result,
      data.frame(
        # diff = 0, diffYesterday = 0,
        positiveSignal = T,
        negativeSignal = F,
        Close = firstDay$Close,
        Date = firstDay$Date
      )
    )
    result = rbind(
      result,
      data.frame(
        # diff = 0, diffYesterday = 0,
        positiveSignal = F,
        negativeSignal = T,
        Close = lastDay$Close,
        Date = lastDay$Date
      )
    )
  }
  
  return(result)
}
