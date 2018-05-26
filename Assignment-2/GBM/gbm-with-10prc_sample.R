############################
#
# Author : Tanjina Islam
# Creation Date : 16th May, 2018
#
############################
library(klaR)
library(caret)
library(gbm)
library(multcomp)
library(lme4)
library(Metrics) # For MSE and MAE
library(e1071)
library(naivebayes)

require(gbm)
require(dplyr)
# library for parellel processing
library(doParallel)

# To create a local 4-node snow cluster

num_of_cluster <- makeCluster(detectCores(), type = "SOCK")
registerDoParallel(num_of_cluster)  # For linux/mac use library(doMC) and registerDoMC(cores = 4)

# Print process Ids

foreach(i=1:length(num_of_cluster)) %dopar% Sys.getpid()

data = read.csv("feature_eng_result.csv")

attach(data)
# data

# Remove the redundant column "X"
data <- data[-c(1,3)] 

# Prepare factors
data$site_id <- factor(make.names(data$site_id))
#data$visitor_location_country_id <- factor(make.names(data$visitor_location_country_id))
#data$prop_country_id <- factor(make.names(data$prop_country_id))
data$prop_starrating <- factor(make.names(data$prop_starrating))
data$prop_brand_bool <- factor(make.names(data$prop_brand_bool))
data$promotion_flag <- factor(make.names(data$promotion_flag))
#data$srch_destination_id <- factor(make.names(data$srch_destination_id))
#data$srch_length_of_stay <- factor(make.names(data$srch_length_of_stay))
#data$srch_adults_count <- factor(make.names(data$srch_adults_count))
#data$srch_children_count <- factor(make.names(data$srch_children_count))
#data$srch_room_count <- factor(make.names(data$srch_room_count))
data$srch_saturday_night_bool <- factor(make.names(data$srch_saturday_night_bool))
data$random_bool <- factor(make.names(data$random_bool))
data$comp1_rate <- factor(make.names(data$comp1_rate))
data$comp1_inv <- factor(make.names(data$comp1_inv))
data$comp2_rate <- factor(make.names(data$comp2_rate))
data$comp2_inv <- factor(make.names(data$comp2_inv))
data$comp3_rate <- factor(make.names(data$comp3_rate))
data$comp3_inv <- factor(make.names(data$comp3_inv))
data$comp4_rate <- factor(make.names(data$comp4_rate))
data$comp4_inv <- factor(make.names(data$comp4_inv))
data$comp5_rate <- factor(make.names(data$comp5_rate))
data$comp5_inv <- factor(make.names(data$comp5_inv))
data$comp6_rate <- factor(make.names(data$comp6_rate))
data$comp6_inv <- factor(make.names(data$comp6_inv))
data$comp7_rate <- factor(make.names(data$comp7_rate))
data$comp7_inv <- factor(make.names(data$comp7_inv))
data$comp8_rate <- factor(make.names(data$comp8_rate))
data$comp8_inv <- factor(make.names(data$comp8_inv))
#data$click_bool <- factor(make.names(data$click_bool))
#data$booking_bool <- factor(make.names(data$booking_bool))

# engineered features
data$date_day <- factor(make.names(data$date_day))
data$date_month <- factor(make.names(data$date_month))
data$date_hour <- factor(make.names(data$date_hour))
data$children_flag <- factor(make.names(data$children_flag))
data$prop_star_rating_monotonic <- factor(make.names(data$prop_star_rating_monotonic))


## Generating training and testing datasets ##

set.seed(12)


train_index <- createDataPartition(data$booking_bool, p=0.75, list=FALSE)  # row indices for training data
train_data <- data[train_index, ]  # training data
test_data  <- data[-train_index, ]   # test data


gbm_model_booking <- gbm(booking_bool ~ prop_location_score2 + prop_location_score1 + ump + price_diff_usd + star_rating_diff + score1d2 + random_bool +
                   fee_per_person + price_usd + score2ma + prop_review_score + total_fee + orig_destination_distance + 
                   adult_child_count + window_count + prop_star_rating_monotonic + children_flag + 
                   date_day + date_month + date_hour + visitor_hist_starrating + visitor_hist_adr_usd + prop_starrating + prop_log_historical_price + 
                   srch_booking_window + srch_adults_count + srch_children_count + srch_room_count +
                   comp1_rate + comp1_inv + comp1_rate_percent_diff +
                   comp2_rate + comp2_inv + comp2_rate_percent_diff +
                   comp3_rate + comp3_inv + comp3_rate_percent_diff +
                   comp4_rate + comp4_inv + comp4_rate_percent_diff +
                   comp5_rate + comp5_inv + comp5_rate_percent_diff +
                   comp6_rate + comp6_inv + comp6_rate_percent_diff +
                   comp7_rate + comp7_inv + comp7_rate_percent_diff +
                   comp8_rate + comp8_inv + comp8_rate_percent_diff, distribution = "bernoulli", data = train_data, n.trees = 1000, shrinkage = 0.01, interaction.depth = 4, verbose = FALSE)

