#Part 1 of the txt file is converted to xlsx format

setwd("~/my_project/assignment1/PeerGroup_1_txt")

#All the files with .txt extension are stored in the files variable as names.
files <- list.files(pattern=".txt$")
i <- grep("Q1_2015|2016|Q2_2015|Q3_2015", files)


#Data cleaning is performed and converted to xlsx

for(fileName in files[i]){
  x1 <- readLines(fileName)
  
  #Since the txt file contains all the three structured of data, we get the first part of txt file
  #by finding a starting pattern of the second part and storing its index
  a <- grep(".*BHCPR PERCENTILE DISTRIBUTION REPORT", x1)
  line <- a[1] - 1
  
  #Now, x1 is created from first line to the (start line of part1 -1)
  x1 <- x1[1:line]
  length(x1)
  
  #Data cleaning
  
  #"PAGE", "PEER GROUP 1" is a word that appears on each page and is not needed, hence its deleted
  grep("PAGE",x1)
  x1 <- gsub("PAGE","",x1)
  x1 <- gsub("PEER GROUP 01","",x1)
  
  library(stringr)
  i<-1
  
  while(i <= length(x1)){
    
    #If line starts with space,digit, space then that line is removed. This is basically to remove lines containing only single digits
    #it is actually a part of "PAGE" word which goes onto the next line
    if(length(grep("^(\\s\\d\\s)", x1[i])) >0){
      x1 <- x1[-i]
      i <- i-1
    }
    
    #If line starts with space,digit,word,space then that line is removed.This is basically to remove lines containing only single digits
    #it is actually a part of "PAGE" word which goes onto the next line
    else if(length(grep("^(\\s\\d\\w\\s)", x1[i])) >0){
      x1 <- x1[-i]
      i <- i-1
    }
    i <- i+1
  }
  
  i <- 1
  while(i <= length(x1)){
    
    #If line starts with spaces,digit,digit,"/" then that line is not disturbed.
    if(length(grep("^(\\s+\\d\\d\\/)", x1[i])) > 0 ){
    }
    
    #If line does not starts with spaces,digit,digit,"/" then folowing operations are checked:
    else{
      
      #If line starts with space,"-","-" then the line is removed. There are two checks for two "-"
      #characters as there are line that start with negative value with "-" sign and we dont want
      #to disturb them. We need to remove lines with "-----+"
      if(length(grep("^(\\s+\\-\\-)", x1[i])) > 0 || length(grep("^(\\-\\-)", x1[i])) > 0 ){
        x1 <- x1[-i]
        i <- i-1
      }
      
      #If the line starts with spaces, then just remove the space for each of the line.
      else if(length(grep("^(\\s+)", x1[i])) > 0){
        x1[i] <- gsub("^(\\s+)","",x1[i])
      }
    }
    i <- i+1
  }
  
  #Spaces at the end of the lines is removed.
  x1 <- str_trim(x1,side="right")
  
  #There are numbers eg: 2,300. The comma has to be removed as later we will be inserting comma as seperator
  #between each column and converting to data frame
  x1 <- gsub(",([0-9])", "\\1", x1)
  
  #Fill lines with multiple spaces with comma as it can serve as a seperator to convert into a data.frame
  x1 <- gsub("(\\s\\s\\s\\s+)", "," , x1)
  
  library(stringr)
  
  #Convert into dataframe with comma seperator
  a1 <- data.frame(str_split_fixed(x1,",",8),stringsAsFactors = FALSE)
  a1
  
  #Rename the name of each column as the third row's values
  colnames(a1) = a1[3,]
  
  #Now there are extra columns that are created where in the values of rows are shifte by 2. Hence shift the values
  #of rows by two for only those rows
  for(k in 1:nrow(a1)){
    j<-2
    while(j <= 8 ){
      if(!grepl("\\d+\\.", a1[k,j]) && grepl("[^0-9]", a1[k,j]) && !grepl("N/A", a1[k,j])){
        a1[k,1] <- paste(a1[k,1], a1[k,j], sep = " ,")
        a1[k,j] <- a1[k,j+1]
        a1[k,j+1] <- a1[k,j+2]
        a1[k,j+2] <- a1[k,j+3]
        a1[k,j+3] <- a1[k,j+4]
        a1[k,j+4] <- a1[k,j+5]
        a1[k,j+5] <- a1[k,j+6]
        a1[k,j+6] <- ''
        j<-j-1
        
      }
      j<-j+1
    }
  }
  
  #When the shifting was done, there were date values that got appended to the first column for 13 rows. 
  #So, removing those values
  a1[,1] <- gsub(",\\d\\d\\/.*",'', a1[,1])
  a1[,7:8] <- NULL
  
  
  #convert class to numeric
  for (l in 2:6) {
    mode(a1[,l]) <- "numeric"  
  }
  
  #Deciding the excel name
  excelName = strsplit(fileName, split = ".txt")
  excelName = paste0(excelName, "_Part1.xlsx")
  library(openxlsx)
  excelPath = paste0("~/my_project/assignment1/PeerGroup_1_xlsx/",excelName)
  
  #write to xlsx
  write.xlsx(a1, file = excelPath)
}

