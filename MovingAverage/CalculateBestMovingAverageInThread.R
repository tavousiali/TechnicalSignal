MovingAverageCalculation = function() {
  source("Util/TimeOfExecution.R")
  
  CalculateBestMovingAverageForAllCompany = function() {
    source("Settings.R")

    library(NoavaranSymbols, lib.loc = settings.packagePath)
    library(foreach)
    library(doParallel)
    library(DBI)
    library(odbc)
    
    source("Util/Logger.R")
    source("Util/ConvertToUTF.R")
    source("Util/ConnectionString.R")
    
    numCores <- detectCores()
    registerDoParallel(numCores - 1)
    
    dbWithTransaction(con, {
      #ثبت تاریخ در دیتابیس
      calculationTableId = Id(schema = "DIT", table = "Tbl18_TechnicalSignal_CalculationDate")
      val = data.frame(
        Cal_Date = Sys.time(),
        Cal_Description = settings.calDescription,
        stringsAsFactors = FALSE
      )
      val$Cal_Description = ConvertToUTF16(ConvertToUTF8(val$Cal_Description))
      
      dbWriteTable(
        conn = con,
        name = calculationTableId,
        value = val,
        append = TRUE
      )
      
      lastCalc = dbReadTable(con, calculationTableId)
      lastCalcId = tail(lastCalc$Cal_ID, 1)
      
      stockDf = foreach (i = 1:nrow(Noavaran.Companies), .combine = rbind) %dopar% {
      #stockDf = foreach (i = 1:8, .combine = rbind) %dopar% {
         tryCatch({
           #TODO
           #شرکت فنفت هست و باید اس پی های پویا راه اندازی شود
           #i = 1
           #------ Initial ------
           source("Settings.R")
           source("Util/Logger.R")
           source("Util/CalculateGain.R")
           source("Util/PlotGainDf.R")
           source("Util/GetBestGain.R")
           source("MovingAverage/GetSMAGainDf.R")
           #source("MovingAverage/GetSMAGainDfLowPerformanceHighVisually.R")
           
           library(NoavaranIndicators, lib = settings.packagePath)
           library(NoavaranSymbols, lib = settings.packagePath)
           library(TTR)
           logger.info(paste('Row Number:', i))
           #------ Calculate ------
           symbolName = Noavaran.Companies$Com_Symbol[i]
           
           #symbolName = "KHCHARKESH"
           stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
           
           comId = Noavaran.Companies$Com_ID[i]
           firstPublishSuplyDay = Noavaran.Companies$FirstPublicSupplyDate[i]
           
           thisSymbolDataframe = tryCatch({
             get(stringSymbolName)
           }, error = function(e) {
             
           })
           
           filteredDf = which(
             thisSymbolDataframe$Date > settings.sma.smaFromTo[1] &
               thisSymbolDataframe$Date < settings.sma.smaFromTo[2]
           )
           
           if (length(filteredDf) == 0) {
             return()
           }
           
           dfLength = length(filteredDf) + max(settings.sma.smaMinMaxHigh)
           df = tail(thisSymbolDataframe[thisSymbolDataframe$Date < settings.sma.smaFromTo[2], ], dfLength)
           bg = getSMAGainDf(
             df,
             settings.sma.smaMinMaxLow,
             settings.sma.smaMinMaxHigh,
             F,
             firstPublishSuplyDay
           )
           
           if (!is.null(bg)) {
             bg = data.frame(cbind(comId, bg, as.data.frame.numeric(lastCalcId)))
           }
           
         }, error = function(e) {
           source("Util/Logger.R")
           logger.error(paste('Error in Company:', i))
           logger.error(e)
         })
       }
      
      tryCatch({
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
        
        table_id <-
          Id(schema = "DIT", table = "Tbl18_TechnicalSignalSMA")
        
        dbWriteTable(
          conn = con,
          name = table_id,
          value = stockDf,
          append = TRUE
        )
        
        calculationTableData = dbReadTable(con, calculationTableId)
        
      }, error = function(e) {
        source("Util/Logger.R")
        logger.error(e)
      }, finally = {
        
      })
      
      
    })
    
    dbDisconnect(con)
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
}