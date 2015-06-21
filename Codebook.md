---
title: "Codebook"
output: html_document
---
This codebook describes the variables found in the data, the data itself, and any transformations.  

<h1>The Assignment</h1>
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
---
<h1>The Data</h1>
The original data came from the following zip file:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

You should unzip the data in the same folder as the source file to make this project work.  The zip file should expand to a folder called 'UCI HAR Dataset' which should be in the same directory / folder as the source code run_analysis.R.

Please refer to the following documents inside the zip file: ReadMe.txt and features_info.txt for an explanation of the project and the data contained within.

The result is the mean of the average and standard deviation of each metric grouped by subject and activity.
---
<h1>The Script</h1>
Note: Not every file in the zip folder is used for the project; only the ones referenced in the cdoe below.  I load the appropriate libraries and read in the features and activity labels.  The features.txt will become my column headers later on
```{r}
#read in data from root folder for labels and such
library(data.table)
library(dplyr)
library(tidyr)
activity_labels.txt <- read.table(file="./UCI HAR Dataset/activity_labels.txt",blank.lines.skip = FALSE,header=FALSE)
features.txt <- read.table(file="./UCI HAR Dataset/features.txt",blank.lines.skip=FALSE,header=FALSE)
```
Note how I use the t function to transpose rather than the dplyr function.
```{r}
#get the column names from the features file and then transpose them to read as 
#such 

features <- t(features.txt[2]) #the t function transposes the rows to a flat character vector
#honestly, I could have done with this with dplyr, but
#at this point I was still working with dataframes, so I stayed with it.
```
Also note that this <a href="https://class.coursera.org/getdata-015/forum/thread?thread_id=112#comment-276">diagram</a> made things quite clear about how the data was to be assembled.  Note: when assembling data, not use the sep argument when using read.table functions.

This reads in the data into temporary data frames where they are lined up via bind_cols.

Note: this opearation is repeated for trainign data.
```{r}
#read in other data frames for the test data
subject_test.txt <-read.table( file="./UCI HAR Dataset/test/subject_test.txt",blank.lines.skip=FALSE,header=FALSE)
X_test.txt <-read.table( file="./UCI HAR Dataset/test/X_test.txt",blank.lines.skip=FALSE,header=FALSE)
Y_test.txt <-read.table( file="./UCI HAR Dataset/test/y_test.txt",blank.lines.skip=FALSE,header=FALSE)

#Bind data via columns according to the example diagram provided by David Hood
TestData<- bind_cols(X_test.txt,subject_test.txt,Y_test.txt)
colnames(TestData) <- c(features,"SubjectID","ActivityID") #add these two column names
```
This operation only retrieves the columns for mean and starndard deviation
```{r}
NewData <- NewData[,c(grep("mean()|std()",features.txt[,2]),length(features.txt[,2])+1,length(features.txt[,2])+2)]
```
Finally, after joining the activity labels 
I use dplyr's functions to join the lables and then summarize each column grouped by subjectid and activity description.

```{r}
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
```

