calculateGain = function(df, firstDayClose, lastDayClose) {
  gain = 0
  pc = 0
  nc = 0
  buySellNo = 0
  wageRate = 1.5
  
  rowCount = nrow(df)
  if (rowCount > 0) {
    for (i in 1:rowCount) {
      row <- df[i,]
      
      if (i == 1 & row$negativeSignal) {
        next()
      }
      if (pc == 0 | nc == 0) {
        if (row$positiveSignal) {
          pc = row$Close
        } else {
          nc = row$Close
        }
      }
      
      if (pc != 0 & nc != 0) {
        gain = gain + (nc - pc)
        nc = 0
        pc = 0
        buySellNo = buySellNo + 1
      }
    }
    
    if (row$positiveSignal) {
      gain = gain + (lastDayClose - row$Close)
      buySellNo = buySellNo + 1
    }
  }
  
  gain = gain - (buySellNo * wageRate / 100)
  gainPercent = (gain / firstDayClose) * 100
  gainFirstLast = lastDayClose - firstDayClose
  gainFirstLastPercent = (gainFirstLast / firstDayClose) * 100
  return(c(
    gain,
    gainPercent,
    gainFirstLast,
    gainFirstLastPercent,
    buySellNo
  ))
}
