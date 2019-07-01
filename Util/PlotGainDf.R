plotGainDf = function(df) {
  library(plotly)
  p <- plot_ly(data = df, x = ~GainPercent, y = ~TradeNo)
  return(p)
  
}