#Part 2 of the txt file is converted to xlsx format
setwd("~/my_project/assignment1/PeerGroup_1_txt")

#All the files with .txt extension are stored in the files variable as names.
files <- list.files(pattern=".txt$")
i <- grep("Q1_2015|2016|Q2_2015|Q3_2015", files)

#Data cleaning is performed and converted to xlsx
for(fileName in files[i]){
  x1 <- readLines(fileName)
  
  #Since the txt file contains all the three structured of data, we get the second part of txt file
  #by finding a starting pattern of the second part and storing its index
  a <- grep(".*BHCPR PERCENTILE DISTRIBUTION REPORT", x1)
  
  #Last line is retrieved by getting the starting pattern of the third part
  b <- grep(".*BHCPR Reporters for Quarter Ending", x1)
  line <- b[1] - 1  
  
  #Now, x1 is created from first line of the second part to the (start line of part3 -1)
  x1 <- x1[a[1]:line]
  length(x1)
  
  #Data cleaning
  
  #"PAGE", "PEER GROUP 1" is a word that appears on each page and is not needed, hence its deleted
  grep("PAG",x1)
  x1 <- gsub("PAG","",x1)
  
  
  i<-1
  while(i <= length(x1)){
    
    #If line has with "PEER GROUP 1" then that line is removed.
    if(length(grep("PEER GROUP 1",x1[i])) >0){
      x1 <- x1[-i]
      i <- i-1
    }
    
    #If line starts with word,space, digit,space then that line is removed. This is basically to remove lines containing only single digits
    #it is actually a part of "PAG" word which goes onto the next line
    else if(length(grep("^(\\w\\s\\d\\s)", x1[i])) >0){
      x1 <- x1[-i]
      i <- i-1
    }
    
    #If line starts with word,space, digit,word,space then that line is removed.
    else if(length(grep("^(\\w\\s\\d\\w\\s)", x1[i])) >0){
      x1 <- x1[-i]
      i <- i-1
    }
    i <- i+1
  }
  i <- 1
  while(i <= length(x1)){
    
    #If line has "PEER.*" then that is removed
    if(length(grep("PEER.*", x1[i])) > 0 ){
      x1[i] <- gsub("PEER.*", "", x1[i])
    }
    
    #If the line has "RATIO" , it is replace with "PEER RATIO"
    else if(length(grep("\\s\\s\\s\\s+RATIO", x1[i]))>0){
      x1[i] <- gsub("RATIO", "PEER RATIO", x1[i])
    }
    
    #if the line has NT or HC , then line is just removed
    else if(length(grep("^(NT )", x1[i]))>0 || length(grep("^(HC )", x1[i]))>0){
      x1 <- x1[-i]
      i <- i-1
    }
    else{
      
      #If line starts with space,"-","-" then the line is removed. There are two checks for two "-"
      #characters as there are line that start with negative value with "-" sign and we dont want
      #to disturb them. We need to remove lines with "-----+"
      if(length(grep("^(\\s+\\-\\-)", x1[i])) > 0 || length(grep("^(\\-\\-)", x1[i])) > 0 ){
        x1 <- x1[-i]
        i <- i-1
      }
      
      #If the line starts with spaces, then just remove the space for each of the line.
      else if(length(grep("^(\\s+)", x1[i])) > 0){
        x1[i] <- gsub("^(\\s+)","",x1[i])
      }
    }
    i <- i+1
  }
  
  #If the line has "COU" , it is replace with "BHC COUNT"
  x1 <- gsub("COU", "BHC COUNT", x1)
  
  
  i<-1
  while(i <= length(x1)){
    
    #If the line starts with one or two digits and ends with space, then
    if(length(grep("^(\\d\\d\\s)$", x1[i])) > 0 || length(grep("^(\\d\\s)$", x1[i])) > 0){
      x1[i-1] <- paste(x1[i-1], x1[i], sep = " ")
      x1 <- x1[-i]
      i <- i-1
    }
    i <- i+1
  }
  library(stringr)
  
  #Spaces at the end of the lines is removed.
  x1 <- str_trim(x1,side="right")
  
  #Fill lines with multiple spaces with comma as it can serve as a seperator to convert into a data.frame
  x1 <- gsub("(\\s\\s+)", "," , x1)
  
  #Convert into dataframe with comma seperator
  a1_1 <- data.frame(str_split_fixed(x1,",",12),stringsAsFactors = FALSE)
  
  #Rename the name of each column as the third row's values
  colnames(a1_1) = a1_1[4,]
  
  #Now there are extra columns that are created where in the values of rows are shifte by 2. Hence shift the values
  #of rows by two for only those rows
  for(k in 1:nrow(a1_1)){
    j<-2
    while(j <= 12 ){
      if(!grepl("\\d+\\.", a1_1[k,j]) && grepl("[^0-9]", a1_1[k,j]) && !grepl("N/A", a1_1[k,j])){
        a1_1[k,1] <- paste(a1_1[k,1], a1_1[k,j], sep = " ,")
        a1_1[k,j] <- a1_1[k,j+1]
        a1_1[k,j+1] <- a1_1[k,j+2]
        a1_1[k,j+2] <- a1_1[k,j+3]
        a1_1[k,j+3] <- a1_1[k,j+4]
        a1_1[k,j+4] <- a1_1[k,j+5]
        a1_1[k,j+5] <- a1_1[k,j+6]
        a1_1[k,j+6] <- a1_1[k,j+7]
        a1_1[k,j+7] <- a1_1[k,j+8]
        a1_1[k,j+8] <- a1_1[k,j+9]
        a1_1[k,j+9] <- a1_1[k,j+10]
        a1_1[k,j+10] <- ''
        j<-j-1
        
      }
      j<-j+1
    }
  }
  
  a1_1[,1] <- gsub(",PEER RATIO.*",'', a1_1[,1])
  a1_1[,11:12] <- NULL
  a1_1[5,10] <-  a1_1[5,2]
  a1_1[5,2] <- ''
  
  #convert class to numeric
  for (l in 2:10) {
    mode(a1_1[,l]) <- "numeric"
  }
  
  #Deciding the excel name
  excelName = strsplit(fileName, split = ".txt")
  excelName = paste0(excelName, "_Part2.xlsx")
  
  library(openxlsx)
  excelPath = paste0("~/my_project/assignment1/PeerGroup_1_xlsx/",excelName)
  
  #write to xlsx
  write.xlsx(a1_1, excelPath)
}


