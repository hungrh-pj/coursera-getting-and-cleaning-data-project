library(reshape2)

fileName <- "getdata_dataset.zip"

#  download and unzip the dataset
if (!file.exists(fileName))
{
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, fileName, method="curl")
}  

#  if the downloaded file is already extracted
if (!file.exists("UCI HAR Dataset"))
{ 
    unzip(fileName) 
}

#  load activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

#  extract only the data on mean and standard deviation
wantedFeatures <- grep(".*mean.*|.*std.*", features[,2])
wantedFeatures.names <- features[wantedFeatures,2]

#  load the datasets - features.txt has 561 lines and train/X_train.txt has 561 columns. If 
#you think as database these are the ID. See output_checking_dataset.txt
train <- read.table("UCI HAR Dataset/train/X_train.txt")[wantedFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[wantedFeatures]
testActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", wantedFeatures.names)

# turn activities & subjects into factors (the terms ‘category’ and ‘enumerated type’ are also used for factors)
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

#  similar to transpose - see output_melted_data.txt
meltedAllData <- melt(allData, id = c("subject", "activity"))

#  see output_dcasted_data.txt
dcastedAllData <- dcast(meltedAllData, subject + activity ~ variable, mean)

#  write to output
write.table(dcastedAllData, "tidy.txt", row.names = FALSE, quote = FALSE)
