####################
#مربوط به محاسبات کلی#
####################

#کامنت در جدول تاریخ
settings.calDescription = 'SMA-1:200-From:81-To:96'
#پکیج های مورد نیاز
settings.usedPackage = c("foreach", "doParallel", "DBI", "odbc", "log4r","dplyr", "plotly")
#درصد محاسبه کارمزد که احتمالا ۱.۴۶ درصد صحیح تر است
settings.wageRate = 1.5
#پس از بدست آوردن بهترین معاملات، آنهایی که بیشتر از این مقدار معامله دارند، صرف نظر شود
#قاعدتا کاربر علاقه دارد، تا با یک تعداد معامله محدود، بهترین گین را بدست بیاورد
settings.maxTradeNo = 1000

#######################
#مربوط به میانگین متحرک ها#
#######################

#از تاریخ تا تاریخ (برای محاسبه میانگین متحرک ها در یک بازه تاریخی)
settings.sma.fromTo = c('2001-03-21', '2017-03-21')
#بردار میانگین متحرک کوتاه مدت
settings.sma.smaMinMaxLow = 1:200
#بردار میانگین متحرک بلند مدت
settings.sma.smaMinMaxHigh = 1:200

################
#مربوط به گین کلی#
################

#از تاریخ تا تاریخ
settings.totalGain.fromTo = c('2017-03-21', '2019-03-21')

################
#مربوط به شرکت ها#
################

#شرکت های که بیش از n روز از آخرین معامله آنها گذشته است
settings.company.daysPastFromLastTrade = 7

settings.company.valueThreshold = c(10 ^ 8, 10 ^ 9, 10 ^ 10, 10 ^ 11)
settings.company.valueCoefficient = 5
settings.company.valuePeriodTime = 60

settings.company.volumeThreshold = c(10 ^ 8, 10 ^ 9, 10 ^ 10, 10 ^ 11)
settings.company.volumeCoefficient = 5
settings.company.volumePeriodTime = 60

#از تاریخ تا تاریخ
settings.company.fromTo = c('2017-03-21', '2019-03-21')

################
# مسیرها
################
# مسیر پکیج ها
settings.packagePath = "C:/Program Files/R/R-3.6.1/library"