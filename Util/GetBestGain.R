getBestGain = function(maxNoOfTrades, df) {
  sortedDf = df[order(df$TradeNo), , drop = FALSE]
  ndf = sortedDf[sortedDf$TradeNo < maxNoOfTrades,]
  return(head(ndf[ndf$GainPercent == max(ndf$GainPercent), ], 1))
}
