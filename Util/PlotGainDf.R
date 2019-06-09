plotGainDf = function(df) {
  library(ggplot2)
  theme_set(theme_bw() +
              theme(legend.position = "top"))
  
  # Initiate a ggplot
  b <- ggplot(df, aes(x = df$`No. of Trades`, y = df$Gain))
  
  # Basic scatter plot
  b + geom_point()
  
  # Change color, shape and size
  #b + geom_point(color = "#00AFBB", size = 2, shape = 23)
  
}
