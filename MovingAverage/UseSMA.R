SourceAndInstalAndLibraryPackage = function() {
  source("Util/InstallPackages.R")
  sourceFile()
  installPackages(settings.usedPackage)
  libraryPackage()
  source("Util/CalculateGain.R")
}

SourceAndInstalAndLibraryPackage()

GetPositiveSignalCompany = function(date) {
  sql <-
    paste0("SELECT * FROM DIT.Tbl18_TechnicalSignalSMA WHERE Cal_ID = 76")
  db_sma <- dbGetQuery(con, sql)
  
  sql <-
    paste0("SELECT * FROM DIT.Tbl18_TechnicalSignal_CompanyExtraData WHERE Cal_ID = 68")
  db_ced <- dbGetQuery(con, sql)
  
  stockDf = data.frame()
  for (i in 1:nrow(Noavaran.Companies)) {
    #for (i in 1:200) {
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    if (nrow(thisSymbolDataframe[thisSymbolDataframe$Date == date,]) == 1) {
      df = tail(thisSymbolDataframe[thisSymbolDataframe$Date <= date,], 202)
      comId = Noavaran.Companies$Com_ID[i]
      logger.info(i)
      
      if (nrow(db_sma[db_sma$Com_ID == comId,])) {
        smaLowIndex = db_sma[db_sma$Com_ID == comId,]$i
        smaHighIndex = db_sma[db_sma$Com_ID == comId,]$j
        
        smaLow = tail(NoavaranIndicators::Indicator.SMA(df, smaLowIndex), 2)
        smaHigh = tail(NoavaranIndicators::Indicator.SMA(df, smaHighIndex), 2)
        
        if (smaLow[2] >= smaHigh[2] && smaLow[1] < smaHigh[1]) {
          company = data.frame(
            'Com_ID' = comId,
            'Com_BourseSymbol' = Noavaran.Companies[i,]$Com_BourseSymbol,
            'Com_Symbol' = Noavaran.Companies[i,]$Com_Symbol,
            'i' = smaLowIndex,
            'j' = smaHighIndex,
            'Com_EntityType' = Noavaran.Companies[i,]$Com_EntityType,
            'FreeFloat' = Noavaran.Companies[i,]$FreeFloat,
            'ValueScale' = db_ced[db_ced$Com_ID == comId,]$ValueScale,
            'VolumeScale' = db_ced[db_ced$Com_ID == comId,]$VolumeScale,
            'CompanyMarketValue' = db_ced[db_ced$Com_ID == comId,]$CompanyMarketValue,
            'RSI' = tail(NoavaranIndicators::Indicator.RSI(df, 14), 1)
          )
          stockDf = rbind(stockDf, company)
        }
      }
    }
  }
  
  return(stockDf)
}

SelectCompanyBy = function(companyList, type) {
  return(head(companies[order(companyList[type[1]], -companyList[type[2]],-companyList[type[3]], -companyList[type[4]], -companyList[type[5]]),], 1))
}

CalcualteSMAGainForCompany = function(company, forDate){
  
  symbolName = Noavaran.Companies[Noavaran.Companies$Com_ID == company$Com_ID, ]$Com_Symbol
  
  stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
  
  thisSymbolDataframe = tryCatch({
    get(stringSymbolName)
  }, error = function(e) {
    
  })
  
  diff = NoavaranIndicators::Indicator.SMA(thisSymbolDataframe, company$i) - NoavaranIndicators::Indicator.SMA(thisSymbolDataframe, company$j)
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
  
  df2 = df2[df2$Date >= settings.sma.fromTo[1],]
  
  df3 = df2[!is.na(df2$positiveSignal) &
                 !is.na(df2$negativeSignal) &
                 ((df2$positiveSignal == T) |
                    df2$negativeSignal == T) ,]
  
  result = head(df3[df3$Date >= forDate,], 2)
  
  gain = result[2,]$Close - result[1,]$Close
  gainPercent = ((gain / result[1,]$Close) * 100) - 1.5
  sellDate = result[2,]$Date
  
  # if (sellDate > '2018-03-21') {
  #   # gain = result[2,]$Close - result[1,]$Close
  #   # gainPercent = (gain / result[1,]$Close) - 1.5
  #   # sellDate = result[2,]$Date
  # }
  sellResult = data.frame('Com_ID' = company$Com_ID,
                          'Com_BourseSymbol' = company$Com_BourseSymbol,
                          'Com_Symbol' = company$Com_Symbol,
                          'i' = company$i,
                          'j' = company$j,
                          'gian' = gain,
                          'gainPercent'= gainPercent,
                          'sellDate' = sellDate)
  return(sellResult)
}

#gainAndSellDate = CalcualteSMAGainForCompany(company, '2017-03-25')
companySelectionType = c('RSI', 'CompanyMarketValue', 'VolumeScale', 'ValueScale', 'FreeFloat')
gainAndSellDate = data.frame()

companies = GetPositiveSignalCompany('2017-03-25')
company = SelectCompanyBy(companies, companySelectionType)
gainAndSellDate = rbind(gainAndSellDate, CalcualteSMAGainForCompany(company, '2017-03-25'))

newDate = tail(gainAndSellDate, 1)$sellDate
while (newDate < '2019-07-23') {
  companies = GetPositiveSignalCompany(newDate)
  company = SelectCompanyBy(companies, companySelectionType)
  gainAndSellDate = rbind(gainAndSellDate, CalcualteSMAGainForCompany(company, newDate))
  print(company)
  print(gainAndSellDate)
  newDate = tail(gainAndSellDate, 1)$sellDate
}

sum(gainAndSellDate$gainPercent)