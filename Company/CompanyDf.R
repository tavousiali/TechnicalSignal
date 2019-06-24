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
c = c[order(-c$CompanyMarketValue),] # مرتب ساری بر اساس مارکت ولیو
#c = c[order(-c$ComC_ShareCount),] # مرتب ساری بر اساس تعداد سهم
#c = c[order(-c$ValueScale),] # مرتب ساری بر اساس بزرگی ارزش معاملات
#c = c[order(-c$VolumeScale),] # مرتب ساری بر اساس بزرگی حجم معاملات

#فیلترها

#c = c[c$ValueScale > 3,] #سهم های بزرگ
#c = c[c$LastTradeDate == max(c$LastTradeDate),] #سهم هایی که امروز معامله شده اند
c = c[c$Com_EntityType == 1,] #سهم های بورسی

#تبدیل به اعداد خوانا
c$ComC_ShareCount = prettyNum(c$ComC_ShareCount,big.mark=",",scientific=FALSE)
c$CompanyMarketValue = prettyNum(c$CompanyMarketValue,big.mark=",",scientific=FALSE)

rownames(c) = NULL
View(c)

