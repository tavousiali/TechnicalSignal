library("log4r")

getLogger = function() {
  # Import the log4r package.
  library('log4r')
  # Create a new logger object with create.logger().
  logger <- create.logger()
  # Set the logger's file output.
  logfile(logger) <- paste0('Logs/',Sys.Date(), '.log')
  # Set the current level of the logger.
  level(logger) <- 'INFO'
  
  return(logger)
}

logger.debug = function(text) {
  debug(getLogger(), text)
}

logger.info = function(text) {
  info(getLogger(), text)
}

logger.warn = function(text) {
  warn(getLogger(), text)
}

logger.error = function(text) {
  error(getLogger(), text)
}

logger.fatal = function(text) {
  fatal(getLogger(), text)
}