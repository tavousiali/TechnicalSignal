source("Settings.R")
calculateGainSMA = function(df) {
  #browser()
  gain = 0
  gainPercent = 0
  buySellNo = 0
  wageRate = settings.wageRate
  
  rowCount = nrow(df)
  if (rowCount > 0) {
    buySellNo = nrow(df[df$positiveSignal == 1, ])
    s = data.frame(buy = df[df$positiveSignal, ]$Close, sell = df[df$negativeSignal, ]$Close)
    gainWithoutWage = sum(s$sell - s$buy)
    gainPercentWithoutWage = sum((s$sell - s$buy) / s$buy)
    gainPercent = (gainPercentWithoutWage -  ((buySellNo * wageRate) / 100)) * 100
    gain = gainWithoutWage * (1 - ((buySellNo * wageRate) / 100))
  }
  
  return(c(gain,
           gainPercent,
           buySellNo))
}
