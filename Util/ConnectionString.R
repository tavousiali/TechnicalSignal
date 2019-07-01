#ConnectionString
con <- dbConnect(
  odbc(),
  Driver = "SQL Server",
  Server = "EAGLE30",
  Database = "FinancialAnalysisDB",
  UID = "dit",
  PWD = "@shahin9814",
  Port = 1433,
  encoding = 'UTF-8'
)