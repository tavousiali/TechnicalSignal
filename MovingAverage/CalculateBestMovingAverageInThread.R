source("Util/TimeOfExecution.R")

CalculateBestMovingAverageForAllCompany = function() {
  library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
  library(foreach)
  library(doParallel)
  library(DBI)
  library(odbc)
  numCores <- detectCores()
  registerDoParallel(numCores)
  now = Sys.time()
  stockDf = foreach (i = 1:nrow(Noavaran.Companies), .combine = rbind) %dopar% {
  #stockDf = foreach (i = 1:13, .combine = rbind) %dopar% {
    
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
    
    symbolName = "KEBAFGH"
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    comId = Noavaran.Companies$Com_ID[i]
    
    bg = getSMAGainDf(thisSymbolDataframe[thisSymbolDataframe$Date > '2017-03-21', ],
                      1:30,
                      31:90,
                      F)
    
    if (!is.null(bg)) {
      bg = data.frame(cbind(comId, bg, now))
    }
  }
  
  if (!is.null(stockDf)) {
    stockDf = data.frame(stockDf)
    rownames(stockDf) <- NULL
    names(stockDf) = c('Com_Id', 
                       'i',
                       'j',
                       'Gain',
                       'GainPercent',
                       'TradeNo',
                       'DateTime')
  }

  con <- dbConnect(
    odbc(),
    Driver = "SQL Server",
    Server = "EAGLE30",
    Database = "FinancialAnalysisDB",
    UID = "dit",
    PWD = "@shahin9814",
    Port = 1433,
    encoding = 'UTF-8'
  )
  
  table_id <- Id(schema = "DIT", table = "Tbl18_TechnicalSignalSMA")
  
  dbWriteTable(
    conn = con,
    name = table_id,
    value = stockDf,
    append = TRUE
  )
  
  stopImplicitCluster()
}

timeOfExecution(CalculateBestMovingAverageForAllCompany)
