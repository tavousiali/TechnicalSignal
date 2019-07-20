GetFirstLastTradeDateAndClose = function(fromTo) {
  
  stockDF = data.frame()
  for (i in 1:nrow(Noavaran.Companies)) {
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    thisSymbolDataframe = thisSymbolDataframe[thisSymbolDataframe$Date >= fromTo[1] &
                                                thisSymbolDataframe$Date <= fromTo[2],]
    
    if (!is.null(thisSymbolDataframe) & nrow(thisSymbolDataframe) > 0) {
      comId = Noavaran.Companies$Com_ID[i]
      firstDay = head(thisSymbolDataframe,1)
      lastDay = tail(thisSymbolDataframe,1)
      stockDF = rbind(stockDF, data.frame(comId, firstDay$Date, lastDay$Date, lastDay$Close))
    } else {
      source("Util/Logger.R")
      logger.info(paste('Error in GetLastTradeDateAndClose:', i))
    }
  }

  names(stockDF) = c('Com_ID',
                     'FirstTradeDate',
                     'LastTradeDate',
                     'Close')
  
  return(stockDF)
}