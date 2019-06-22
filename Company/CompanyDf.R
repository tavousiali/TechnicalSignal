UpdateCompanyDf = function() {
  library(dplyr)
  
  source("Company/CategorizeCompanyByValue.R")
  source("Company/CategorizeCompanyByVolume.R")
  source("Company/FreeFloat-FirstPublicSupplyDate-ShareCount.R")
  
  companyValueDf = CategorizeCompanyByValue()
  companyVolumeDf = CategorizeCompanyByVolume()
  ff_fpsd_sc_Df = getFf_Fpsd_Sc()
  
  Noavaran.Companies$Com_ID <- as.numeric(Noavaran.Companies$Com_ID)
  companyValueDf$Com_ID <- as.numeric(companyValueDf$Com_ID)
  companyVolumeDf$Com_ID <- as.numeric(companyVolumeDf$Com_ID)
  ff_fpsd_sc_Df$Com_ID <- as.numeric(ff_fpsd_sc_Df$Com_ID)
  c = data.frame()
  c = inner_join(Noavaran.Companies, companyValueDf)
  c = inner_join(c, companyVolumeDf)
  c = inner_join(c, ff_fpsd_sc_Df)
  return(c)
}
View(UpdateCompanyDf())
