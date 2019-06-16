# install.packages("DBI")
# install.packages("rlang")
# install.packages("odbc")

source("Util/TimeOfExecution.R")
truncateTable = function() {
  library(DBI)
  library(odbc)
  con <- dbConnect(
    odbc(),
    Driver = "SQL Server",
    Server = "EAGLE30",
    Database = "FinancialAnalysisDB",
    UID = "dit",
    PWD = "@shahin9814",
    #rstudioapi::askForPassword(""),
    Port = 1433,
    encoding = 'UTF-8'
  )
  
  dbSendQuery(
    con,
    "IF EXISTS (SELECT TOP 1 ([Com_ID]) FROM [FinancialAnalysisDB].[DIT].[Tbl18_TechnicalSignalSMA])
    DELETE [FinancialAnalysisDB].[DIT].[Tbl18_TechnicalSignalSMA]"
  )
}

CalculateBestMovingAverageForAllCompany = function(deleteOldData) {
  library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
  library(foreach)
  library(doParallel)
  numCores <- detectCores()
  registerDoParallel(numCores)
  
  #اگر این مقدار فالس باشد، در هنگام اجرا ممکن است که به خطای comId تگراری از طرف sql بخوریم
  if (deleteOldData) {
    truncateTable()
  }
  
  foreach (i = 1:nrow(Noavaran.Companies)) %dopar% {
    #foreach (i = 127:127) %dopar% {
    preRequired = function() {
      library(NoavaranIndicators, lib = "C:/Program Files/R/R-3.5.2/library")
      library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
      library(TTR)
      source("Util/CalculateGain.R")
      source("Util/PlotGainDf.R")
      source("Util/GetBestGain.R")
      source("MovingAverage/GetSMAGainDf.R")
      library(DBI)
      library(odbc)
    }
    
    insertIntoDB = function(bg) {
      con <- dbConnect(
        odbc(),
        Driver = "SQL Server",
        Server = "EAGLE30",
        Database = "FinancialAnalysisDB",
        UID = "dit",
        PWD = "@shahin9814",
        #rstudioapi::askForPassword(""),
        Port = 1433,
        encoding = 'UTF-8'
      )
      
      dbSendQuery(
        con,
        paste0(
          "INSERT INTO [FinancialAnalysisDB].DIT.[Tbl18_TechnicalSignalSMA]
          (Com_ID,
          i,
          j,
          Gain,
          GainPercent,
          TradeNo) VALUES (",
          bg$comId,
          ',',
          ifelse(!is.null(bg$i), bg$i, 'NULL') ,
          ',',
          ifelse(!is.null(bg$j), bg$j, 'NULL') ,
          ',',
          ifelse(!is.null(bg$Gain), bg$Gain, 'NULL') ,
          ',',
          ifelse(!is.null(bg$GainPercent), bg$GainPercent, 'NULL') ,
          ',',
          ifelse(!is.null(bg$TradeNo), bg$TradeNo, 'NULL') ,
          ")"
          )
        )
    }
    getCompanyAndCalcBestGain = function(i) {
      symbolName = Noavaran.Companies$Com_Symbol[i]
      
      stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
      
      thisSymbolDataframe = tryCatch({
        get(stringSymbolName)
      }, error = function(e) {
        
      })
      
      comId = Noavaran.Companies$Com_ID[i]
      
      bg = getSMAGainDf(tail(thisSymbolDataframe, 500),
                        1:30,
                        31:90,
                        F)
      
      bg = data.frame(cbind(comId, bg))
      
      return(bg)
    }
    runInThread = function(i) {
      preRequired()
      bg = getCompanyAndCalcBestGain(i)
      insertIntoDB(bg)
    }
    
    runInThread(i)
  }
}

timeOfExecution(CalculateBestMovingAverageForAllCompany, T)
