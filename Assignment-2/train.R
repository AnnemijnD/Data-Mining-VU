data_raw = read.csv('sample_train_10prc_no_missing_val.csv')


# Feature Engineering: DateTime
data_raw$date_time <- as.character(data_raw$date_time)
data_raw$date_day <- sapply(data_raw$date_time, FUN=function(x) {strsplit(x, split='[- :]')[[1]][3]})
data_raw$date_month <- sapply(data_raw$date_time, FUN=function(x) {strsplit(x, split='[- :]')[[1]][2]})
data_raw$date_hour <- sapply(data_raw$date_time, FUN=function(x) {strsplit(x, split='[- :]')[[1]][4]})
data_raw$date_day <- factor(make.names(data_raw$date_day))
data_raw$date_month <- factor(make.names(data_raw$date_month))
data_raw$date_hour <- factor(make.names(data_raw$date_hour))

# Feature Engineering: 

# Prepare factors
data_raw$site_id <- factor(make.names(data_raw$site_id))
#data_raw$visitor_location_country_id <- factor(make.names(data_raw$visitor_location_country_id))
#data_raw$prop_country_id <- factor(make.names(data_raw$prop_country_id))
data_raw$prop_starrating <- factor(make.names(data_raw$prop_starrating))
data_raw$prop_brand_bool <- factor(make.names(data_raw$prop_brand_bool))
data_raw$promotion_flag <- factor(make.names(data_raw$promotion_flag))
#data_raw$srch_destination_id <- factor(make.names(data_raw$srch_destination_id))
data_raw$srch_length_of_stay <- factor(make.names(data_raw$srch_length_of_stay))
data_raw$srch_adults_count <- factor(make.names(data_raw$srch_adults_count))
data_raw$srch_children_count <- factor(make.names(data_raw$srch_children_count))
data_raw$srch_room_count <- factor(make.names(data_raw$srch_room_count))
data_raw$srch_saturday_night_bool <- factor(make.names(data_raw$srch_saturday_night_bool))
data_raw$random_bool <- factor(make.names(data_raw$random_bool))
data_raw$comp1_rate <- factor(make.names(data_raw$comp1_rate))
data_raw$comp1_inv <- factor(make.names(data_raw$comp1_inv))
data_raw$comp2_rate <- factor(make.names(data_raw$comp2_rate))
data_raw$comp2_inv <- factor(make.names(data_raw$comp2_inv))
data_raw$comp3_rate <- factor(make.names(data_raw$comp3_rate))
data_raw$comp3_inv <- factor(make.names(data_raw$comp3_inv))
data_raw$comp4_rate <- factor(make.names(data_raw$comp4_rate))
data_raw$comp4_inv <- factor(make.names(data_raw$comp4_inv))
data_raw$comp5_rate <- factor(make.names(data_raw$comp5_rate))
data_raw$comp5_inv <- factor(make.names(data_raw$comp5_inv))
data_raw$comp6_rate <- factor(make.names(data_raw$comp6_rate))
data_raw$comp6_inv <- factor(make.names(data_raw$comp6_inv))
data_raw$comp7_rate <- factor(make.names(data_raw$comp7_rate))
data_raw$comp7_inv <- factor(make.names(data_raw$comp7_inv))
data_raw$comp8_rate <- factor(make.names(data_raw$comp8_rate))
data_raw$comp8_inv <- factor(make.names(data_raw$comp8_inv))
data_raw$click_bool <- factor(make.names(data_raw$click_bool))
data_raw$booking_bool <- factor(make.names(data_raw$booking_bool))

data = data_raw[1:100000,]

library('caret')
set.seed(1)


#Spliting training set into two parts based on outcome: 75% and 25%
trainSet <- data[1:7500,]
testSet <- data[7501:10000,]

#Defining the training controls for multiple models
fitControl <- trainControl(
  method = "cv",
  number = 5,
  savePredictions = 'final',
  classProbs = T,
  verboseIter = TRUE)

predictors <- c("date_day",
                "date_month",
                "date_hour",
                "prop_location_score2",
                "srch_destination_id",
                "price_usd",
                "srch_booking_window",
                "prop_log_historical_price",
                "site_id",
                "comp1_rate",
                "comp1_inv",
                "comp1_rate_percent_diff",
                "comp2_rate",
                "comp2_inv",
                "comp2_rate_percent_diff",
                "comp3_rate",
                "comp3_inv",
                "comp3_rate_percent_diff",
                "comp4_rate",
                "comp4_inv",
                "comp4_rate_percent_diff",
                "comp5_rate",
                "comp5_inv",
                "comp5_rate_percent_diff",
                "comp6_rate",
                "comp6_inv",
                "comp6_rate_percent_diff",
                "comp7_rate",
                "comp7_inv",
                "comp7_rate_percent_diff",
                "comp8_rate",
                "comp8_inv",
                "comp8_rate_percent_diff")
outcomeName <- 'booking_bool'

model_rf<-train(trainSet[,predictors],trainSet[,outcomeName],method='rf',trControl=fitControl,tuneLength=3)

importance <- varImp(model_rf, scale=FALSE)
plot(importance)

testSet$pred_rf<-predict(object = model_rf,testSet[,predictors])
confusionMatrix(testSet$booking_bool,testSet$pred_rf)