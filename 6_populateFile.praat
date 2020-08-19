#This script populates the empty columns with the acoustic inforlation.
#Author: simon gonzalez (simon.gonzalez@anu.edu.au)

#specify the file name without extension
filename$ = "csvfilename"

#directory where the output TextGrids are located
  directory_textgrid$ = "path_to_textgrid_force-alignment_outputs"

#directory where the Formant files are located
  directory_formant$ = "path_to_formant_files"

#directory where the Pitch files are located
  directory_pitch$ = "path_to_pitch_files"

#directory where the Intensity files are located
  directory_intensity$ = "path_to_intensity_files"

	#loads the csv file
	#........................................................
	Read Table from comma-separated file... 'filename$'.csv

 	# loads textgrid files
 	#........................................................
  	Create Strings as file list... list_textgrid 'directory_textgrid$'/*.TextGrid

  	numberOfFiles = Get number of strings

  	for ifile to numberOfFiles
    	select Strings list_textgrid
    	fileName$ = Get string... ifile
    	Read from file... 'directory_textgrid$'/'fileName$'
  	endfor

  	#loads formant files
  	#........................................................
  	Create Strings as file list... list_formant 'directory_formant$'/*.Formant

  	numberOfFiles = Get number of strings

  	for ifile to numberOfFiles
    	select Strings list_formant
    	fileName$ = Get string... ifile
    	Read from file... 'directory_formant$'/'fileName$'
  	endfor

  	#loads pitch files
  	#........................................................
  	Create Strings as file list... list_pitch 'directory_pitch$'/*.Pitch

  	numberOfFiles = Get number of strings

  	for ifile to numberOfFiles
    	select Strings list_pitch
    	fileName$ = Get string... ifile
    	Read from file... 'directory_pitch$'/'fileName$'
  	endfor

  	#loads intensity files
  	#........................................................
  	Create Strings as file list... list_intensity 'directory_intensity$'/*.Intensity

  	numberOfFiles = Get number of strings

  	for ifile to numberOfFiles
    	select Strings list_intensity
    	fileName$ = Get string... ifile
    	Read from file... 'directory_intensity$'/'fileName$'
  	endfor

#extract values

selectObject: "Table 'filename$'"
tableCols = Get number of rows

writeInfoLine: "Start"

for i from 1 to tableCols
	#appendInfoLine: i
	selectObject: "Table 'filename$'"

	tmpFile$ = Get value... i fullname
	tmpTime = Get value... i mid

	#add formant values
	#........................................................
	#........................................................
	selectObject: "Formant " + tmpFile$
	
	f1Value = Get value at time... 1 tmpTime hertz Linear
	f2Value = Get value at time... 2 tmpTime hertz Linear
	f3Value = Get value at time... 3 tmpTime hertz Linear

	#add pitch values
	#........................................................
	#........................................................

	selectObject: "Pitch " + tmpFile$
	
	tmpPitchValue = Get value at time... tmpTime Hertz Linear

	#add intensity values
	#........................................................
	#........................................................

	selectObject: "Intensity " + tmpFile$
	
	tmpIntensityValue = Get value at time... tmpTime Cubic

	#adds values to table
	#........................................................
	#........................................................
	selectObject: "Table 'filename$'"

	Set numeric value... i F1 f1Value
	Set numeric value... i F2 f2Value
	Set numeric value... i F3 f3Value
	Set numeric value... i pitchValue tmpPitchValue
	Set numeric value... i intensityValue tmpIntensityValue

endfor

selectObject: "Table 'filename$'"

Save as comma-separated file... 'filename$'.csv

writeInfo: "Done"
