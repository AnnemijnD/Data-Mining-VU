################################
#
# predict_position.R
#
# Izak de Kom
#
# Predict hotel position on 
# result page based on other
# features.
#
#
################################

library(caret)
library(doMC)

data = read.csv("Assignment-2/feature_eng_result.csv")
data$X = NULL

# training only: click_bool, gross_bookings_usd, booking_bool and position
# also remove datetime
data$date_time = NULL

# split for train/test data: 0.7/0.3
trainIndex = createDataPartition(data$position, p = .7, list = FALSE)
train = data[ trainIndex,]
test  = data[-trainIndex,]

#######################################
########### modeling
#######################################

# caret training control
control <- trainControl(method="repeatedcv",
                        #classProbs = TRUE,
                        number=10, 
                        repeats=1, 
                        savePredictions = TRUE)

gbmGrid <-  expand.grid(interaction.depth = c(3), 
                        n.trees = c(1)*1000, 
                        shrinkage = 0.1,
                        n.minobsinnode = 10)

# parallel processing
registerDoMC(cores = 7)

# gradient boosting model -> labels (position variable) is index 15
ptm = proc.time()
gbm = train(train[,-c(14,51,52,53)],train[,14], method = "gbm", trControl = control, preProcess = c("center", "scale"), tuneGrid=gbmGrid)
time = proc.time() - ptm
time

position_model = predict(gbm, data[,-c(14,51,52,53)])
save.image("RData_position_model")
saveRDS(gbm,"gbm_position.RDS")
save(position_model, file = "Assignment-2/position_feature")
