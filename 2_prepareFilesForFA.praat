#This script saves textgrids and wave files from the directories specifified.
#This step is done as a transition step when these files are created from R (rPraat) and 
#are prepared for MFA alignment
#Author: simon gonzalez (simon.gonzalez@anu.edu.au)

#Run if the TextGrids are to be resaved
  directory$ = "/Users/u1037706/Dropbox/TIG2018/languages/eibela/newFiles/alignment_20201707/tgs/"

  # read files
  Create Strings as file list... list 'directory$'/*.TextGrid

  numberOfFiles = Get number of strings

  for ifile to numberOfFiles
    select Strings list
    fileName$ = Get string... ifile
    Read from file... 'directory$'/'fileName$'
    Save as text file... 'directory$'/'fileName$'
    Remove
  endfor

#Run if the wavefiless are to be converted
  directory$ = "/Users/u1037706/Dropbox/TIG2018/languages/eibela/newFiles/alignment_20201707/audios/"

  # read files
  Create Strings as file list... list 'directory$'/*.wav

  numberOfFiles = Get number of strings

  for ifile to numberOfFiles
    select Strings list
    fileName$ = Get string... ifile
    Read from file... 'directory$'/'fileName$'
	Convert to mono
	Resample... 44100 50
    Save as WAV file... 'directory$'/'fileName$'
    Remove
  endfor



