TotalGainCalculation = function(fromTo, calDescription)
{
  CalculateGainForAllSymbol = function(fromTo, calDescription) {
    
    stockDF = data.frame()
    for (i in 1:nrow(Noavaran.Companies)) {
    #for (i in 1:200) {
      symbolName = Noavaran.Companies$Com_Symbol[i]
      
      stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
      
      thisSymbolDataframe = tryCatch({
        get(stringSymbolName)
      }, error = function(e) {
        
      })
      
      comId = Noavaran.Companies$Com_ID[i]
      
      df = thisSymbolDataframe[thisSymbolDataframe$Date >= fromTo[1] &
                                 thisSymbolDataframe$Date <= fromTo[2],]
      if (!is.null(df)) {
        bg = getTotalGainDf(df, comId)
        
        if (!is.null(bg)) {
          stockDF = rbind(stockDF, bg)
        }
      }
    }
    browser()
    source("Util/ConnectionString.R")
    dbWithTransaction(con, {
      #ثبت تاریخ در دیتابیس
      calculationTableId = Id(schema = "DIT", table = "Tbl18_TechnicalSignal_CalculationDate")
      val = data.frame(
        Cal_Date = Sys.time(),
        Cal_Description = calDescription,
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
      
      stockDF$Cal_ID = lastCalcId
      
      tryCatch({
        table_id <-
          Id(schema = "DIT", table = "Tbl18_TechnicalSignalTotalGain")
        
        dbWriteTable(
          conn = con,
          name = table_id,
          value = stockDF,
          append = TRUE
        )
      }, error = function(e) {
        source("Util/Logger.R")
        logger.error(e)
      }, finally = {
        
      })
    })
    
    dbDisconnect(con)
  }
  
  timeOfExecution(CalculateGainForAllSymbol, fromTo, calDescription)
}