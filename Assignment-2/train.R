data_raw = read.csv('sample_train_10prc_no_missing_val.csv')

data_raw$site_id <- as.character(data_raw$site_id)
data_raw$visitor_location_country_id <- as.character(data_raw$visitor_location_country_id)
data_raw$prop_country_id <- as.character(data_raw$prop_country_id)
data_raw$prop_starrating <- as.character(data_raw$prop_starrating)
data_raw$prop_brand_bool <- as.character(data_raw$prop_brand_bool)
data_raw$promotion_flag <- as.character(data_raw$promotion_flag)
data_raw$srch_destination_id <- as.character(data_raw$srch_destination_id)
data_raw$srch_length_of_stay <- as.character(data_raw$srch_length_of_stay)
data_raw$srch_adults_count <- as.character(data_raw$srch_adults_count)
data_raw$srch_children_count <- as.character(data_raw$srch_children_count)
data_raw$srch_room_count <- as.character(data_raw$srch_room_count)
data_raw$srch_saturday_night_bool <- as.character(data_raw$srch_saturday_night_bool)
data_raw$random_bool <- as.character(data_raw$random_bool)
data_raw$comp1_rate <- as.character(data_raw$comp1_rate)
data_raw$comp1_inv <- as.character(data_raw$comp1_inv)
data_raw$comp2_rate <- as.character(data_raw$comp2_rate)
data_raw$comp2_inv <- as.character(data_raw$comp2_inv)
data_raw$comp3_rate <- as.character(data_raw$comp3_rate)
data_raw$comp3_inv <- as.character(data_raw$comp3_inv)
data_raw$comp4_rate <- as.character(data_raw$comp4_rate)
data_raw$comp4_inv <- as.character(data_raw$comp4_inv)
data_raw$comp5_rate <- as.character(data_raw$comp5_rate)
data_raw$comp5_inv <- as.character(data_raw$comp5_inv)
data_raw$comp6_rate <- as.character(data_raw$comp6_rate)
data_raw$comp6_inv <- as.character(data_raw$comp6_inv)
data_raw$comp7_rate <- as.character(data_raw$comp7_rate)
data_raw$comp7_inv <- as.character(data_raw$comp7_inv)
data_raw$comp8_rate <- as.character(data_raw$comp8_rate)
data_raw$comp8_inv <- as.character(data_raw$comp8_inv)
data_raw$click_bool <- as.character(data_raw$click_bool)
data_raw$gross_bookings_usd <- as.character(data_raw$gross_bookings_usd)
data_raw$booking_bool <- as.character(data_raw$booking_bool)

data = data_raw[1:1000,]

library('caret')
set.seed(1)


#Spliting training set into two parts based on outcome: 75% and 25%
index <- createDataPartition(data$booking_bool, p=0.75, list=FALSE)
trainSet <- data[ index,]
testSet <- data[-index,]

#Defining the training controls for multiple models
fitControl <- trainControl(
  method = "cv",
  number = 5,
  savePredictions = 'final',
  classProbs = T,
  verboseIter = TRUE)

predictors <- colnames(data)[2:52]
outcomeName <- 'booking_bool'

model_rf<-train(trainSet[,predictors],trainSet[,outcomeName],method='rf',trControl=fitControl,tuneLength=3)


testSet$pred_rf<-predict(object = model_rf,testSet[,predictors])
confusionMatrix(testSet$booking_bool,testSet$pred_rf)
