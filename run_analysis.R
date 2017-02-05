#
# run_analysis.R
#

# Settings ..................................................................

# Data directory
data_dir <- "UCI HAR Dataset"

# Files
training_files <- c( "train/X_train.txt", "train/y_train.txt", "train/subject_train.txt" )
test_files <- c( "test/X_test.txt", "test/y_test.txt", "test/subject_test.txt" )

# Output file 
main_output_file <- "tidy_dataset.txt"
average_output_file <- "average_dataset.txt"

# Features file
features_file <- "features.txt"

# Activities file
activity_labels_file <- "activity_labels.txt"

# ---------------------------------------------------------------------------
# Step 1: Merge training and testing data sets.
#
# Load and merge the training and test by row binding ('rbind').
# ---------------------------------------------------------------------------

# 1. Training data: new (empty) data frame
training_data <- data.frame()

# Read the first data file
cat(sprintf("Reading '%s'...\n", training_files[1]))
training_data <- read.table( paste(data_dir, training_files[1], sep="/"),
                  sep = "",
                  header = FALSE )

# Read the other files and (column) bind to the training_data
for( file in training_files[-(1)] )
{
  cat(sprintf("Reading '%s'...\n", file))
  training_data <- cbind(training_data, read.table(
    paste(data_dir, file, sep="/"),
    sep = "",
    header = FALSE ))
}

# 2. Testing data: new (empty) data frame
test_data <- data.frame()

# Read the first data file
cat(sprintf("Reading '%s'...\n", test_files[1]))
test_data <- read.table( paste(data_dir, test_files[1], sep="/"),
                             sep = "",
                             header = FALSE )

# Read the other files and (column) bind to the test_data
for( file in test_files[-(1)] )
{
  cat(sprintf("Reading '%s'...\n", file))
  test_data <- cbind(test_data, read.table( paste(data_dir, file, sep="/"),
    sep = "",
    header = FALSE ))
}

#
cat("Reading files complete:\n")
cat(sprintf("  - training size : %dx%d\n", nrow(training_data), ncol(training_data)))
cat(sprintf("  - test size     : %dx%d\n", nrow(test_data), ncol(test_data)))

# Now, join the training and testing data sets
cat("Joining data...\n")
full_data <- rbind( training_data, test_data )
cat(sprintf("Data set size : %dx%d\n", nrow(full_data), ncol(full_data)))

# (Step 4): 
# We load the column names from the features file and set them before
# selecting the columns.
features_data <- read.table( paste(data_dir, features_file, sep="/") )
col_labels <- as.character( features_data[,2] )

# Add a column name for label (Y) and subject columns
col_labels <- append( col_labels, c("activity-id", "subject-id") )

# Set the column names
colnames(full_data) <- col_labels

# ---------------------------------------------------------------------------
# Step 2: Extract only the measurements on the mean and standard deviation
# for each measurement. 
#
# We will select only columns with 'mean' and 'std' names.
#
# ---------------------------------------------------------------------------

cat("Selecting columns...\n")

# Columns with 'mean' or 'std' (and '-id's)
selected_columns <- grep("mean|std|\\-id", colnames(full_data))

# Data selection
data_selected <- full_data[, selected_columns]

cat(sprintf("Selected data set size : %dx%d\n",
            nrow(data_selected), ncol(data_selected)))

# ---------------------------------------------------------------------------
# Step 3: Uses descriptive activity names to name the activities in the data
# set. 
#
# Activity names come from the 'activity_labels.txt' file. They match with
# 'y_data' values.
#
# ---------------------------------------------------------------------------

# Load activity names from the file
activity_names <- read.table( paste(data_dir, activity_labels_file, sep="/") )

# Create a factor vector with the activity label
activity_column <- factor(full_data[,"activity-id"],
                          levels = activity_names[,1],
                          labels = activity_names[,2])

# Replace the activity IDs with activity factors (labels)
data_selected[,"activity-id"] <- activity_column

# Just for coherence: rename the column ("activity")
activityid_colnumber = grep("activity-id", colnames(data_selected))
colnames(data_selected)[activityid_colnumber] <- c("activity")

# ---------------------------------------------------------------------------
# Step 4: Appropriately labels the data set with descriptive variable names.
#
# Already done. Just save the data set into the file "tidy_data.txt"
#
# ---------------------------------------------------------------------------

cat(sprintf("Saving tidy data to '%s'...\n", main_output_file))
write.csv(data_selected, file=main_output_file)

# ---------------------------------------------------------------------------
# Step 5: From the data set in step 4, creates a second, independent tidy
# data set with the average of each variable for each activity and each
# subject.
#
# Using 'aggregate' over the data set with 'mean()' function.
# ---------------------------------------------------------------------------

# First: we need to exclude the last two columns (activity and subject-id)
data_len <- length(data_selected) - 2

# Aggregate
data_average <- aggregate( data_selected[,1:data_len], 
           list(data_selected$activity, data_selected$`subject-id`), mean )

# Set column names
colnames(data_average)[1] <- c("activity")
colnames(data_average)[2] <- c("subject-id")

# And save the new data set
cat(sprintf("Saving average data to '%s'...\n", average_output_file))
write.table( data_average, file=average_output_file, row.name=FALSE)

cat("End.")