gbm_model_booking

saveRDS(gbm_model_booking, file = "GBM/gbm_model_booking.rds")

gbm_pred_booking <- predict(gbm_model_booking, test_data, n.trees = 1000, type = "response") 

gbm_pred_booking

confusionMatrix(gbm_pred_booking, as.factor(test_data$booking_bool))

summary(gbm_model_booking,
        cBars=length(gbm_model_booking$var.names),
        n.trees=1000,
        plotit=TRUE,
        order=TRUE,
        method=relative.influence,
        normalize=TRUE)

actuals_preds_booking <- data.frame(cbind(actuals = test_data$booking_bool, predicteds = gbm_pred_booking))  # actuals_predicteds dataframe for booking_bool
actuals_preds_booking

## Calculate MSE ##

mse(actuals_preds_booking$actuals, actuals_preds_booking$predicteds)


## Calculate MAE ##

mae(actuals_preds_booking$actuals, actuals_preds_booking$predicteds)

#### FOR CLICK BOOL ####

gbm_model_click <- gbm(as.factor(click_bool) ~ prop_location_score2 + prop_location_score1 + ump + price_diff_usd + star_rating_diff + score1d2 + random_bool +
                   fee_per_person + price_usd + score2ma + prop_review_score + total_fee + orig_destination_distance + 
                   adult_child_count + window_count + prop_star_rating_monotonic + children_flag + 
                   date_day + date_month + date_hour + visitor_hist_starrating + visitor_hist_adr_usd + prop_starrating + prop_log_historical_price + 
                   srch_booking_window + srch_adults_count + srch_children_count + srch_room_count +
                   comp1_rate + comp1_inv + comp1_rate_percent_diff +
                   comp2_rate + comp2_inv + comp2_rate_percent_diff +
                   comp3_rate + comp3_inv + comp3_rate_percent_diff +
                   comp4_rate + comp4_inv + comp4_rate_percent_diff +
                   comp5_rate + comp5_inv + comp5_rate_percent_diff +
                   comp6_rate + comp6_inv + comp6_rate_percent_diff +
                   comp7_rate + comp7_inv + comp7_rate_percent_diff +
                   comp8_rate + comp8_inv + comp8_rate_percent_diff, data = train_data, n.trees = 1000, shrinkage = 0.01, interaction.depth = 4, verbose = FALSE)

gbm_model_click
saveRDS(gbm_model_click, file = "GBM/gbm_model_click.rds")

gbm_pred_click <- predict(gbm_model_click, test_data, n.trees = 1000) 
gbm_pred_click

confusionMatrix(gbm_pred_click, as.factor(test_data$click_bool))

summary(gbm_model_click,
        cBars=length(gbm_model_click$var.names),
        n.trees=1000,
        plotit=TRUE,
        order=TRUE,
        method=relative.influence,
        normalize=TRUE)

actuals_preds_click <- data.frame(cbind(actuals = test_data$click_bool, predicteds = gbm_pred_click))  # actuals_predicteds dataframe for click_bool
actuals_preds_click

## Calculate MSE ##

mse(actuals_preds_click$actuals, actuals_preds_click$predicteds)


## Calculate MAE ##

mae(actuals_preds_click$actuals, actuals_preds_click$predicteds)


## Naieve Bayes

# use booking_bool as a factor

library(e1071)
model = train(as.factor(booking_bool) ~ prop_location_score2 + prop_location_score1 + ump + price_diff_usd + star_rating_diff + score1d2 + random_bool +
                fee_per_person + price_usd + score2ma + prop_review_score + total_fee + orig_destination_distance + 
                adult_child_count + window_count + prop_star_rating_monotonic + children_flag + 
                date_day + date_month + date_hour + visitor_hist_starrating + visitor_hist_adr_usd + prop_starrating + prop_log_historical_price + 
                srch_booking_window + srch_adults_count + srch_children_count + srch_room_count +
                comp1_rate + comp1_inv + comp1_rate_percent_diff +
                comp2_rate + comp2_inv + comp2_rate_percent_diff +
                comp3_rate + comp3_inv + comp3_rate_percent_diff +
                comp4_rate + comp4_inv + comp4_rate_percent_diff +
                comp5_rate + comp5_inv + comp5_rate_percent_diff +
                comp6_rate + comp6_inv + comp6_rate_percent_diff +
                comp7_rate + comp7_inv + comp7_rate_percent_diff +
                comp8_rate + comp8_inv + comp8_rate_percent_diff, data = train_data,'nb',trControl=trainControl(method='cv',number=10))

model

saveRDS(model, file = "nb_model_booking.rds")

model_pred <- predict(model, test_data, type = "prob")
model_pred
confusionMatrix(model_pred, as.factor(test_data$booking_bool))
