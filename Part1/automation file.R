#Since its an aspx page, we need to perform an automation on the page wherein the dropdown is 
#selected one by one and the page source is retrieved and the data frame is created along with 
#a csv. At the end all the data frames are merged into one csv


#Using RSelenium for automating the website
install.packages("RSelenium")
update.packages("RSelenium")
library(RSelenium)
library(XML)
library(magrittr)
library(rvest)

#manually start selenium from console: navigate to the location jar file is downloaded - 
#command: java -jar selenium-server-standalone-2.53.1.jar
#RemoteWebDriver instances should connect to: http://127.0.0.1:4444/wd/hub

require(RSelenium)

#RSelenium has a main reference class named remoteDriver. 
#To connect to a server you need to instantiate a new remoteDriver with appropriate options.

remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444, browserName = "firefox")

#To connect to the server use the open method.
remDr$open()
remDr$getStatus()

#To start with we navigate to a url.
remDr$navigate("https://www.ffiec.gov/nicpubweb/nicweb/HCSGreaterThan10B.aspx")

# We can execute the below command to check if the dropdown is present
#remDr$executeScript("return document.getElementById('DateDropDown').hidden;", args = list())

j<-0

#Retrieve the values of a dropdown
values_dropdown <- (remDr$findElement(using = 'id', "DateDropDown"))$getElementText()[[1]]

#Seperate the values from \n as they appear in this format: 0160630\n20160331\n...
values_dropdown <- (strsplit(values_dropdown, "\n"))[[1]]

#Create an empty list to enter each dataframe
list_sb <- list()

#Run a loop, where each dropdown is selected, and the page is received, data frame is created for each
#and put in the list_sb

for(i in values_dropdown)
  {
    option <- remDr$findElement(using = 'xpath', sprintf("//*/option[@value = %s]", i))
    option$clickElement()
    
    #Each dropdown element is found using xpath and clicked.Pieces of 'table' is retrieved usinh html_nodes
    table <- read_html(remDr$getPageSource()[[1]])
    sb_table <- html_nodes(table, 'table')
    sb <- html_table(sb_table, fill = TRUE)[[1]]
    
    #Cleaning data: Here, data cleaning is performed.Where in the first 8 lines are removed which are not needed 
    #in the csv file.
    sb <- sb[-(1:8), ]
    
    #Column names are renamed using the first line of the row.
    colnames(sb) = sb[1, ]
    sb = sb[-1, ]
    
    #rownames are re-named with a correct order as 1:number_of_rows
    rownames(sb) <- 1:nrow(sb)
    
    #There is an unwanted row created at the bottom: so that is deleted as well
    sb <- sb[1:(nrow(sb)-2),]
    
    #Here, all the extra columns with NA values is deducted.
    sb <- sb[ , ! apply( sb , 2 , function(x) all(is.na(x)) ) ]
    
    #Since later all the data frames will be merged, so the Rank will change. Hence, Rank column is removed
    sb$Rank <- NULL
    
    #An extra date column is included as later we will need to merge the data frames and get the stacked data
    sb["Date"] <- NA
    
    #Column name for total Asset is renamed to remove the Date value
    colnames(sb)[3] <- sprintf("Total Assets %s",j)
    
    #Define the format of date for the Date column and place dates.
    sb$Date <- as.Date(i,"%Y%m%d" )
    
    #Rename date column with index 1, 2, 3 .... so that each total asset and date can be distinguished
    #for each date dropdown data
    colnames(sb)[4] <- sprintf("Date %s",j)
    
    #Insert the data frame to list_sb
    list_sb[[j+1]] <- sb
    
    #Copy data frame to csv file with the name as Daata_date.csv
    write.csv(sb, sprintf("Data_%s.csv",i), row.names=F)
    j<-j+1
}

#Collect all the data frames and merge into a single data frame
merged_data <- Reduce(function(x,y) merge(x,y, by=c(colnames(list_sb[[1]])[1],colnames(list_sb[[1]])[2]), all=TRUE), list_sb)

#Write data frame to csv
write.csv(merged_data, "merged.csv", row.names = F)

#Convert the unstacked data to stacked data

#For each bank,total asset and date is combined with _ seperator 
combined_data <- data.frame( merged_data[1:2], mapply( paste, merged_data[-(1:2)][c(T,F)], merged_data[-(1:2)][c(F,T)], sep = "_") )

library(reshape2)

#Data is stacked for each bank where a variable column holds the column name of Total Asset and value column holds the combined value of total assets and date
stacked_data <- melt(combined_data, id.vars = 1:2)

#Rows with NA_NA combined value is moitted
stacked_data <- stacked_data[!stacked_data$value == "NA_NA", ]

#The last column is split with underscore and stored in a variable
list <- strsplit(as.character(stacked_data$value), "_")

#The last two columns are added to the stacked data i.e. the values of total assets and date in the stacked data dataframe
stacked_data <- transform(stacked_data, value = sapply(list, "[[", 1), Date= sapply(list, "[[", 2))

#Column with total asset values are converted into factors so that they are not character
stacked_data <- transform(stacked_data, value = as.factor(value))

#Write stacked_data frame to csv
write.csv(stacked_data, "stacked_data.csv", row.names = F)




