#This creates formant, intensity and pitch files from wav files
#Author: simon gonzalez (simon.gonzalez@anu.edu.au)

#directory storing the audio files in wav format
directory$ = "/Users/u1037706/Dropbox/TIG2018/languages/eibela/alignment_20200305/files/"

  # read files
  Create Strings as file list... list 'directory$'/*.wav

  numberOfFiles = Get number of strings

  for ifile to numberOfFiles
    select Strings list
    fileName$ = Get string... ifile

	nameFile$ = replace$ (fileName$, ".wav", "", 1)
	nameFormant$ = replace$ (fileName$, ".wav", ".Formant", 1)
	nameIntensity$ = replace$ (fileName$, ".wav", ".Intensity", 1)
	namePitch$ = replace$ (fileName$, ".wav", ".Pitch", 1)

    Read from file... 'directory$'/'fileName$'

	#Creates Formant files
	#.....................................................................
	#.....................................................................
	To Formant (burg)... 0 5 5500 0.025 50
	outputLocationFormant$ = "praatOutput/formants/" + nameFormant$
	Save as text file... 'outputLocationFormant$'

	#Creates Intensity files
	#.....................................................................
	#.....................................................................
	selectObject: "Sound " + nameFile$

	To Intensity... 100 0.0 Yes
	outputLocationIntensity$ = "praatOutput/intensity/" + nameIntensity$
	Save as text file... 'outputLocationIntensity$'

	#Creates Pitch files
	#.....................................................................
	#.....................................................................
	selectObject: "Sound " + nameFile$

	To Pitch... 0.0 75.0 600.0
	outputLocationPitch$ = "praatOutput/pitch/" + namePitch$
	Save as text file... 'outputLocationPitch$'

	#Removes all working files
	#.....................................................................
	#.....................................................................
	selectObject: "Sound " + nameFile$
	Remove
	selectObject: "Pitch " + nameFile$
	Remove
	selectObject: "Intensity " + nameFile$
	Remove
	selectObject: "Formant " + nameFile$
	Remove

	writeInfoLine: fileName$
  endfor

writeInfoLine: "Done"
