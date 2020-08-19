#This script creates a pronunciation dictionary from the transcription files
#in TextGrid format
#It assumes there is only one TextGrid per speaker with only one Tier
#Author: Simon Gonzalez - simon.gonzalez@anu.edu.au

#loads libraries
library(elan)
library(rPraat)
library(audio)
library(tuneR)
library(stringr)
library(seewave)

#sets the name of the language to set files for
languageFolder <- 'path_folder_with_files'

fls <- list.files(languageFolder, full.names = T)

#adds the folders and the files within
allFolders <- NULL

for(flsi in fls){
  flsin <- list.files(flsi, full.names = T)
  allFolders <- append(allFolders, flsin)
}

dict <- NULL

dict_df <- data.frame(file = '', word = '')

#iterates fro each individual file
for(i in allFolders[grep('\\.textgrid', allFolders)]){

  #reads in TextGrid
    tg <- tg.read(i)

    #all transcription to lower case
    tmp_dict = tolower(unlist(strsplit(paste(tg[[1]]$label, collapse = ' '), ' ')))
    #gets rid of empty entries
    tmp_dict = tmp_dict[tmp_dict != '']
    
    tmpdf_dataframe <- data.frame(file = i, word = tmp_dict)
    
    dict_df <- rbind(dict_df, tmpdf_dataframe)
    
    #adds the words to the dictionary
    dict = append(dict, tmp_dict)
}

# #cleaning transcription options
# dict <- gsub("\\:|\\;", "ː", dict)
# dict <- sub("\\(.*\\)", "", dict)
# dict <- gsub("<unintelligible>|<unclear>|<|>|-|--|->|\\?|\\.", "", dict)
# dict <- gsub("\\(.*", "", dict)
# dict <- dict[!grepl('\\)|\n', dict)]

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
