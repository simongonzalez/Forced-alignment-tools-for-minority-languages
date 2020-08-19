findWords = function(data = NULL, segNumber = NULL, tierLabel = NULL, wordTier = NULL){
  
  finBegin = data[[tierLabel]]$t1[segNumber]
  finEnd = data[[tierLabel]]$t2[segNumber]
  
  allInds = which(data[[wordTier]]$t1 <= finBegin)
  
  uniqueIndex = allInds[length(allInds)]
  
  wordLoc = uniqueIndex
  wordLabel = data[[wordTier]]$label[uniqueIndex]
  wordOnset = data[[wordTier]]$t1[uniqueIndex]
  wordOffset = data[[wordTier]]$t2[uniqueIndex]
  wordMid = wordOnset + ((wordOffset - wordOnset)/2)
  wordDur = wordOffset - wordOnset
  
  return(list(wordLabel, wordOnset, wordOffset, wordMid, wordDur, wordLoc))
  
}