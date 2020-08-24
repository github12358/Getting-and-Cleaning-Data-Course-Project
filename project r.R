Downloads and unzips the 'UCI HAR Dataset
=========================================
if (!dir.exists("UCI HAR Dataset")) {
  # ONE EXTREME COINCIDENCE
  ## It does a simplistic test, yet sufficient on most of the cases,
  ## that is to check if a folder with name 'UCI HAR Dataset' exists
  ## in the working directory to determine if it should download the files.
  ## Obviously if you have, by luck or on purpose, a folder with that name,
  ## it will mistakenly assume that it contains the correct data files.
  message("    ...no folder with name 'UCI HAR Dataset'",
          " exists in the working directory.")
 
  
   message("Trying to download the zipped file...")
  data_url = paste0("https://d396qusza40orc.cloudfront.net/",
                    "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
  download.file(data_url, "data.zip")
  message("    ...zipped data was downloaded successfully ",
          " in the working directory as 'data.zip'.")  
  
  log_entry_url <- paste0("Data was downloaded from the url: ", data_url)
  log_entry_date <- paste0("Data was downloaded at date: " , date())
  
  log_con <- file("log.txt")
  writeLines(c(log_entry_url, log_entry_date), log_con)
  close(log_con)

  message("Trying to extract files from the 'data.zip'",
          "in the working directory...")
  unzip("data.zip")
  message("    ...data files extracted successfully, in the folder \n",
          "       with name 'UCI HAR Dataset' in the working directory.")
  
  
} else {
  message("    ...data files are available, in the folder \n",
          "       with name 'UCI HAR Dataset' in the working directory.")
}

===========================
Loading required packages
===========================
library(dplyr)

======================================================
Loads all the data files needed for this analysis in R
======================================================

read.table_instructions <- list(
   file = list(
    activity_labels = "UCI HAR Dataset/activity_labels.txt",
    features = "UCI HAR Dataset/features.txt",
    subject_train = "UCI HAR Dataset/train/subject_train.txt",
    y_train = "UCI HAR Dataset/train/y_train.txt",
    X_train = "UCI HAR Dataset/train/X_train.txt",
    subject_test = "UCI HAR Dataset/test/subject_test.txt",
    y_test = "UCI HAR Dataset/test/y_test.txt",
    X_test = "UCI HAR Dataset/test/X_test.txt"
  ),
  
  colClasses = list(
    activity_labels = c("integer", "character"),
    features = c("integer", "character"),
    subject_train = "integer",
    y_train = "integer",
    X_train = rep("numeric", 561),
    subject_test = "integer",
    y_test = "integer",
    X_test = rep("numeric", 561)
  ),
  
  nrows = list(
    activity_labels = 6,
    features = 561,
    subject_train = 7352,
    y_train = 7352,
    X_train = 7352,
    subject_test = 2947,
    y_test = 2947,
    X_test = 2947
  )
)

data_files <- with(read.table_instructions,
                   Map(read.table,
                       file = file, colClasses = colClasses, nrows = nrows,
                       quote = "", comment.char = "",
                       stringsAsFactors = FALSE))

message("    ...data files were successfully loaded into R, \n",
        "       in the list with name 'data_files'.")

=====================================================================
Step 1: Merges the training and the test sets to create one data set.
=====================================================================

merged_data <- with(data_files,
                    rbind(cbind(subject_train, y_train, X_train),
                          cbind(subject_test,  y_test,  X_test)))

===============================================================================================
Step 2: Extracts only the measurements on the mean and standard deviation for each measurement.
===============================================================================================

target_features_indexes <- grep("mean\\(\\)|std\\(\\)",
                                data_files$features[[2]])

target_variables_indexes <- c(1, 2, # the first two columns that refer to
                              target_features_indexes + 2)

target_data <- merged_data[ , target_variables_indexes]

===============================================================================
Step 3: Uses descriptive activity names to name the activities in the data set.
===============================================================================

target_data[[2]] <- factor(target_data[[2]],
                           levels = data_files$activity_labels[[1]],
                           labels = data_files$activity_labels[[2]])

==========================================================================
Step 4: Appropriately labels the data set with descriptive variable names.
==========================================================================

descriptive_variable_names <- data_files$features[[2]][target_features_indexes]
descriptive_variable_names <- gsub(pattern = "BodyBody", replacement = "Body",
                                   descriptive_variable_names)

tidy_data <- target_data
names(tidy_data) <- c("subject", "activity", descriptive_variable_names)

======================================================================================================================================================
Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
======================================================================================================================================================

tidy_data_summary <- tidy_data %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean)) %>%
  ungroup()

new_names_for_summary <- c(names(tidy_data_summary[c(1,2)]),
                           paste0("Avrg-", names(tidy_data_summary[-c(1, 2)])))
names(tidy_data_summary) <- new_names_for_summary

write.table(tidy_data_summary, "tidy_data_summary.txt", row.names = FALSE)

message("The script 'run_analysis.R was executed successfully. \n",
        "As a result, a new tidy data set was created with name \n", 
        "'tidy_data_summary.txt' in the working directory.")

=======================
Checking variable names
=======================

str(tidy_data_summary)

