timeOfExecution = function(func, ...) {
  start.time <- Sys.time()
  
  result = func(...)
  
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  
  #print(paste0("Time of execution code: ", time.taken, '-',end.time, '-',start.time))
  return(time.taken)
}