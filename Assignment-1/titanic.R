library(caret)
library(doMC)
# parallel processing: set number of cores
registerDoMC(cores = 4)

# load data
data = read.csv('assignments/Data-Mining-VU/Assignment-1/2. Titanic/train.csv')

# exclude samples with NA's
data = na.exclude(data)

# maybe exclude ID, Name, Ticket and Cabin...
data = data[-c(1,4,9,11)]
data$Survived = as.factor(data$Survived)

# split for train/test data
trainIndex = createDataPartition(data$Survived, p = .7, list = FALSE)
train = data[ trainIndex,]
test  = data[-trainIndex,]

# caret machine learning control: number of cross validation folds and repeats
control = trainControl(method="repeatedcv", number=10, repeats=2)

# train the classifiers
# generalized boosted model: https://en.wikipedia.org/wiki/Gradient_boosting
gbm = train(train[-1],train[,1], method = "gbm", trControl = control)
gbm_result = confusionMatrix(predict(gbm,test),test$Survived)

# ranfom forest model: https://en.wikipedia.org/wiki/Random_forest
rf = train(train[-1],train[,1], method = "rf", trControl = control)
rf_result = confusionMatrix(predict(rf,test),test$Survived)