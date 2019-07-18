getBestGain = function(maxNoOfTrades, df) {
  # sortedDf = df[order(df$TradeNo), , drop = FALSE]
  # ndf = sortedDf[sortedDf$TradeNo <= maxNoOfTrades,]
  # return(head(ndf[ndf$GainPercent == max(ndf$GainPercent), ], 1))
  
  ndf = df[df$TradeNo <= maxNoOfTrades,]
  if (nrow(ndf) > 0)  {
    return(head(df[df$GainPercent == max(ndf$GainPercent),], 1))
  }
  return(NULL)
}
