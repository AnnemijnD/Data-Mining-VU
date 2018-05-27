library(caret)
library(doMC)

data = read.csv("Assignment-2/feature_eng_result.csv")
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


## Generating training and testing datasets ##

set.seed(12)


train_index <- createDataPartition(data$booking_bool, p=0.75, list=FALSE)  # row indices for training data
train_data <- data[train_index, ]  # training data
test_data  <- data[-train_index, ]   # test data

## Naieve Bayes

# model click_bool
library(doMC)
registerDoMC(cores = 7)

nb_model_click = train(train_data[,-c(14,51,52,53)],
                       make.names(factor(train_data[,51])),
                       method='nb',
                       trControl=trainControl(method='cv',number=10))

saveRDS(nb_model_click, file = "Assignment-2/nb_model_click.rds")

model_pred_click <- predict(nb_model_click, train_data[,-c(14,51,52,53)], type = "prob")

train_data$prediction_click = model_pred_click$X1

# model book_bool
registerDoMC(cores = 7)

nb_model_book = train(train_data[,-c(14,51,52,53)],
                      make.names(factor(train_data[,53])),
                      method='nb',
                      trControl=trainControl(method='cv',number=10))

saveRDS(nb_model_book, file = "Assignment-2/nb_model_book.rds")

model_pred_book <- predict(nb_model_book, train_data[,-c(14,51,52,53)], type = "prob")

train_data$prediction_book = model_pred_book$X1
write.csv(train_data,"Assignment-2/nb_model_book_result.csv")

x=cbind(train_data$srch_id,
        train_data$prop_id,
        train_data$click_bool,
        train_data$booking_bool,
        train_data$prediction_click,
        train_data$prediction_book)

colnames(x) = c("srch_id", "prop_id", "click_bool","booking_bool", "prediction_click","prediction_book")

x = as.data.frame(x)
x = x[order(x$srch_id,x$prediction_book,x$prediction_click, decreasing = T),]
source("Assignment-2/src/ndcg.R")

train_ndcg = nDCG(x, ignore_null=TRUE,debug = FALSE)

save.image("Assignment-2/nb_RData")
###############################################
# predict for test data
###############################################


