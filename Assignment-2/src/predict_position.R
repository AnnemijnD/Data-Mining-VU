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

data = read.csv("Assignment-2/sample_train_10prc_feature_eng.csv")
data$X = NULL

# training only: click_bool, gross_bookings_usd, booking_bool and position
# also remove datetime
data$date_time = NULL
#data$click_bool = NULL
#data$gross_bookings_usd = NULL
#data$booking_bool = NULL

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
                        repeats=3, 
                        savePredictions = TRUE)

gbmGrid <-  expand.grid(interaction.depth = c(3), 
                        n.trees = c(1)*1000, 
                        shrinkage = 0.1,
                        n.minobsinnode = 10)

# parallel processing
registerDoMC(cores = 3)

# gradient boosting model -> labels (position variable) is index 15
ptm = proc.time()
gbm = train(train[,-c(14,51,52,53)],train[,14], method = "gbm", trControl = control, preProcess = c("center", "scale"), tuneGrid=gbmGrid)
time = proc.time() - ptm
time

###################################
# position_model feature importance
###################################
# gbm_position = gbm
# train$position_model = predict(gbm_position, train[,-c(14,51,52,53)])
# 
# registerDoMC(cores = 3)
# control <- trainControl(method="repeatedcv",
#                         number=10,
#                         repeats=1)
# 
# glmnet = train(train[,-c(14,51,52,53)],train[,53], method = "glmnet", trControl = control, preProcess = c("center", "scale"))
# glmnetVarImp = varImp(glmnet)[[1]]
# glmnetVarImp = glmnetVarImp[order(glmnetVarImp$Overall,decreasing = T),,drop=F]

##########################################
# predict final feature position_model
##########################################

position_model = predict(gbm, data[,-c(14,51,52,53)])
save.image("RData_position_model")
saveRDS(gbm,"gbm_position.RDS")
save(position_model, file = "Assignment-2/position_feature")
