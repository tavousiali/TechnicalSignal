####################
#مربوط به محاسبات کلی#
####################

#درصد محاسبه کارمزد که احتمالا ۱.۴۶ درصد صحیح تر است
settings.wageRate = 1.5
#پس از بدست آوردن بهترین معاملات، آنهایی که بیشتر از این مقدار معامله دارند، صرف نظر شود
#قاعدتا کاربر علاقه دارد، تا با یک تعداد معامله محدود، بهترین گین را بدست بیاورد
settings.maxTradeNo = 10

#######################
#مربوط به میانگین متحرک ها#
#######################

#از تاریخ تا تاریخ (برای محاسبه میانگین متحرک ها در یک بازه تاریخی)
settings.sma.smaFromTo = c('2017-03-21', '2019-03-21')
#بردار میانگین متحرک کوتاه مدت
settings.sma.smaMinMaxLow = 1:200
#بردار میانگین متحرک بلند مدت
settings.sma.smaMinMaxHigh = 1:200

################
#مربوط به گین کلی#
################

#از تاریخ تا تاریخ
settings.totalGain.totalGainFromTo = c('2017-03-21', '2019-03-21')

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

################
# مسیرها
################
# مسیر پکیج ها
settings.packagePath = "C:/Program Files/R/R-3.6.1/library"

