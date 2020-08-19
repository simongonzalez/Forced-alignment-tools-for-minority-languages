get_name_parameter = function(complete_name, name_separator, specify_location){
  #get location of all separators
  separator_locs = unlist(lapply(strsplit(complete_name, ''), function(x) which(x == '_')))
  
  locs_matrix = matrix(nrow = (length(separator_locs)+1), ncol = 2)
  
  locs_matrix[1,1] = 1
  locs_matrix[1,2] = separator_locs[1]-1
  
  for(i in 2:(nrow(locs_matrix)-1)){
    locs_matrix[i,1] = separator_locs[i-1]+1
    locs_matrix[i,2] = separator_locs[i]-1
  }
  
  locs_matrix[nrow(locs_matrix),1] = separator_locs[length(separator_locs)]+1
  locs_matrix[nrow(locs_matrix),2] = nchar(complete_name)
  
  output_parameter = substr(complete_name, locs_matrix[specify_location,1], locs_matrix[specify_location,2])
  
  return(output_parameter)
}