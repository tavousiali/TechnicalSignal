UpdateCompanyDf = function() {
  library(DBI)
  library(odbc)
  library(NoavaranIndicators, lib = "C:/Program Files/R/R-3.5.2/library")
  library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
  source("Util/TimeOfExecution.R")
  library(dplyr)
  
  source("Company/CategorizeCompanyByValue.R")
  source("Company/CategorizeCompanyByVolume.R")
  source("Company/FreeFloat-FirstPublicSupplyDate-ShareCount.R")
  source("Company/GetLastTradeDate.R")
  
  companyValueDf = CategorizeCompanyByValue()
  companyVolumeDf = CategorizeCompanyByVolume()
  ff_fpsd_sc_Df = getFf_Fpsd_Sc()
  lastTradeDate = GetLastTradeDateAndClose()
  
  Noavaran.Companies$Com_ID <- as.numeric(Noavaran.Companies$Com_ID)
  companyValueDf$Com_ID <- as.numeric(companyValueDf$Com_ID)
  companyVolumeDf$Com_ID <- as.numeric(companyVolumeDf$Com_ID)
  ff_fpsd_sc_Df$Com_ID <- as.numeric(ff_fpsd_sc_Df$Com_ID)
  lastTradeDate$Com_ID <- as.numeric(lastTradeDate$Com_ID)
  
  c = data.frame()
  c = inner_join(Noavaran.Companies, companyValueDf)
  c = inner_join(c, companyVolumeDf)
  c = inner_join(c, ff_fpsd_sc_Df)
  c = inner_join(c, lastTradeDate)
  return(c)
}

newCompanyDf = UpdateCompanyDf()

c = data.frame()
c = newCompanyDf[,c('Com_ID','Com_BourseSymbol','ValueAverage', 'ValueScale', 'VolumeAverage', 'VolumeScale', 'ComC_ShareCount', 'Com_FreeFloat', 'Close', 'LastTradeDate', 'Com_EntityType')]

c$CompanyMarketValue = c$ComC_ShareCount * c$Close

c$ComC_ShareCount = as.numeric(c$ComC_ShareCount)
c$CompanyMarketValue = as.numeric(c$CompanyMarketValue)

# مرتب سازی ها
#c = c[order(-c$CompanyMarketValue),] # مرتب ساری بر اساس مارکت ولیو
#c = c[order(-c$ComC_ShareCount),] # مرتب ساری بر اساس تعداد سهم
#c = c[order(-c$ValueScale),] # مرتب ساری بر اساس بزرگی ارزش معاملات
#c = c[order(-c$VolumeScale),] # مرتب ساری بر اساس بزرگی حجم معاملات

#فیلترها

c = c[c$ValueScale > 3,] #سهم های بزرگ
#c = c[c$LastTradeDate == max(c$LastTradeDate),] #سهم هایی که امروز معامله شده اند
c = c[c$Com_EntityType != 16,] #سهم های بورسی

#تبدیل به اعداد خوانا
c$ComC_ShareCount = prettyNum(c$ComC_ShareCount,big.mark=",",scientific=FALSE)
c$CompanyMarketValue = prettyNum(c$CompanyMarketValue,big.mark=",",scientific=FALSE)

rownames(c) = NULL


######


library(DBI)
library(odbc)
con <- dbConnect(odbc(), Driver = "SQL Server", Server = "EAGLE30", 
                 Database = "FinancialAnalysisDB", UID = "dit", PWD = "@shahin9814", 
                 Port = 1433, encoding = "UTF-8")

comIds = paste(as.character(c$Com_ID), collapse=", ")
CalId1 = 1
CalId2 = 4

result = dbGetQuery(con, paste("
                    
                    SELECT Q1.Com_ID, c.Com_Nemad, c.Com_BourseSymbol, c.Com_EntityType, 
                    Q1.i Q1i,Q1.j Q1j, Q2.i Q2i,Q2.j Q2j,
                    Q1.GainPercent Q1GP,Q2.GainPercent Q2GP,
                    Q2.GainPercent - Q1.GainPercent AS Q2Q1Diff,
                    CASE
                    WHEN (Q2.GainPercent - Q1.GainPercent) < 10 THEN 1
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 10 AND (Q2.GainPercent - Q1.GainPercent) < 20 THEN 2
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 20 AND (Q2.GainPercent - Q1.GainPercent) < 30 THEN 3
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 30 AND (Q2.GainPercent - Q1.GainPercent) < 40 THEN 4
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 40 AND (Q2.GainPercent - Q1.GainPercent) < 50 THEN 5
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 50 AND (Q2.GainPercent - Q1.GainPercent) < 60 THEN 6
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 60 AND (Q2.GainPercent - Q1.GainPercent) < 70 THEN 7
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 70 AND (Q2.GainPercent - Q1.GainPercent) < 80 THEN 8
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 80 AND (Q2.GainPercent - Q1.GainPercent) < 90 THEN 9
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 90 AND (Q2.GainPercent - Q1.GainPercent) < 100 THEN 10
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 100 AND (Q2.GainPercent - Q1.GainPercent) < 110 THEN 11
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 110 AND (Q2.GainPercent - Q1.GainPercent) < 120 THEN 12
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 120 AND (Q2.GainPercent - Q1.GainPercent) < 130 THEN 13
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 130 AND (Q2.GainPercent - Q1.GainPercent) < 140 THEN 14
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 140 AND (Q2.GainPercent - Q1.GainPercent) < 150 THEN 15
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 150 AND (Q2.GainPercent - Q1.GainPercent) < 160 THEN 16
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 160 AND (Q2.GainPercent - Q1.GainPercent) < 170 THEN 17
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 170 AND (Q2.GainPercent - Q1.GainPercent) < 180 THEN 18
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 180 AND (Q2.GainPercent - Q1.GainPercent) < 190 THEN 19
                    WHEN (Q2.GainPercent - Q1.GainPercent) >= 190 AND (Q2.GainPercent - Q1.GainPercent) < 200 THEN 20
                    WHEN (Q2.GainPercent - Q1.GainPercent) > 200 THEN 21
                    END AS Abundance
                    --Q2.GainPercent / Q1.GainPercent AS Q2GP_To_Q1GP,
                    --(Q2.GainPercent - Q1.GainPercent) / Q2.GainPercent AS Q2Q1Diff_To_Q2GP_Rate
                    FROM
                    (SELECT * FROM [FinancialAnalysisDB].[DIT].[Tbl18_TechnicalSignalSMA] 
                    WHERE cal_id = ",CalId1,") Q1
                    INNER JOIN 
                    (SELECT * FROM [FinancialAnalysisDB].[DIT].[Tbl18_TechnicalSignalSMA] 
                    WHERE cal_id = ",CalId2 ,") Q2 ON Q2.Com_ID = Q1.Com_ID
                    INNER JOIN DIT.Tbl02_Company c ON c.Com_ID = Q1.Com_ID
                    WHERE Q1.Com_ID IN (", comIds, ")
                    --WHERE Q2.GainPercent - Q1.GainPercent > 100
                    ORDER BY Q2Q1Diff DESC
                    
                    
                    "))

library(plotly)

p <- plot_ly(
  x = seq(10,210, 10),
  y = as.data.frame(table(factor(result$Abundance, levels = 1:21)))$Freq,
  #name = "SF Zoo",
  type = "bar"
)
p
