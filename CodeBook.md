---
title: "CodeBook"
author: "tbarreno"
date: "02/02/2017"
output: html_document
---

# Introduction

This file describes the variables, data and transformations performed by
the `run_analysis.R` script.

## Step 1: Merges the training and the test sets to create one data set.

We read the training and test files with `read.csv()`, joining the
label and subjects columns, and then joining the rows from both
data sets.

## Step 2: Extracts only the measurements on the mean and standard deviation for each measurement.

We filter the columns with 'grep()' function over the column names.

## Step 3: Uses descriptive activity names to name the activities in the data set

We load the activity names and replace the numeric values with name
factors (using `colnames()`). The data set is called `data_selected`.

## Step 4: Appropriately labels the data set with descriptive variable names.

This step is done during the Step 1: we load the column names and put them
in the dataset.

## Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

We use `aggregate()` with the `mean()` function over the data columns.

The final data set is called `data_average`.
