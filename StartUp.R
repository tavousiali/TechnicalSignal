source("Util/InstallPackages.R")
sourceFile()
installPackages(settings.usedPackage)
libraryPackage()

#محاسبات مربوط به میانگین متحرک ها
source('MovingAverage/CalculateBestMovingAverageInThread.R')
MovingAverageCalculation(c('2001-03-21', '2017-03-20'), 1:30, 31:90, 'SMA - 1:30-31:90 - c(2001-03-21, 2017-03-20)')
MovingAverageCalculation(c('2001-03-21', '2017-03-20'), 1:40, 41:200, 'SMA - 1:40-40:200 - c(2001-03-21, 2017-03-20)')
MovingAverageCalculation(c('2001-03-21', '2017-03-20'), 1:90, 1:90, 'SMA - 1:90-1:90 - c(2001-03-21, 2017-03-20)')
MovingAverageCalculation(c('2001-03-21', '2017-03-20'), 1:200, 1:200, 'SMA - 1:200-1:200 - c(2001-03-21, 2017-03-20)')

MovingAverageCalculation(c('2001-03-21', '2015-03-20'), 1:30, 31:90, 'SMA - 1:30-31:90 - c(2001-03-21, 2015-03-20)')
MovingAverageCalculation(c('2001-03-21', '2015-03-20'), 1:40, 41:200, 'SMA - 1:40-40:200 - c(2001-03-21, 2015-03-20)')
MovingAverageCalculation(c('2001-03-21', '2015-03-20'), 1:90, 1:90, 'SMA - 1:90-1:90 - c(2001-03-21, 2015-03-20)')
MovingAverageCalculation(c('2001-03-21', '2015-03-20'), 1:200, 1:200, 'SMA - 1:200-1:200 - c(2001-03-21, 2015-03-20)')

MovingAverageCalculation(c('2001-03-21', '2017-03-20'), seq(3,30,by = 3), seq(33,90,by = 3), 'SMA - seq(3,30,by = 3)-seq(33,90,by = 3) - c(2001-03-21, 2017-03-20)')
MovingAverageCalculation(c('2001-03-21', '2017-03-20'), seq(5,30,by = 5), seq(35,90,by = 5), 'SMA - seq(5,30,by = 5)-seq(35,90,by = 5) - c(2001-03-21, 2017-03-20)')
MovingAverageCalculation(c('2001-03-21', '2017-03-20'), seq(5,40,by = 5), seq(40,200,by = 5), 'SMA - seq(5,40,by = 5)-seq(40,200,by = 5) - c(2001-03-21, 2017-03-20)')
MovingAverageCalculation(c('2001-03-21', '2017-03-20'), 1:15, 16:50, 'SMA - 1:15-16:50 - c(2001-03-21, 2017-03-20)')

#MovingAverageCalculation(settings.sma.fromTo, settings.sma.smaMinMaxLow, settings.sma.smaMinMaxHigh, settings.calDescription)

#محاسبات مربوط به اطلاعات تکمیلی شرکت ها
source('CompanyExtraData/CompanyDf.R')
#CompanyExtraDataCalculation(settings.company.fromTo, 'CompanyExtraData-ForTest')
CompanyExtraDataCalculation(settings.company.fromTo, 'CompanyExtraData')

#محاسبات مربوط به گین کلی
source('TotalGain/CalculateGainForAllSymbol.R')
TotalGainCalculation(settings.totalGain.fromTo, 'TotalGain')
TotalGainCalculation(c('2017-03-21', '2019-07-22'), 'TotalGain - c(2017-03-21, 2019-07-22)')
