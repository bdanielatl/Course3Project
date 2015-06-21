#run_analysis.R
#Ben Daniel, 2015

#read in data from root folder for labels and such
library(data.table)
library(dplyr)
library(tidyr)
activity_labels.txt <- read.table(file="./UCI HAR Dataset/activity_labels.txt",blank.lines.skip = FALSE,header=FALSE)
features.txt <- read.table(file="./UCI HAR Dataset/features.txt",blank.lines.skip=FALSE,header=FALSE)
#this diagram given by David Hood helped me understand how to put the data together
#https://class.coursera.org/getdata-015/forum/thread?thread_id=112#comment-276

#get the column names from the features file and then transpose them to read as 
#such 

features <- t(features.txt[2]) #the t function transposes the rows to a flat character vector
#honestly, I could have done with this with dplyr, but
#at this point I was still working with dataframes, so I stayed with it.

#read in other data frames for the test data
subject_test.txt <-read.table( file="./UCI HAR Dataset/test/subject_test.txt",blank.lines.skip=FALSE,header=FALSE)
X_test.txt <-read.table( file="./UCI HAR Dataset/test/X_test.txt",blank.lines.skip=FALSE,header=FALSE)
Y_test.txt <-read.table( file="./UCI HAR Dataset/test/y_test.txt",blank.lines.skip=FALSE,header=FALSE)

#Bind data via columns according to the example diagram provided by David Hood
TestData<- bind_cols(X_test.txt,subject_test.txt,Y_test.txt)
colnames(TestData) <- c(features,"SubjectID","ActivityID") #add these two column names

#read int he other data frames for the training data
subject_train.txt <-read.table( file="./UCI HAR Dataset/train/subject_train.txt",blank.lines.skip=FALSE,header=FALSE)
X_train.txt <-read.table( file="./UCI HAR Dataset/train/X_train.txt",blank.lines.skip=FALSE,header=FALSE)
Y_train.txt <-read.table( file="./UCI HAR Dataset/train/y_train.txt",blank.lines.skip=FALSE,header=FALSE)

#Bind data via columns according to the example diagram provided by Jeff Leek
TrainData<- bind_cols(X_train.txt,subject_train.txt,Y_train.txt)
colnames(TrainData) <- c(features,"SubjectID","ActivityID") #add column names

#combine the XData together
NewData <- rbind(TestData,TrainData)

#subset the data frame to only retrieve the columns at specified positions where mean and standard deviation measures are
#also append the subjectid and activityID
#note: a test was run succesfully using the dplyr select function, which means that there are no duplicate column names
#what I am doing is asking for all rows and the indexes of columns where mean() and std() are
#found, then I also added the last two columns; hence the `c` function.
NewData <- NewData[,c(grep("mean()|std()",features.txt[,2]),length(features.txt[,2])+1,length(features.txt[,2])+2)]

#combine the column names in a join (like a database join)
NewData <- dplyr::inner_join(NewData, activity_labels.txt, by=c("ActivityID"="V1")) #workign code

#transform the NewData into a tbl_df which is easier to examine with dplyr
NewData <-dplyr::tbl_df(NewData) %>%
    #rename the V2 column
  rename(ActivityDescr = V2)

#sumamrize each column with the mean function
 NewData <- NewData %>% 
    group_by(SubjectID,ActivityDescr) %>%
       summarise_each(funs(mean))

 #write out the result
 write.table(NewData,row.names = FALSE,file="tidy_movement_data.txt")