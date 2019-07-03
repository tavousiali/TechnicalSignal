plotGainDf = function(df) {
  #browser()
  library(plotly)
  p <- plot_ly(data = df, x = ~GainPercent, y = ~TradeNo,
               text = ~paste("i: ", i, '<br>j:', j, '<br>GainPercent:', round(GainPercent), '<br>TradeNo:', TradeNo),
               color = ~GainPercent, size = ~GainPercent,
               mode = 'markers',
               type = 'scatter'
  )
  p
}
