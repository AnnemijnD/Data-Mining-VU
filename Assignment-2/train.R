data_raw = read.csv('sample_train_10prc_no_missing_val.csv')

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

data = data_raw[1:10000,]

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

predictors <- c("prop_location_score2","date_time","srch_destination_id","price_usd","srch_booking_window","prop_log_historical_price","site_id")
outcomeName <- 'booking_bool'

model_rf<-train(trainSet[,predictors],trainSet[,outcomeName],method='rf',trControl=fitControl,tuneLength=3)

importance <- varImp(model_rf, scale=FALSE)
plot(importance)

testSet$pred_rf<-predict(object = model_rf,testSet[,predictors])
confusionMatrix(testSet$booking_bool,testSet$pred_rf)


library('FSelector')
res <- gain.ratio(g~., data)