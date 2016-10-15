# get all pdf downloaded
setwd('~/my_project/assignment1/')

#Read the txt file containing the links of pdf in x1
x1 <- readLines("workfile.txt")
length(x1)

#create directoris for pdf, txt , xlsx
dir.create("PeerGroup_1_pdf")
dir.create("PeerGroup_1_txt")
dir.create("PeerGroup_1_xlsx")
setwd('~/my_project/assignment1/PeerGroup_1_pdf')
getwd()
i <- 1

#Run a loop where pdf url is stored each time
#Also, the quarter is assigned to the txt file by checking the month and hence the name of the file is decided
while(i <= length(x1)){
  pdf.url <- x1[i]
  #print(pdf.url)
  a <- tail(strsplit(x1[i],split="/")[[1]],1)
  if(length(grep("Dec|dec|December|december",a))>0){
    a <- gsub("Dec|dec|December|december","Q4_",a)
  }
  else if(length(grep("Jun|June",a))>0){
    a <- gsub("Jun|June","Q2_",a)
  }
  else if(length(grep("Sep|September|Sept",a))>0){
    a <- gsub("Sep|September|Sept","Q3_",a)
  }
  else if(length(grep("March|Mar",a))>0){
    a <- gsub("March|Mar","Q1_",a)
  }
  
  #File is downloaded
  download.file(pdf.url, a)
  i <- i+1
}


