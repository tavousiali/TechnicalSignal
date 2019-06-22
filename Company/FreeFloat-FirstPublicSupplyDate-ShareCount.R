library(DBI)
library(odbc)

getFf_Fpsd_Sc = function() {
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
  
  result = dbGetQuery(
    con,
    "DECLARE @date dDate
    SELECT @date = MAX(ComSH_Date) FROM [DIT].Tbl05_CompanyShareHolder
    
    SELECT S1.Com_ID,S1.ComMI_FirstPublicSupplyDate, S2.ComC_ShareCount, S3.Com_FreeFloat FROM (
    SELECT Q1.Com_ID, Q1.ComMI_FirstPublicSupplyDate  FROM DIT.Tbl02_CompanyMarketItem Q1
    INNER JOIN
    (
    SELECT C.Com_ID, MIN(ComMI_FirstPublicSupplyDate) AS MINFirstPublicSupplyDate FROM DIT.Tbl02_CompanyMarketItem CMI WITH (NOLOCK)
    INNER JOIN dit.Tbl02_Company C ON C.Com_ID = CMI.Com_ID
    WHERE Com_EntityType IN (1,2,16) AND ComMI_EntityType IN (1,2,16)
    GROUP BY C.Com_ID
    ) Q2 ON Q2.Com_ID = Q1.Com_ID AND Q2.MINFirstPublicSupplyDate = Q1.ComMI_FirstPublicSupplyDate
    WHERE Q1.ComMI_EntityType IN (1,2,16)
    ) S1
    INNER JOIN (
    SELECT Q1.Com_ID, Q1.ComC_ShareCount FROM dit.Tbl05_CompanyCalendar Q1 WITH (NOLOCK)
    INNER JOIN DIT.Tbl01_Calendar Q3 ON Q3.Cal_ID = Q1.Cal_ID
    INNER JOIN
    (
    SELECT cc.Com_ID, MAX(c.PKDate) AS MAXPKDate
    FROM dit.Tbl05_CompanyCalendar cc  WITH (NOLOCK)
    INNER JOIN DIT.Tbl01_Calendar c ON c.Cal_ID = cc.Cal_ID
    GROUP BY cc.Com_ID
    ) Q2 ON Q1.Com_ID = Q2.Com_ID AND MAXPKDate = Q3.PKDate AND ComC_Type = 1
    ) S2 ON S2.Com_ID = S1.Com_ID
    INNER JOIN (
    SELECT Com_ID, P as Com_FreeFloat
    FROM
    (
    SELECT Q3.Com_ID
    ,(100-sum([ComSHD_SharePercent])) P
    FROM [DIT].[Tbl05_CompanyShareHolderDetail] Q1 WITH (NOLOCK)
    INNER JOIN DIT.Tbl05_CompanyShareHolder Q3 ON Q1.ComSH_ID = Q3.ComSH_ID
    INNER JOIN
    (
    SELECT Com_ID, MAX(ComSH_Date) MaxComSH_Date, CONVERT(date, ComSH_Date) ComSH_Date
    FROM DIT.Tbl05_CompanyShareHolder Q1  WITH (NOLOCK)
    GROUP BY Com_ID, CONVERT(date, ComSH_Date)
    ) Q4 ON Q3.ComSH_Date = Q4.MaxComSH_Date AND Q3.Com_ID = Q4.Com_ID
    WHERE CONVERT(date,Q3.ComSH_Date) = CONVERT(date,@date)
    GROUP BY Q3.Com_ID
    ) F
    ) S3 ON S3.Com_ID = S1.Com_ID"

  )
  
  return(result)
  
}

# getFf_Fpsd_Sc()