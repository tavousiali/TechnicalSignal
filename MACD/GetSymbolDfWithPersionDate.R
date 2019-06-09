GetSymbolDfWithPersionDate = function(df) {
  library("dplyr")
  symboldf = tail(df,500)
  #symboldf = head(symboldf,56)
  calendar <- read.csv("D:/calendar.csv")
  calendar$Date = as.Date(calendar$Date)
  
  res = inner_join(symboldf, calendar, by = c("Date"="Date"))
  View(res)  
}
