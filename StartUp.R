source("Settings.R")
source("Util/InstallPackages.R")
installPackages(settings.usedPackage)

#محاسبات مربوط به میانگین متحرک ها
source('MovingAverage/CalculateBestMovingAverageInThread.R')
MovingAverageCalculation()

#محاسبات مربوط به گین کلی
# source('MovingAverage/CalculateBestMovingAverageInThread.R')
# MovingAverageCalculation()
