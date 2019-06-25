library(DBI)
library(odbc)
con <- dbConnect(odbc(), Driver = "SQL Server", Server = "EAGLE30", 
                 Database = "FinancialAnalysisDB", UID = "dit", PWD = "@shahin9814", 
                 Port = 1433, encoding = "UTF-8")

result = dbGetQuery(con, "SELECT c.Com_ID, c.Com_Nemad, c.Com_BourseSymbol, c.Com_EntityType,
                    sma.i, sma.j, sma.Gain,sma.GainPercent, sma.TradeNo,
                    tg.TotalGain, tg.TotalGainPercent
                    FROM DIT.Tbl02_Company c
                    INNER JOIN DIT.Tbl18_TechnicalSignalSMA sma ON sma.Com_ID = c.Com_ID
                    INNER JOIN DIT.Tbl18_TechnicalSignalTotalGain tg ON  tg.Com_ID = c.Com_ID
                    ")

#1.
#مرتب سازی بر اساس تعداد معامله
df1 = result[order(result$TradeNo),]
df1 = df1[, c('Com_Nemad','Com_BourseSymbol','Com_EntityType', 'i', 'j', 'Gain', 'TotalGain', 'GainPercent', 'TotalGainPercent', 'TradeNo', 'Type')]
# فیلتر بر اساس حجم معامله
df1 = df1[df1$Type > 2,]
View(df1)
#نتیجه:
# از ۱ معامله تا ۴۷ معامله وجود دارد

#2.
#مرتب سازی بر اساس GainPercent
df2 = result[order(-result$GainPercent),]
df2 = df2[,c('Com_Nemad','Com_BourseSymbol','Com_EntityType', 'i', 'j', 'Gain', 'TotalGain', 'GainPercent', 'TotalGainPercent', 'TradeNo', 'Type')]
df2 = df2[df2$Type > 2,]
View(df2)

#3.
#مرتب سازی بر اساس TotalGainPercent
df3 = result[order(-result$TotalGainPercent),]
df3 = df3[,c('Com_Nemad','Com_BourseSymbol','Com_EntityType', 'i', 'j', 'Gain', 'TotalGain', 'GainPercent', 'TotalGainPercent', 'TradeNo', 'Type')]
df3 = df3[df3$Type > 2,]
View(df3)

#4.
#مرتب سازی بر اساس GainPercent - TotalGainPercent
df4 = result
df4$GainDiff=df4$GainPercent - df4$TotalGainPercent
df4 = df4[order(-df4$GainDiff),]
df4 = df4[,c('Com_Nemad','Com_BourseSymbol','Com_EntityType', 'i', 'j', 'Gain', 'TotalGain', 'GainPercent', 'TotalGainPercent', 'TradeNo', 'GainDiff','Type')]
df4 = df4[df4$Type > 3,]
View(df4)


#Plot
p<-ggplot(data=data.frame(df4$Com_Nemad, df4$GainDiff), aes(x=df4$Com_Nemad, y=df4$GainDiff)) +
  geom_bar(stat="identity")
p
