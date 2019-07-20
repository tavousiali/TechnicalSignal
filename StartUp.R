source("Util/InstallPackages.R")
sourceFile()
installPackages(settings.usedPackage)
libraryPackage()

#محاسبات مربوط به میانگین متحرک ها
source('MovingAverage/CalculateBestMovingAverageInThread.R')
#MovingAverageCalculation(settings.sma.fromTo, 1:5, 6:10, 'SMA - For Test')
MovingAverageCalculation(settings.sma.fromTo, settings.sma.smaMinMaxLow, settings.sma.smaMinMaxHigh, settings.calDescription)

#محاسبات مربوط به اطلاعات تکمیلی شرکت ها
source('CompanyExtraData/CompanyDf.R')
#CompanyExtraDataCalculation(settings.company.fromTo, 'CompanyExtraData-ForTest')
CompanyExtraDataCalculation(settings.company.fromTo, 'CompanyExtraData')

#محاسبات مربوط به گین کلی
source('TotalGain/CalculateGainForAllSymbol.R')
TotalGainCalculation(settings.totalGain.fromTo, 'TotalGain')
