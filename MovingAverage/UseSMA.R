source("Util/InstallPackages.R")
sourceFile()
installPackages(settings.usedPackage)
libraryPackage()

GetPositiveSignalCompany = function(date) {
  sql <-
    paste0("SELECT * FROM DIT.Tbl18_TechnicalSignalSMA WHERE Cal_ID = 39")
  res <- dbGetQuery(con, sql)
  
  stockDf = data.frame()
  for (i in 1:nrow(Noavaran.Companies)) {
    #for (i in 1:200) {
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    if (nrow(thisSymbolDataframe[thisSymbolDataframe$Date == date, ]) == 1) {
      df = tail(thisSymbolDataframe[thisSymbolDataframe$Date <= date, ], 202)
      comId = Noavaran.Companies$Com_ID[i]
      
      smaLowIndex = res[res$Com_ID == comId, ]$i
      smaHighIndex = res[res$Com_ID == comId, ]$j
      smaLow = tail(NoavaranIndicators::Indicator.SMA(df, smaLowIndex), 2)
      smaHigh = tail(NoavaranIndicators::Indicator.SMA(df, smaHighIndex), 2)
      
      if (smaLow[2] >= smaHigh[2] && smaLow[1] < smaHigh[1]) {
        company = data.frame(
          'Com_ID' = comId,
          'Com_BourseSymbol' = Noavaran.Companies[i, ]$Com_BourseSymbol,
          'i' = smaLowIndex,
          'j' = smaHighIndex,
          'Com_EntityType' = Noavaran.Companies[i, ]$Com_EntityType
        )
        stockDf = rbind(stockDf, company)
      }
    }
  }
  
  return(stockDf)
}

companies = GetPositiveSignalCompany('2019-03-25')
View(companies)
