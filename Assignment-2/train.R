data = read.csv('sample_train_10prc_feature_eng.csv')

# Prepare factors
data$site_id <- factor(make.names(data$site_id))
#data$visitor_location_country_id <- factor(make.names(data$visitor_location_country_id))
#data$prop_country_id <- factor(make.names(data$prop_country_id))
#data$prop_starrating <- factor(make.names(data$prop_starrating))
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
data$click_bool <- factor(make.names(data$click_bool))
data$booking_bool <- factor(make.names(data$booking_bool))

# engineered features
data$date_day <- factor(make.names(data$date_day))
data$date_month <- factor(make.names(data$date_month))
data$date_hour <- factor(make.names(data$date_hour))
data$children_flag <- factor(make.names(data$children_flag))


# TRAIN

library('caret')
set.seed(1)


#Spliting training set into two parts based on outcome: 75% and 25%
index <- createDataPartition(data$booking_bool, p=0.75, list=FALSE)
trainSet <- data[ index,]
testSet <- data[-index,]

#Defining the training controls for multiple models
fitControl <- trainControl(
  method = "cv",
  number = 1,
  savePredictions = 'final',
  classProbs = T,
  verboseIter = TRUE)

predictors <- c(#"X",
                #"srch_id",
                #"date_time",
                "site_id",
                #"visitor_location_country_id",
                "visitor_hist_starrating",
                "visitor_hist_adr_usd",
                #"prop_country_id",
                #"prop_id",
                "prop_starrating",
                "prop_review_score",
                "prop_brand_bool",
                "prop_location_score1",
                "prop_location_score2",
                "prop_log_historical_price",
                #"position",
                "price_usd",
                "promotion_flag",
                #"srch_destination_id",
                "srch_length_of_stay",
                "srch_booking_window",
                "srch_adults_count",
                "srch_children_count",
                "srch_room_count",
                "srch_saturday_night_bool",
                "srch_query_affinity_score",
                "orig_destination_distance",
                "random_bool",
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
                "comp8_rate_percent_diff",
                "click_bool",
                "gross_bookings_usd",
                "booking_bool",
                "date_day",
                "date_month",
                "date_hour",
                "children_flag",
                "price_diff_usd",
                "star_rating_diff",
                "prop_star_rating_monotonic",
                "window_count",
                "adult_child_count",
                "ump",
                "fee_per_person",
                "total_fee",
                "score2ma",
                "score1d2")
outcomeName <- 'booking_bool'

#Training the Logistic regression model
model_lr<-train(trainSet[,predictors],trainSet[,outcomeName],method='rf',trControl=fitControl,tuneLength=3)

importance <- varImp(model_knn, scale=FALSE)
plot(importance)

#Predicting using knn model
testSet$pred_knn<-predict(object = model_knn,testSet[,predictors])

#Checking the accuracy of the random forest model
confusionMatrix(testSet$Loan_Status,testSet$pred_knn)