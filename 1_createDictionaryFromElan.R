#This script creates a pronunciation dictionary from the transcription files
#in Elan format. It also creates the corresponding transcription TextGrids.
#To achieve this, it also needs access to the corresponding audio files.
#Audio files must be in WAV format.
#Author: Simon Gonzalez - simon.gonzalez@anu.edu.au

#loads libraries
library(elan)
library(rPraat)
library(audio)
library(tuneR)
library(stringr)
library(seewave)

#sets the name of the language to set files for
languageFolder <- './rawinput'

fls <- list.files(languageFolder, full.names = T)

dict <- NULL

transcriptionDuration <- NULL

tierName <- 'Transcription'

#iterates fro each individual file
for(i in fls){

  dfi <- efileAnnotations(i)

  dfi <- dfi[grep(tierName, dfi$TIER_ID),]
  
  # #cleaning option
  # dfi$VALUE <- gsub('<|>|-|\\(|\\)', '', dfi$VALUE)
  
  for(filei in sort(unique(dfi$TIER_ID))){
    df <- dfi[dfi$TIER_ID == filei,]
    
    #TextGrid names
    tmpTGnames <-gsub('elan', 'tgs', i)
    tmpTGnames <- gsub('eaf', 'TextGrid',tmpTGnames)
    tmpTGnames <- gsub('\\.TextGrid', paste0('_', gsub('_.*', '', filei), '\\.TextGrid'), tmpTGnames)

    #WAV names
    tmpWAVnames <-gsub('elan', 'audios', i)
    tmpWAVnames <-gsub('eaf', 'wav', tmpWAVnames)
    
    tmpWAVnamesSave <-gsub('\\.wav', paste0('_', gsub('_.*', '', filei), '\\.wav'), tmpWAVnames)
    tmpWAVnamesSave <-gsub('audios', 'wavs', tmpWAVnamesSave)
    
    df <- df[df$VALUE != '',]
    
    #change times to secs
    df$startTime <- df$t0 / 1000
    df$endTime <- df$t1 / 1000
    
    #all transcription to lower case
    tmp_dict = tolower(unlist(strsplit(paste(df$VALUE, collapse = ' '), ' ')))
    #gets rid of empty entries
    tmp_dict = tmp_dict[tmp_dict != '']
    
    #adds the words to the dictionary
    dict = append(dict, tmp_dict)
    
    #calculate transcription duration
    #transcriptionDuration <- append(transcriptionDuration, sum(df$endTime - df$startTime))
    transcriptionDuration <- sum(df$endTime - df$startTime)
    
    #Creates the TEXTGRID............................................
    #get audio file duration
    s1 <-readWave(tmpWAVnames)
    sound_length <- round(length(s1@left) / s1@samp.rate, 4)
    
    savewav(s1, filename = tmpWAVnamesSave)
    
    #create TG from time information
    tg <- tg.createNewTextGrid(0, sound_length)
    #add tier
    tg <- tg.insertNewIntervalTier(tg, 1, "transcription")
    
    #adds intervals to tiers
    for(k in 1:nrow(df)){
      tg <- tg.insertInterval(tg, "transcription", df$startTime[k], df$endTime[k], df$VALUE[k])
    }
    
    #saves the TextGrid
    tg.write(tg = tg, fileNameTextGrid = tmpTGnames)
  }

}

#saves all dictionary entries
write.csv(data.frame(dict), 'dict.csv', row.names = F)

#Creates the dictionary from all transcriptions
unique_dict = sort(unique(dict))

#saves the unique words in the transcriptions
write.csv(data.frame(unique_dict), 'unique_dict.csv', row.names = F)

#empty variable to store the phonemic representation of the words
entries = NULL

#Creates the phonemic representations
for(ii in 1:length(unique_dict)){
  tmpE =unique_dict[ii]
  
  if(is.na(as.numeric(tmpE))){
    tmpE = paste(unlist(strsplit(tmpE, '')), collapse = ' ')
  }
  
  entries = append(entries, tmpE)
  
}

#stores entries and phonemes as a dataframe
pronDict <- data.frame(unique_dict, entries)

#saves the dictionary as a Tab-Separated file
write.table(pronDict, file = 'pronDict_asis.txt', sep = '\t', quote = F, row.names = F, col.names = F)
