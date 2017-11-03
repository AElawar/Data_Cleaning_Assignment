# Ensure the downloaded file 'UCI HAR Dataset' is in your working directory.
# Load activity labels and features
activityLabels <- read.table("activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data involving the mean and standard deviation, then adjust 
# the corresponding features names
featuresSelected <- grep(".*mean.*|.*std.*", features[,2])
featuresSelected.names <- features[featuresSelected,2]
featuresSelected.names = gsub('-mean', 'Mean', featuresSelected.names)
featuresSelected.names = gsub('-std', 'Std', featuresSelected.names)
featuresSelected.names = gsub('[-()]', '', featuresSelected.names)

# Load the train and test datasets, and bind them with their corresponding
# subject and activity data 
train <- read.table("train/X_train.txt")[featuresSelected]
trainActivities <- read.table("train/y_train.txt")
trainSubjects <- read.table("train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("test/X_test.txt")[featuresSelected]
testActivities <- read.table("test/y_test.txt")
testSubjects <- read.table("test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge train and test datasets, and add column labels to merged dataset
mergedDataset <- rbind(train, test)
colnames(mergedDataset) <- c("subject", "activity", featuresSelected.names)

# In merged data frame, convert activity and subject values into factors
mergedDataset$activity <- factor(mergedDataset$activity, levels=activityLabels[,1], labels=activityLabels[,2])
mergedDataset$subject <- as.factor(mergedDataset$subject)

# Convert the merged data frame into long-format data frame using 'subject' 
# and 'activity' as id-variables 
mergedDataset.melted <- melt(mergedDataset, id = c("subject", "activity"))

# Convert the long-format data frame back into wide-format data frame using 
# 'subject' and 'activity' as id-variables, and compute the mean of all values
# per subject per activity
mergedDataset.mean <- dcast(mergedDataset.melted, subject + activity ~ variable, mean)

# Output the new 'tidy' data frame into a text file
write.table(mergedDataset.mean, "tidy.txt", row.names=FALSE, quote=FALSE)
