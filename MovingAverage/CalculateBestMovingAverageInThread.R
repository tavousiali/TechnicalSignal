source("Util/TimeOfExecution.R")

CalculateBestMovingAverageForAllCompany = function() {
  library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
  library(foreach)
  library(doParallel)
  library(DBI)
  library(odbc)
  source("Util/ConvertToUTF.R")
  source("Util/ConnectionString.R")
  source("Settings.R")
  numCores <- detectCores()
  registerDoParallel(numCores)
  
  #ثبت تاریخ در دیتابیس
  calculationTableId = Id(schema = "DIT", table = "Tbl18_TechnicalSignal_CalculationDate")
  val = data.frame(Cal_Date = Sys.time(), 
                   Cal_Description = c('SMA-1:200-31:200-CHEFIBER'), 
                   stringsAsFactors=FALSE)
  val$Cal_Description = ConvertToUTF16(ConvertToUTF8(val$Cal_Description))
  
  dbWriteTable(
    conn = con,
    name = calculationTableId,
    value = val,
    append = TRUE
  )
  
  lastCalc = dbReadTable(con, calculationTableId)
  lastCalcId = tail(lastCalc$Cal_ID, 1)
  ############
  
  #stockDf = foreach (i = 1:nrow(Noavaran.Companies), .combine = rbind) %dopar% {
  stockDf = foreach (i = 1:1, .combine = rbind) %dopar% {
    
    #------ Initial ------
    library(NoavaranIndicators, lib = "C:/Program Files/R/R-3.5.2/library")
    library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
    library(TTR)
    source("Util/CalculateGain.R")
    source("Util/PlotGainDf.R")
    source("Util/GetBestGain.R")
    source("MovingAverage/GetSMAGainDf.R")
    #source("MovingAverage/GetSMAGainDfLowPerformanceHighVisually.R")
    
    #------ Calculate ------
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    #symbolName = "CHEFIBER"
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    comId = Noavaran.Companies$Com_ID[i]
    
    dfLength = length(which(thisSymbolDataframe$Date > settings.sma.smaFromTo[1])) + max(settings.sma.smaMinMaxHigh)
    df = tail(thisSymbolDataframe, dfLength)
    bg = getSMAGainDf(df,
                      settings.sma.smaMinMaxLow,
                      settings.sma.smaMinMaxHigh,
                      F)
    
    if (!is.null(bg)) {
      bg = data.frame(cbind(comId, bg, as.data.frame.numeric(lastCalcId)))
    }
  }
  
  #ثبت میانگین متحرک در دیتابیس
  if (!is.null(stockDf)) {
    stockDf = data.frame(stockDf)
    rownames(stockDf) <- NULL
    names(stockDf) = c('Com_Id', 
                       'i',
                       'j',
                       'Gain',
                       'GainPercent',
                       'TradeNo',
                       'Cal_ID')
  }
  
  table_id <- Id(schema = "DIT", table = "Tbl18_TechnicalSignalSMA")
  
  dbWriteTable(
    conn = con,
    name = table_id,
    value = stockDf,
    append = TRUE
  )

  calculationTableData = dbReadTable(con, calculationTableId)
  
  
  stopImplicitCluster()
}

timeOfExecution(CalculateBestMovingAverageForAllCompany)


# getCompanyDataFrame(index) {
#   symbolName = Noavaran.Companies$Com_Symbol[index]
#   
#   stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
#   
#   thisSymbolDataframe = tryCatch({
#     get(stringSymbolName)
#   }, error = function(e) {
#     
#   })
#   
#   comId = Noavaran.Companies$Com_ID[index]
#   
#   return(list(symbolName, thisSymbolDataframe, comId))
# }