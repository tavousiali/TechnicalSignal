UpdateCompanyDf = function() {
  library(dplyr)
  
  source("Company/CategorizeCompanyByValue.R")
  source("Company/CategorizeCompanyByVolume.R")
  source("Company/FreeFloat-FirstPublicSupplyDate-ShareCount.R")
  source("Company/GetLastTradeDate.R")
  
  companyValueDf = CategorizeCompanyByValue()
  companyVolumeDf = CategorizeCompanyByVolume()
  ff_fpsd_sc_Df = getFf_Fpsd_Sc()
  lastTradeDate = GetLastTradeDate()
  
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
c = newCompanyDf[,c('Com_ID','Com_BourseSymbol','Com_Symbol','ValueAverage', 'ValueScale', 'VolumeAverage', 'VolumeScale', 'ComC_ShareCount', 'Com_FreeFloat', 'LastTradeDate')]

c = c[order(c$ValueAverage),]
c = c[c$ValueAverage > 4,]
#c = c[c$Com_Symbol == 'HIWEB',]
View()
