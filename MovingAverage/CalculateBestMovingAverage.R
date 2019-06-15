#detach("package:NoavaranSymbols", unload = TRUE)
library(NoavaranIndicators, lib = "C:/Program Files/R/R-3.5.2/library")
library(NoavaranSymbols, lib = "C:/Program Files/R/R-3.5.2/library")
library(TTR)
source("Util/CalculateGain.R")
source("Util/TimeOfExecution.R")
source("Util/PlotGainDf.R")
source("Util/GetBestGain.R")
source("MovingAverage/GetSMAGainDf.R")

timeOfExecution(getSMAGainDf, tail(Noavaran.Symbols.REMAPNA, 500), 5:30, 31:90, T, 'REMAPNA')

getSMAGainDf(tail(Noavaran.Symbols.FEOLAD, 500), 5:30, 31:90, T, 'Symbol')
plotGainDf(G)
#TODO
# 2. باید بررسی بشه که هر سیگنالی که میده، چقدر از کف قیمت فاصله داریم. یعنی در واقع چقدر از سود رو از دست داده ایم
# 3. مشخص بشه که برای این سهم، مثلا ۱۰ بار سیگنال دادیم و از این ۱۰ بار، ۸ بار، مثبت بوده و ۲ بار هم اشتباه بوده
# 4. بررسی روی کلیه سهم ها
# 5. وقتی که میانگین متحرک مثلا ۸۰ روزه انتخاب میشه، در عمل، اون ۸۰ روز اول تو محاسبات نمیاد. بررسی بشه که آیا لازم هست که درست بشه یا نه
# 6. باید به صورت رندم، تاریخ، از-تا رو عوض کنیم تا اعداد بهتری برای هر سهم پیدا کنیم.
# 7. توضیح متنی به کاربر ارائه کنیم. مثلا بگیم که اگر سهم رو از ابتدای این تاریخ تا انتهای اون میخریدید، انقدر سود میکردید. بیشترین سود هم انقدر میشده و شما هم با این سیگنال ما، انقدر سود میکردید.
# 8. نسبت مقدار سود به قیمت اولیه سهم (در واقع بازده درصدی سیگنال ما) مشخص بشه
# 9. ویژوالایز کردن نتایج
# 10. یک کار خیلی مهم: توضیح: در مورد بدست آوردن بهترین سهام از طریق این روش، قاعدتا تمام اون سهم هایی که در لیست بهترین هستند،
# برای مثال سهمی که ۳۰۰۰ درصد رشد کرده، در لیست ما هم اولین سهم معرفی میشه. ولی اگر بیایم و نسبت سود از طریق الگوریت ما
# رو به سود از طریق اخرید ابتدا و انتها و همچنین نسبت سود از طریق الگرویتم ما به سود در بهترین حالت را بدست بیاوریم، بهترین سیهم ها رو میشه معرفی کرد.


bestGainForAllSymbol = function() {
  stockDF = data.frame()
  #for (i in 1:nrow(Noavaran.Companies)) {
  for (i in 1:3) {
    symbolName = Noavaran.Companies$Com_Symbol[i]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    comId = Noavaran.Companies$Com_ID[i]
    
    bg = getSMAGainDf(tail(thisSymbolDataframe, 500), 1:30, 31:90, F, symbolName)
    
    stockDF = rbind(stockDF, bg)
  }
  
  library(xlsx)
  write.xlsx(stockDF, "d:/result.xlsx")
  View(stockDF)
  return(stockDF)
}

timeOfExecution(bestGainForAllSymbol)

bestGainForAllSymbolWithApply = function() {
  stockDF = data.frame()
  
  f = function(x) {
    symbolName = x[2]
    
    stringSymbolName = paste("Noavaran.Symbols.", symbolName, sep = "")
    
    thisSymbolDataframe = tryCatch({
      get(stringSymbolName)
    }, error = function(e) {
      
    })
    
    comId = x[1]
    
    bg = getSMAGainDf(tail(thisSymbolDataframe, 500), 1:30, 31:90, F, symbolName)
    stockDF = rbind(stockDF, bg)
    NULL
  }
  
  apply(Noavaran.Companies, 1, f)
}

timeOfExecution(bestGainForAllSymbolWithApply)
