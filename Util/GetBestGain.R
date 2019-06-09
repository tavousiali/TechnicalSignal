getBestGain = function(maxNoOfTrades, df) {
  sortedDf = df[order(df$`No. of Trades`), , drop = FALSE]
  ndf = sortedDf[sortedDf$`No. of Trades` < maxNoOfTrades,]
  #View(df[order(df$`Gain(%)`), , drop = FALSE])
  return(head(ndf[ndf$`Gain(%)` == max(ndf$`Gain(%)`), ], 1))
}