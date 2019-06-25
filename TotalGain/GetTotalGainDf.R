getTotalGainDf = function(df, comId) {
  if (is.null(df)) {
    return()
  }
  if (nrow(df) == 0) {
    return()
  }
  dfGain = data.frame()
  gainResult = calculateGain(head(df$Close, 1), tail(df$Close, 1))
  dfGain = rbind(dfGain,
                 c(comId,
                   gainResult[1],
                   gainResult[2]))
  names(dfGain) = c('Com_ID', 'TotalGain', 'TotalGainPercent')
  return(dfGain)
}
