GetSymbolDfWithPersionDate = function(df) {
  library("dplyr")
  calendar <- read.csv("D:/calendar.csv")
  calendar$Date = as.Date(calendar$Date)
  
  res = inner_join(df, calendar, by = c("Date"="Date"))
}
