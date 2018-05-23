############################
#
# Author : Tanjina Islam
# Creation Date : 16th May, 2018
#
############################

library(caret)
library(gbm)
library(multcomp)
library(lme4)
library(Metrics) # For MSE and MAE


require(gbm)
require(dplyr)
# library for parellel processing
library(doParallel)

# To create a local 4-node snow cluster

num_of_cluster <- makeCluster(detectCores(), type = "SOCK")
registerDoParallel(num_of_cluster)  # For linux/mac use library(doMC) and registerDoMC(cores = 4)

# Print process Ids

foreach(i=1:length(num_of_cluster)) %dopar% Sys.getpid()

data_sample = read.csv("sample_train_10prc_no_missing_val.csv")

attach(data_sample)
# data_sample

# Feature Engineering: DateTime
data_sample$date_time <- as.character(data_sample$date_time)
data_sample$date_day <- sapply(data_sample$date_time, FUN=function(x) {strsplit(x, split='[- :]')[[1]][3]})
data_sample$date_month <- sapply(data_sample$date_time, FUN=function(x) {strsplit(x, split='[- :]')[[1]][2]})
data_sample$date_hour <- sapply(data_sample$date_time, FUN=function(x) {strsplit(x, split='[- :]')[[1]][4]})
data_sample$date_day <- as.factor(data_sample$date_day)
data_sample$date_month <- as.factor(data_sample$date_month)
data_sample$date_hour <- as.factor(data_sample$date_hour)


# Feature Engineering: price_diff_usd = | visitor_hist_adr_usd - price_usd |

data_sample["price_diff_usd"] <- abs(visitor_hist_adr_usd - price_usd)
# data_sample$price_diff_usd <- factor(make.names(data_sample$price_diff_usd))

# Feature Engineering: star_rating_diff = | visitor_hist_adr_usd - price_usd |
data_sample["star_rating_diff"] <- abs(visitor_hist_starrating - prop_starrating)
# data_sample$star_rating_diff <- factor(make.names(data_sample$star_rating_diff))

# Feature Engineering: prop_star_rating_monotonic = | prop_starrating - mean(prop_starrating[booking_bool]) |
data_sample["prop_star_rating_monotonic"] <- abs(prop_starrating - mean(prop_starrating[booking_bool]))
# data_sample$prop_star_rating_monotonic <- factor(make.names(data_sample$prop_star_rating_monotonic))

# data_sample


# Remove the redundant column "X"
data_sample <- data_sample[-c(1,3)] 

# Write CSV in R
write.csv(data_sample, file = "sample_train_10prc_data_processed.csv") 


## Generating training and testing datasets ##

set.seed(12)


train_index <- sample(1:nrow(data_sample), 0.75*nrow(data_sample))  # row indices for training data
train_data <- data_sample[train_index, ]  # training data
test_data  <- data_sample[-train_index, ]   # test data


gbm2 <- gbm(booking_bool ~ price_diff_usd + date_day + date_month + date_hour + visitor_hist_starrating + visitor_hist_adr_usd + prop_starrating + prop_log_historical_price + 
              srch_booking_window + price_usd + srch_adults_count + srch_children_count + srch_room_count + star_rating_diff +
              comp1_rate + comp1_inv + comp1_rate_percent_diff +
              comp2_rate + comp2_inv + comp2_rate_percent_diff +
              comp3_rate + comp3_inv + comp3_rate_percent_diff +
              comp4_rate + comp4_inv + comp4_rate_percent_diff +
              comp5_rate + comp5_inv + comp5_rate_percent_diff +
              comp6_rate + comp6_inv + comp6_rate_percent_diff +
              comp7_rate + comp7_inv + comp7_rate_percent_diff +
              comp8_rate + comp8_inv + comp8_rate_percent_diff, data = train_data, n.trees = 1000, shrinkage = 0.01, interaction.depth = 4)
gbm2_pred <- predict(gbm2, test_data, n.trees = 1000) 

summary(gbm2,
        cBars=length(gbm2$var.names),
        n.trees=1000,
        plotit=TRUE,
        order=TRUE,
        method=relative.influence,
        normalize=TRUE)

actuals_preds <- data.frame(cbind(actuals = test_data$booking_bool, predicteds = gbm2_pred))  # actuals_predicteds dataframe for Cooling.Load
actuals_preds

## Calculate MSE ##

mse(actuals_preds$actuals, actuals_preds$predicteds)


## Calculate MAE ##

mae(actuals_preds$actuals, actuals_preds$predicteds)

