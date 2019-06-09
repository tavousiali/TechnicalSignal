detach("package:NoavaranSymbols", unload = TRUE)
library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
library(NoavaranIndicators)
library(TTR)

calculateGain = function(df, firstDayClose, lastDayClose) {
  gain = 0
  pc = 0
  nc = 0
  buySellNo = 0
  wageRate = 1.5
  
  rowCount = nrow(df)
  if (rowCount > 0) {
    for (i in 1:rowCount) {
      row <- df[i,]
      
      if (i == 1 & row$negativeSignal) {
        next()
      }
      if (pc == 0 | nc == 0) {
        if (row$positiveSignal) {
          pc = row$Close
        } else {
          nc = row$Close
        }
      }
      
      if (pc != 0 & nc != 0) {
        gain = gain + (nc - pc)
        nc = 0
        pc = 0
        buySellNo = buySellNo + 1
      }
    }
    
    if (row$positiveSignal) {
      gain = gain + (lastDayClose - row$Close)
      buySellNo = buySellNo + 1
    }
  }
  
  #TODO
  # این قسمت باید درست شود
  # به جای 
  # firstDayClose
  # باید در هر معامله، مقدار کارمزد کسر شود
  gain = gain - (buySellNo * wageRate / 100)
  gainPercent = (gain / firstDayClose) * 100
  gainFirstLast = lastDayClose - firstDayClose
  gainFirstLastPercent = (gainFirstLast / firstDayClose) * 100
  return(c(
    gain,
    gainPercent,
    gainFirstLast,
    gainFirstLastPercent,
    buySellNo
  ))
}

timeOfExecution = function(func, ...) {
  start.time <- Sys.time()
  
  result = func(...)
  
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  
  #print(paste0("Time of execution code: ", time.taken, '-',end.time, '-',start.time))
  return(time.taken)
}

plotGainDf = function(df) {
  library(ggplot2)
  theme_set(theme_bw() +
              theme(legend.position = "top"))
  
  # Initiate a ggplot
  b <- ggplot(df, aes(x = df$`No. of Trades`, y = df$Gain))
  
  # Basic scatter plot
  b + geom_point()
  
  # Change color, shape and size
  #b + geom_point(color = "#00AFBB", size = 2, shape = 23)
  
}

getBestGain = function(maxNoOfTrades, df) {
  sortedDf = df[order(df$`No. of Trades`), , drop = FALSE]
  ndf = sortedDf[sortedDf$`No. of Trades` < maxNoOfTrades,]
  #View(df[order(df$`Gain(%)`), , drop = FALSE])
  return(head(ndf[ndf$`Gain(%)` == max(ndf$`Gain(%)`), ], 1))
}

getGainDf = function(df, smaMinMaxLow, smaMinMaxHigh, drawPlot, symbolName) {
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
    
    names(dfGain) = c('i', 'j', 'Gain', 'Gain(%)', 'LastClose - FirstClose', 'LastClose - FirstClose (%)', 'No. of Trades')
    
    #TODO
    #باید بررسی شود که چرا رسم چارت کار نمیکند
    if (drawPlot == T) {
      plotGainDf(dfGain)
    }
    
    bg = getBestGain(100, dfGain)
    
    bg = cbind(symbolName, bg)
    
    colnames(bg)[which(names(bg) == "symbolName")] <- "Symbol Name"
    
    return(bg)
  }
}

#timeOfExecution(getGainDf, tail(Noavaran.Symbols.REMAPNA, 500), 5:30, 31:90, T, 'REMAPNA')

getGainDf(tail(Noavaran.Symbols.FEOLAD, 500), 5:30, 31:90, T, 'Symbol')
plotGainDf(G)
#TODO
# 2. باید بررسی بشه که هر سیگنالی که میده، چقدر از کف قیمت فاصله داریم. یعنی در واقع چقدر از سود رو از دست داده ایم
# 3. مشخص بشه که برای این سهم، مثلا ۱۰ بار سیگنال دادیم و از این ۱۰ بار، ۸ بار، مثبت بوده و ۲ بار هم اشتباه بوده
# 4. بررسی روی کلیه سهم ها
# 5. وقتی که میانگین متحرک مثلا ۸۰ روزه انتخاب میشه، در عمل، اون ۸۰ روز اول تو محاسبات نمیاد. بررسی بشه که آیا لازم هست که درست بشه یا نه
# 6. باید به صورت رندم، تاریخ، از-تا رو عوض کنیم تا اعداد بهتری برای هر سهم پیدا کنیم.
# 7. توضیح متنی به کاربر ارائه کنیم. مثلا بگیم که اگر سهم رو از ابتدای این تاریخ تا انتهای اون میخریدید، انقدر سود میکردید. بیشترین سود هم انقدر میشده و شما هم با این سیگنال ما، انقدر سود میکردید.
# 8. نسبت مقدار سود به قیمت اولیه سهم (در واقع بازده درصدی سیگنال ما) مشخص بشه
# 9. ویژوالایز کردن نتایج
# 10. یک کار خیلی مهم: توضیح: در مورد بدست آوردن بهترین سهام از طریق این روش، قاعدتا تمام اون سهم هایی که در لیست بهترین هستند،
# برای مثال سهمی که ۳۰۰۰ درصد رشد کرده، در لیست ما هم اولین سهم معرفی میشه. ولی اگر بیایم و نسبت سود از طریق الگوریت ما
# رو به سود از طریق اخرید ابتدا و انتها و همچنین نسبت سود از طریق الگرویتم ما به سود در بهترین حالت را بدست بیاوریم، بهترین سیهم ها رو میشه معرفی کرد.


bestGainForAllSymbol = function() {
  stockDF = data.frame()
  for (i in 1:nrow(Noavaran.Companies)) {
    #for (i in 1:1) {
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    comId = Noavaran.Companies$Com_ID[i]
    
    bg = getGainDf(tail(thisSymbolDataframe, 500), 1:30, 31:90, F, symbolName)
    
    stockDF = rbind(stockDF, bg)
  }
  
  library(xlsx)
  write.xlsx(stockDF, "d:/result.xlsx")
  View(stockDF)
  return(stockDF)
}

timeOfExecution(bestGainForAllSymbol)

bestGainForAllSymbolWithApply = function() {
  stockDF = data.frame()
  
  f = function(x) {
    symbolName = x[2]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    comId = x[1]
    
    bg = getGainDf(tail(thisSymbolDataframe, 500), 1:30, 31:90, F, symbolName)
    stockDF = rbind(stockDF, bg)
    NULL
  }
  
  apply(Noavaran.Companies, 1, f)
}

timeOfExecution(bestGainForAllSymbolWithApply)
