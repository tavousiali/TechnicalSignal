calculateGain = function(df, firstDayClose, lastDayClose) {
  gain = 0
  buySellNo = 0
  wageRate = 1.5
  
  rowCount = nrow(df)
  if (rowCount > 0) {
    gain = sum(df$Close * (-df$positiveSignal) + df$Close * df$negativeSignal)
    buySellNo = nrow(df[df$positiveSignal == 1,])
  }
  
  gainPercent = ((gain / firstDayClose) * 100) -  (buySellNo * wageRate)
  gain = (gain * (100 - (buySellNo * wageRate)) / 100)
  return(c(
    gain,
    gainPercent,
    buySellNo
  ))
}
