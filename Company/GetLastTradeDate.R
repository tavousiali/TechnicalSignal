GetLastTradeDate = function() {
  
  stockDF = data.frame()
  for (i in 1:nrow(Noavaran.Companies)) {
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    if (!is.null(thisSymbolDataframe)) {
      comId = Noavaran.Companies$Com_ID[i]
      stockDF = rbind(stockDF, data.frame(comId, tail(thisSymbolDataframe,1)$Date))
    }
  }

  names(stockDF) = c('Com_ID',
                     'LastTradeDate')
  
  return(stockDF)
}

#View(GetLastTradeDate())
