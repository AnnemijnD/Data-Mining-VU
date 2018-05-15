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

## Data Processing ##

# Remove the redundant column "X"
data_sample <- data_sample[-c(1)] 

attach(data_sample)

# filling up missing values with -1
data_sample[1:54] = as.data.frame(lapply(data_sample[1:54], function(x) ifelse(is.na(x), -1, x)))

# Write CSV in R
write.csv(data_sample, file = "sample_train_10prc_no_missing_val.csv")
