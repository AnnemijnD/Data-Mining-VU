############################
#
# Author : Tanjina Islam
# Creation Date : 14th May, 2018
#
############################

# library for parellel processing
library(doParallel)

# To create a local 4-node snow cluster

num_of_cluster <- makeCluster(detectCores(), type = "SOCK")
registerDoParallel(num_of_cluster)  # For linux/mac use library(doMC) and registerDoMC(cores = 4)

# Print process Ids

foreach(i=1:length(num_of_cluster)) %dopar% Sys.getpid()

data_sample = read.csv("sample_train_10prc.csv")

data_sample

## Data Processing ##

# Remove the redundant column "X"
data_sample <- data_sample[-c(1)] 

attach(data_sample)


# filling up missing values with 0 for comp_rate 1 - comp_rate 8

data_sample[28] = as.data.frame(lapply(data_sample[28], function(x) ifelse(is.na(x), 0, x)))
data_sample[31] = as.data.frame(lapply(data_sample[31], function(x) ifelse(is.na(x), 0, x)))
data_sample[34] = as.data.frame(lapply(data_sample[31], function(x) ifelse(is.na(x), 0, x)))
data_sample[37] = as.data.frame(lapply(data_sample[31], function(x) ifelse(is.na(x), 0, x)))
data_sample[40] = as.data.frame(lapply(data_sample[31], function(x) ifelse(is.na(x), 0, x)))
data_sample[43] = as.data.frame(lapply(data_sample[31], function(x) ifelse(is.na(x), 0, x)))
data_sample[46] = as.data.frame(lapply(data_sample[31], function(x) ifelse(is.na(x), 0, x)))
data_sample[49] = as.data.frame(lapply(data_sample[31], function(x) ifelse(is.na(x), 0, x)))

# filling up missing values with -1 for rest of the other attributes
# data_sample[1:27] = as.data.frame(lapply(data_sample[1:27], function(x) ifelse(is.na(x), -1, x)))
data_sample[5:6] = as.data.frame(lapply(data_sample[5:6], function(x) ifelse(is.na(x), -1, x)))
data_sample[13] = as.data.frame(lapply(data_sample[13], function(x) ifelse(is.na(x), -1, x)))
data_sample[25:26] = as.data.frame(lapply(data_sample[25:26], function(x) ifelse(is.na(x), -1, x)))
data_sample[29:30] = as.data.frame(lapply(data_sample[29:30], function(x) ifelse(is.na(x), -1, x)))
data_sample[32:33] = as.data.frame(lapply(data_sample[32:33], function(x) ifelse(is.na(x), -1, x)))
data_sample[35:36] = as.data.frame(lapply(data_sample[35:36], function(x) ifelse(is.na(x), -1, x)))
data_sample[38:39] = as.data.frame(lapply(data_sample[38:39], function(x) ifelse(is.na(x), -1, x)))
data_sample[41:42] = as.data.frame(lapply(data_sample[41:42], function(x) ifelse(is.na(x), -1, x)))
data_sample[44:45] = as.data.frame(lapply(data_sample[44:45], function(x) ifelse(is.na(x), -1, x)))
data_sample[47:48] = as.data.frame(lapply(data_sample[47:48], function(x) ifelse(is.na(x), -1, x)))
data_sample[50:51] = as.data.frame(lapply(data_sample[50:51], function(x) ifelse(is.na(x), -1, x)))
data_sample[53] = as.data.frame(lapply(data_sample[53], function(x) ifelse(is.na(x), -1, x)))

# Write CSV in R
write.csv(data_sample, file = "sample_train_10prc_no_missing_val.csv")

data_new = read.csv("sample_train_10prc_no_missing_val.csv")
data_new

