library(DBI)
library(odbc)
con <- dbConnect(
  odbc(),
  Driver = "SQL Server",
  Server = "EAGLE30",
  Database = "FinancialAnalysisDB",
  UID = "dit",
  PWD = "@shahin9814",
  #rstudioapi::askForPassword(""),
  Port = 1433,
  encoding = 'UTF-8'
)

freefloat = dbGetQuery(
  con,
  "DECLARE @date dDate
  SELECT @date = MAX(ComSH_Date) FROM [DIT].Tbl05_CompanyShareHolder
  
  SELECT Com_ID, P as Com_FreeFloat
  FROM
  (
  SELECT Q3.Com_ID
  ,(100-sum([ComSHD_SharePercent])) P
  FROM [DIT].[Tbl05_CompanyShareHolderDetail] Q1
  INNER JOIN DIT.Tbl05_CompanyShareHolder Q3 ON Q1.ComSH_ID = Q3.ComSH_ID
  INNER JOIN
  (
  SELECT Com_ID, MAX(ComSH_Date) MaxComSH_Date, CONVERT(date, ComSH_Date) ComSH_Date
  FROM DIT.Tbl05_CompanyShareHolder Q1
  GROUP BY Com_ID, CONVERT(date, ComSH_Date)
  ) Q4 ON Q3.ComSH_Date = Q4.MaxComSH_Date AND Q3.Com_ID = Q4.Com_ID
  WHERE CONVERT(date,Q3.ComSH_Date) = CONVERT(date,@date)
  GROUP BY Q3.Com_ID
  )F
  ORDER BY F.Com_ID"
)

library(dplyr)
Noavaran.Companies$Com_ID <- as.numeric(Noavaran.Companies$Com_ID)
freefloat$Com_ID <- as.numeric(freefloat$Com_ID)
Noavaran.Companies = left_join(Noavaran.Companies, freefloat)
