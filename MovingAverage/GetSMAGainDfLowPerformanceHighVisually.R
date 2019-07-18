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
  
  #if (maxOfSmaMinMaxLow <= nrow(df)) {
  #maxOfSmaMinMaxHigh = max(smaMinMaxHigh)
  maxOfSmaMinMaxHigh = min(max(smaMinMaxHigh), nrow(df))
  
  for (i in smaMinMaxLow) {
    sma = NoavaranIndicators::Indicator.SMA(df, i)
    if (!is.null(sma)) {
      df[[paste0('sma_', i)]] = sma
    }
  }
  
  for (i in smaMinMaxHigh) {
    sma = NoavaranIndicators::Indicator.SMA(df, i)
    if (!is.null(sma)) {
      df[[paste0('sma_', i)]] = sma
    }
  }
  
  for (i in smaMinMaxLow) {
    for (j in smaMinMaxHigh) {
      if (j <= maxOfSmaMinMaxHigh & j > i) {
        diff = df[paste0('sma_', i)] - df[paste0('sma_', j)]
        diffYesterday = rbind(NA, head(diff , -1))
        positiveSignal = diffYesterday <= 0 & diff >= 0
        negativeSignal = diffYesterday >= 0 & diff <= 0
        close = df$Close
        date = df$Date
        
        df2 = cbind(diff,
                    diffYesterday,
                    positiveSignal,
                    negativeSignal,
                    close,
                    date)
        colnames(df2) = c(
          'diff',
          'diffYesterday',
          'positiveSignal',
          'negativeSignal',
          'Close',
          'Date'
        )
        
        # خط زیر برای سهم هایی مثل دتهران مشکل درست میشود. زیرا که این سهم در طول بازه دو ساله، فقط سه روز معامله شده است. و پس از افزودن ۹۰ روز، 
        #فقط ۳۶ روز دیگر به آن اضافه ده و پس از آن باید همین ۳۶ روز از آن کم شود. و نه ۹۰ روز. به همین دلیل اگر بخواهیم از خط زیر استفاده
        #کنیم، باید آن را تصحیح کرده و آن تعداد روزی که اضافه میشود را کم کنیم.
        #df2 = tail(df2, nrow(df2) - max(settings.sma.smaMinMaxHigh))
        #ولی به جای کد بالا،  از کد زیر استفاده میکنیم.
        df2 = df2[df2$Date > settings.sma.smaFromTo[1],] 
        
        result = df2[!is.na(df2$diffYesterday) &
                       ((df2$positiveSignal == T) |
                          df2$negativeSignal == T) , ]
        
        firstDay = head(df2, 1)
        lastDay = tail(df2, 1)
        
        result = addFisrtAndLastCloseDayIfRequired(result, firstDay, lastDay, firstPublishSuplyDay)
        
        #اگر اولین سیگنال، سیگنال فروش بود، از آن صرف نظر میکنیم
        if (head(result, 1)$negativeSignal) {
          result = result[-1, ]
        }
        #حذف روزهایی که دوبار پشت سر هم سیگنال صادر میشود
        result = result[result$positiveSignal != c(F, head(result$positiveSignal,-1)), ]
        
        gainResult = calculateGain(result)
        dfGain = rbind(dfGain,
                       c(i,
                         j,
                         gainResult[1],
                         gainResult[2],
                         gainResult[3]))
        
      }
    }
  }
  
  names(dfGain) = c('i',
                    'j',
                    'Gain',
                    'GainPercent',
                    'TradeNo')
  
  if (drawPlot == T) {
    plotGainDf(dfGain)
  }
  
  #bg = result
  bg = getBestGain(settings.maxTradeNo, dfGain)

  if (bg$TradeNo == 0) {
    bg$i = 0
    bg$j = 0
  }
  
  return(bg)
  #}
}

addFisrtAndLastCloseDayIfRequired = function(result, firstDay, lastDay, firstPublishSuplyDay) {
  if (nrow(result) > 0) {
    if (as.Date(firstPublishSuplyDay) == firstDay$Date) {
      v = data.frame(
        diff = 0,
        diffYesterday = 0,
        positiveSignal = T,
        negativeSignal = F,
        Close = firstDay$Close,
        Date = firstDay$Date
      )
      
      result = rbind(v, result)
    }
    
    if (tail(result, 1)$positiveSignal) {
      v = data.frame(
        diff = 0,
        diffYesterday = 0,
        positiveSignal = F,
        negativeSignal = T,
        Close = lastDay$Close,
        Date = lastDay$Date
      )
      
      result = rbind(result, v)
    }
  } else {
    f = data.frame(
      diff = 0,
      diffYesterday = 0,
      positiveSignal = T,
      negativeSignal = F,
      Close = firstDay$Close,
      Date = firstDay$Date
    )
    
    l = data.frame(
      diff = 0,
      diffYesterday = 0,
      positiveSignal = F,
      negativeSignal = T,
      Close = lastDay$Close,
      Date = lastDay$Date
    )
    
    result = rbind(result, f)
    result = rbind(result, l)
  }
  
  return(result)
}