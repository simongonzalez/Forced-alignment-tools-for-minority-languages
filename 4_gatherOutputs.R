#This script reads all the outputs from the force-alignments and prepares
#new columns for storing acoustic information
#Author: Simon Gonzalez - simon.gonzalez@anu.edu.au

#loads libraries
library(rPraat)
library(dplyr)
library(stringr)
library(ggplot2)
library(plotly)
library(readr)

source('./functions/findSegments.R')
source('./functions/findTranscription.R')
source('./functions/findWords.R')
source('./functions/get_name_parameter.R')

fls <- list.files('./output', full.names = T, pattern = '.TextGrid')
cntr = 1
for(i in fls){

  print(paste0(cntr, '/', length(fls)))
  tg <- tg.read(i, encoding = as.character(guess_encoding(i)$encoding[1]))
  
  fullname <- gsub('.TextGrid', '', basename(i))
  namesSplit <- unlist(strsplit(fullname, '_'))
  
  tmpCorpora <- namesSplit[1]
  tmpName <- namesSplit[2]
  
  tmpSegsLocs <- which(!tg[[2]]$label %in% c('', 'sp', 'sil'))
  tmpSegs <- tg[[2]]$label[tmpSegsLocs]
  tmpSegsPrev <- tg[[2]]$label[tmpSegsLocs-1]
  tmpSegsFoll <- tg[[2]]$label[tmpSegsLocs+1]
  tmpSegsOnset <- tg[[2]]$t1[tmpSegsLocs]
  tmpSegsOffset <- tg[[2]]$t2[tmpSegsLocs]
  tmpSegsDur <- tmpSegsOffset - tmpSegsOnset
  
  segmentTierLabel <- names(tg)[2]
  transcriptTierLabel <- names(tg)[1]
  
  #get words
  wordlabel = NULL
  wordOnset = NULL
  wordOffset = NULL
  wordMid = NULL
  wordDur = NULL
  wordLoc <- NULL
  
  for(j in 1:length(tmpSegsLocs)){
    wordlabel[j] = findWords(data = tg, segNumber = tmpSegsLocs[j], tierLabel = segmentTierLabel, wordTier = transcriptTierLabel)[[1]]
    wordOnset[j] = findWords(data = tg, segNumber = tmpSegsLocs[j], tierLabel = segmentTierLabel, wordTier = transcriptTierLabel)[[2]]
    wordOffset[j] = findWords(data = tg, segNumber = tmpSegsLocs[j], tierLabel = segmentTierLabel, wordTier = transcriptTierLabel)[[3]]
    wordMid[j] = findWords(data = tg, segNumber = tmpSegsLocs[j], tierLabel = segmentTierLabel, wordTier = transcriptTierLabel)[[4]]
    wordDur[j] = findWords(data = tg, segNumber = tmpSegsLocs[j], tierLabel = segmentTierLabel, wordTier = transcriptTierLabel)[[5]]
    wordLoc[j] = findWords(data = tg, segNumber = tmpSegsLocs[j], tierLabel = segmentTierLabel, wordTier = transcriptTierLabel)[[6]]
  }

  #get previous words
  prevWords <- tg[[transcriptTierLabel]]$label[wordLoc-1]
  
  #get following words
  follWords <- tg[[transcriptTierLabel]]$label[wordLoc+1]
  
  tmpdf <- data.frame(fullname, corpus = tmpCorpora, speaker = tmpName,
                      segment = tmpSegs, onset = tmpSegsOnset, offset = tmpSegsOffset, dur = tmpSegsDur,
                      word = wordlabel, wordOnset, wordOffset, wordDur, 
                      previous = tmpSegsPrev, following = tmpSegsFoll)
  
  if(i == fls[1]){
    df <- tmpdf
  }else{
    df <- rbind(df, tmpdf)
  }
  
  write.csv(df, 'dfoutputs.csv', row.names = F)
  
  cntr = cntr + 1
  
}

#identify the position of the segment in the word
df$position <- ifelse(df$onset == df$wordOnset, 'initial', 'medial')
df[df$offset == df$wordOffset, 'position'] <- 'final'
df[df$onset == df$wordOnset & df$offset == df$wordOffset, 'position'] <- 'both'

#creates duration and prepares the file to store acoustic information
df$mid <- df$onset + ((df$offset - df$onset)/2)
df$wordMid <- df$wordOnset + ((df$wordOffset - df$wordOnset)/2)
df$F1 <- 0
df$F2 <- 0
df$F3 <- 0

df$pitch <- 0
df$intensity <- 0

#saves data
write.csv(df, 'dfoutputs.csv', row.names = F, quote = F)
