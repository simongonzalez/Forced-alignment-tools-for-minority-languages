#script to calculate standard deviations from Formant values and filter accordingly
#Author: Simon Gonzalez
#email: simon.gonzalez@anu.edu.au
#Last date updated: 20 June 2019

library(dplyr)
library(ggplot2)

#Functions
#==============================================================================================================
#multiplot function from winston@stdout.org - http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

#calculate sds for each formant
                        # data = df
                        # sd_value = 3
                        # f1_label = 'F1.50.'
                        # f2_label = 'F2.50.'
                        # vowel_column = 'vowel'
                        # sex_column = NULL
                        # plot_vowels = T
                        # compare = T
sd_classify = function(data = NULL, sd_value = NULL, f1_label = NULL, f2_label = NULL, vowel_column = NULL, sex_column = NULL, plot_vowels = F, compare = F){
  #-----data: incoming data (data.frame)
  #-----sd_value: standard deviation value cutoff (numeric, e.g. 2.5)
  #-----vowel_column: label of the column with the vowel information (character, e.g. 'vowel')
  #-----sex_column: label of the column with the sex information (character, e.g. 'gender')
  #-----plot_vowels: if plotting the vowel space after filtering (Boolean: TRUE or FALSE)
  
  incoming_data = data
  
  #create formulae
  mean_f1_formula = as.formula(paste0(' ~ mean(', f1_label, ', na.rm = TRUE)'))
  mean_f2_formula = as.formula(paste0(' ~ mean(', f2_label, ', na.rm = TRUE)'))
  
  sd_f1_formula = as.formula(paste0(' ~ sd(', f1_label, ', na.rm = TRUE)'))
  sd_f2_formula = as.formula(paste0(' ~ sd(', f2_label, ', na.rm = TRUE)'))
  
  mean_sd_lowerBound_f1_formula = as.formula(paste0(' ~ mean(', f1_label, ', na.rm = TRUE) - (', sd_value, '*sd(', f1_label, ', na.rm = TRUE))'))
  mean_sd_upperBound_f1_formula = as.formula(paste0(' ~ mean(', f1_label, ', na.rm = TRUE) + (', sd_value, '*sd(', f1_label, ', na.rm = TRUE))'))
  
  mean_sd_lowerBound_f2_formula = as.formula(paste0(' ~ mean(', f2_label, ', na.rm = TRUE) - (', sd_value, '*sd(', f2_label, ', na.rm = TRUE))'))
  mean_sd_upperBound_f2_formula = as.formula(paste0(' ~ mean(', f2_label, ', na.rm = TRUE) + (', sd_value, '*sd(', f2_label, ', na.rm = TRUE))'))
  
  dots_f1 <- setNames(list(  mean_f1_formula,  
                             sd_f1_formula,  
                             mean_sd_lowerBound_f1_formula, 
                             mean_sd_upperBound_f1_formula),  
                      c('mean_f', 'sd_f', 'sdMINUS2', 'sdPLUS2'))
  
  dots_f2 <- setNames(list(  mean_f2_formula,  
                             sd_f2_formula,  
                             mean_sd_lowerBound_f2_formula, 
                             mean_sd_upperBound_f2_formula),  
                      c('mean_f', 'sd_f', 'sdMINUS2', 'sdPLUS2'))
  
  if(is.null(sex_column)){
    #calculates acoustic frequencies sds for each sex and vowel--------------------------------------------------------------------------------------------
    frequencies_sum_f1 = as.data.frame(data %>% group_by_(.dots = c(vowel_column)) %>% summarise_(.dots = dots_f1))
    frequencies_sum_f2 = as.data.frame(data %>% group_by_(.dots = c(vowel_column)) %>% summarise_(.dots = dots_f2))
    
    data$f1_class = 'in'
    data$f2_class = 'in'
    
    for(i in 1:nrow(frequencies_sum_f1)){
      data[data[[vowel_column]] == frequencies_sum_f1[[vowel_column]][i] & data$F1 < frequencies_sum_f1$sdMINUS2[i], c('f1_class')] = 'out'
      data[data[[vowel_column]] == frequencies_sum_f1[[vowel_column]][i] & data$F1 > frequencies_sum_f1$sdPLUS2[i], c('f1_class')] = 'out'
      data[data[[vowel_column]] == frequencies_sum_f2[[vowel_column]][i] & data$F2 < frequencies_sum_f2$sdMINUS2[i], c('f2_class')] = 'out'
      data[data[[vowel_column]] == frequencies_sum_f2[[vowel_column]][i] & data$F2 > frequencies_sum_f2$sdPLUS2[i], c('f2_class')] = 'out'
    }
  }else{
    #calculates acoustic frequencies sds for each sex and vowel--------------------------------------------------------------------------------------------
    frequencies_sum_f1 = as.data.frame(data %>% group_by_(.dots = c(vowel_column, sex_column)) %>% summarise_(.dots = dots_f1))
    frequencies_sum_f2 = as.data.frame(data %>% group_by_(.dots = c(vowel_column, sex_column)) %>% summarise_(.dots = dots_f2))
    
    data$f1_class = 'in'
    data$f2_class = 'in'
    
    for(i in 1:nrow(frequencies_sum_f1)){
      data[data[[vowel_column]] == frequencies_sum_f1[[vowel_column]][i] & data[[sex_column]] == frequencies_sum_f1[[sex_column]][i] & data$F1 < frequencies_sum_f1$sdMINUS2[i], c('f1_class')] = 'out'
      data[data[[vowel_column]] == frequencies_sum_f1[[vowel_column]][i] & data[[sex_column]] == frequencies_sum_f1[[sex_column]][i] & data$F1 > frequencies_sum_f1$sdPLUS2[i], c('f1_class')] = 'out'
      data[data[[vowel_column]] == frequencies_sum_f2[[vowel_column]][i] & data[[sex_column]] == frequencies_sum_f2[[sex_column]][i] & data$F2 < frequencies_sum_f2$sdMINUS2[i], c('f2_class')] = 'out'
      data[data[[vowel_column]] == frequencies_sum_f2[[vowel_column]][i] & data[[sex_column]] == frequencies_sum_f2[[sex_column]][i] & data$F2 > frequencies_sum_f2$sdPLUS2[i], c('f2_class')] = 'out'
    }
  }
  
  data = data[data$f1_class == 'in',]
  data = data[data$f2_class == 'in',]
  
  data$f1_class = NULL
  data$f2_class = NULL
  
  if(plot_vowels){
    if(compare){
      basis = ggplot(incoming_data, aes_string(x = 'F2', y = 'F1', color = vowel_column)) + geom_point() + scale_x_reverse() + scale_y_reverse() + ggtitle('Basis')
      filtered = ggplot(data, aes_string(x = 'F2', y = 'F1', color = vowel_column)) + geom_point() + scale_x_reverse() + scale_y_reverse() + ggtitle('Filtered')
      multiplot(basis, filtered)
    }
    else
    print(ggplot(data, aes_string(x = 'F2', y = 'F1', color = vowel_column)) + geom_point() + scale_x_reverse() + scale_y_reverse())
  }
  
  return(data)
}

#EXAMPLE==============================================================================================================================

#df_3sd = sd_classify(data = df, sd_value = 3, f1_label = 'F1.50.', f2_label = 'F2.50.', vowel_column = 'vowel', plot_vowels = T, compare = T)