#Part 3 of the txt file is converted to xlsx format
setwd("~/my_project/assignment1/PeerGroup_1_txt")

#All the files with .txt extension are stored in the files variable as names.
files <- list.files(pattern=".txt$")
i <- grep("Q1_2015|2016|Q2_2015|Q3_2015", files)

#Data cleaning is performed and converted to xlsx
for(fileName in files[i]){
  x1 <- readLines(fileName)
  x1
  
  #Since the txt file contains all the three structured of data, we get the third part of txt file
  #by finding a starting pattern of the third part and storing its index
  b <- grep(".*BHCPR Reporters for Quarter Ending", x1)
  line <- length(x1)
  
  #Now, x1 is created from first line of third part to the end of line
  x1 <- x1[b[1]:line]
  
  #Data cleaning
  
  #Fill lines with multiple spaces with colon as it can serve as a seperator to convert into a data.frame
  a <- gsub("(\\s\\s+)", ";", x1[3])
  
  #Convert into dataframe with colon seperator
  a <- data.frame(str_split_fixed(a,";",4),stringsAsFactors = FALSE)
  x1 <- gsub("\\s+Consolidated.*","",x1)
  
  #If line starts with space,"-","-" then the line is removed. There are two checks for two "-"
  #characters as there are line that start with negative value with "-" sign and we dont want
  #to disturb them. We need to remove lines with "-----+"
  x1 <- gsub("^(\\s+\\-\\-.*)", "",x1)
  
  i <- 10
  
  #"BHCPR.", is a word that appears on second page and is not needed, hence its deleted and lines after that deleted
  while(i <= length(x1)){
    if(length(grep(".*BHCPR.*", x1[i])) >0){
      x1 <- x1[-(i:(i+4))]
      break
    }
    i <- i+1
  }
  
  #Spaces at the end of the lines is removed.
  x1 <- str_trim(x1,side="right")
  
  #Spaces at the start of the lines is removed.
  x1 <- str_trim(x1,side="left")
  
  #There are numbers eg: 2,300. The comma has to be removed as later we will be inserting comma as seperator
  #between each column and converting to data frame
  x1 <- gsub("(\\s)([0-9])(,)", "\\1 \\2\\3", x1)
  
  #Fill lines with multiple spaces with colon as it can serve as a seperator to convert into a data.frame
  x1 <- gsub("(\\s\\s+)", ";" , x1)
  
  #Convert into dataframe with colon seperator
  a1_2 <- data.frame(str_split_fixed(x1,";",5),stringsAsFactors = FALSE)
  
  #Join few values of rows
  a1_2[5,2] = paste(a[1,2], a1_2[5,2], sep = " ")
  a1_2[5,4] = paste(a[1,3], a1_2[5,4], sep = " ")
  a1_2[5,5] = paste(a[1,4], a1_2[5,5], sep = " ")
  
  colnames(a1_2) = a1_2[5,]
  a1_2 <- a1_2[-5,]
  
  
  a1_2 <-  a1_2[!apply(a1_2 == "", 1, all),]
  a1_2[nrow(a1_2),1] = paste(a1_2[nrow(a1_2),1], a1_2[nrow(a1_2),2], sep = " " )
  a1_2[nrow(a1_2),2] <- ''
  rownames(a1_2) <- 1:nrow(a1_2)
  
  
  #Deciding the excel name
  excelName = strsplit(fileName, split = ".txt")
  excelName = paste0(excelName, "_Part3.xlsx")
  
  library(openxlsx)
  excelPath = paste0("~/my_project/assignment1/PeerGroup_1_xlsx/",excelName)
  #write to xlsx
  write.xlsx(a1_2,excelPath)
}
