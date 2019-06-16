calculateGain = function(firstDayClose, lastDayClose) {
  gainFirstLast = lastDayClose - firstDayClose
  gainFirstLastPercent = (gainFirstLast / firstDayClose) * 100
  return(c(
    gainFirstLast,
    gainFirstLastPercent
  ))
}
