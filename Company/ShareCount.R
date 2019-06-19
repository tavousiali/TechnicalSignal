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

ShareCount = dbGetQuery(
  con,
  "SELECT Q1.Com_ID, Q1.ComC_ShareCount FROM dit.Tbl05_CompanyCalendar Q1 
  INNER JOIN DIT.Tbl01_Calendar Q3 ON Q3.Cal_ID = Q1.Cal_ID
  INNER JOIN 
  ( 
  SELECT cc.Com_ID, MAX(c.PKDate) AS MAXPKDate
  FROM dit.Tbl05_CompanyCalendar cc
  INNER JOIN DIT.Tbl01_Calendar c ON c.Cal_ID = cc.Cal_ID
  GROUP BY cc.Com_ID
  ) Q2 ON Q1.Com_ID = Q2.Com_ID AND MAXPKDate = Q3.PKDate"
)

library(dplyr)
Noavaran.Companies$Com_ID <- as.numeric(Noavaran.Companies$Com_ID)
ShareCount$Com_ID <- as.numeric(ShareCount$Com_ID)
Noavaran.Companies = left_join(Noavaran.Companies, ShareCount)
