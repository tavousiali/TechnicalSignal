ConvertToUTF16 <- function(String){
  
  # Determining Encoding ====
  for (i in 1:length(String)) {
    if (Encoding(String)[i]=="unknown"){
      BaseEnc=""
    } else {
      BaseEnc=Encoding(String)[i]
      break
    }
  }
  
  # Converting to UTF-16 ====
  String <- lapply(String, function(x){
    unlist(iconv(x,from = BaseEnc,to = "UTF-16LE",toRaw = T))
  })
  return(String)
}
ConvertToUTF8 <- function(String){
  
  # Determining Encoding ====
  for (i in 1:length(String)) {
    if (Encoding(String)[i]=="unknown"){
      BaseEnc=""
    } else {
      BaseEnc=Encoding(String)[i]
      break
    }
  }
  
  if (Encoding(String)[1]!="UTF-8"){
    
    String <-as.character(lapply(String, function(x){
      unlist(iconv(x,from = BaseEnc,to = "UTF-8"))}))
  }
  return(String)
}