source("Util/InstallPackages.R")
sourceFile()
installPackages(settings.usedPackage)
libraryPackage()
source("Util/CalculateGain.R")

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

CalcualteSMAGainForAllCompany = function(fromTo, sma_calID) {
  dfGainForAllCompany = data.frame()
  for (i in 1:nrow(Noavaran.Companies)) {
    #print(paste('Number of iteration: ',i))
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    comId = Noavaran.Companies$Com_ID[i]
    firstPublishSuplyDay = Noavaran.Companies$FirstPublicSupplyDate[i]
    sql <-
      paste0("SELECT * FROM DIT.Tbl18_TechnicalSignalSMA WHERE Cal_ID = ", sma_calID)
    db_sma <- dbGetQuery(con, sql)
    
    if (nrow(db_sma[db_sma$Com_ID == comId,])) {
      smaLowIndex = db_sma[db_sma$Com_ID == comId,]$i
      smaHighIndex = db_sma[db_sma$Com_ID == comId,]$j
      
      
      diff = NoavaranIndicators::Indicator.SMA(thisSymbolDataframe, smaLowIndex) - NoavaranIndicators::Indicator.SMA(thisSymbolDataframe, smaHighIndex)
      diffYesterday = c(NA, head(diff ,-1))
      positiveSignal = diffYesterday <= 0 & diff >= 0
      negativeSignal = diffYesterday >= 0 & diff <= 0
      close = thisSymbolDataframe$Close
      date = thisSymbolDataframe$Date
      
      df2 = data.frame(
        'positiveSignal' = positiveSignal,
        'negativeSignal' = negativeSignal,
        'Close' = close,
        'Date' = date
      )
      
      df2 = df2[df2$Date >= fromTo[1] & df2$Date <= fromTo[2], ]
      
      if (nrow(df2) > 0) {
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
          dfGainForAllCompany = rbind(dfGainForAllCompany,
                                      c(comId,
                                        smaLowIndex,
                                        smaHighIndex,
                                        gainResult[1],
                                        gainResult[2],
                                        gainResult[3]))
        }, error = function(e) {
          print(paste('Company with Id=', comId, 'has error in this duration.'))
        })
        
      } else {
        #print(paste('2.Company with Id=', comId, 'does not trade in this duration.'))
      }
      
    }
  }
  
  if (nrow(dfGainForAllCompany) > 0) {
    names(dfGainForAllCompany) = c('Com_ID',
                                   'i',
                                   'j',
                                   'Gain',
                                   'GainPercent',
                                   'TradeNo')
  }
  
  return(dfGainForAllCompany)
}

dfSMAGainForAllCompanyInDuration = CalcualteSMAGainForAllCompany(c('2017-03-21', '2019-07-22'), 78)



#------------
#TotalGain
sql <- paste0("SELECT * FROM DIT.Tbl18_TechnicalSignalTotalGain WHERE Cal_ID = 83")
totalgainFrom96 <- dbGetQuery(con, sql)
totalgainFrom96$Com_ID <- as.numeric(totalgainFrom96$Com_ID)

c = inner_join(dfSMAGainForAllCompanyInDuration, totalgainFrom96)
c$diff = c$GainPercent - c$TotalGainPercent
c = inner_join(Noavaran.Companies, c)

View(c)
d = c[c$Com_EntityType != 16,]

nrow(c)
nrow(c[c$diff >= 0,])
nrow(d)
nrow(d[d$diff >= 0,])



library(plotly)
p <- plot_ly(data = d, x = ~TotalGainPercent, y = ~diff,
             text = ~paste("i: ", i, '<br>j:', j, '<br>TotalGainPercent:', round(TotalGainPercent), '<br>diff:', round(diff)),
             #color = ~GainPercent, size = ~GainPercent,
             mode = 'markers',
             type = 'scatter'
)
p
