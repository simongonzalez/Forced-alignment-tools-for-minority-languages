findSegments = function(data = NULL, wordNumber = NULL, originLabel = NULL, targetLabel = NULL){
  findWord = data[[originLabel]]$label[wordNumber]
  finBegin = data[[originLabel]]$t1[wordNumber]
  finEnd = data[[originLabel]]$t2[wordNumber]
  
  segBegin = which(data[[targetLabel]]$t1 >= finBegin & data[[targetLabel]]$t1 < finEnd)
  
  segLabel = data[[targetLabel]]$label[segBegin]
  
  segLabel = paste(segLabel, collapse = '')
  
  return(segLabel)
}