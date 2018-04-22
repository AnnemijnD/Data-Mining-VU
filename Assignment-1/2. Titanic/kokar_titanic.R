train <- read.csv("train.csv")
test <- read.csv("test.csv")
library(caret)
# Install and load required packages for decision trees and forests
library(rpart)
# install.packages('randomForest')
library(randomForest)
# install.packages('party')
library(party)

library(doMC)
# parallel processing: set number of cores
registerDoMC(cores = 4)

# Join together the test and train sets for easier feature engineering
test$Survived <- NA
combi <- rbind(train, test)

# Convert to a string
combi$Name <- as.character(combi$Name)

# Engineered variable: Title
combi$Title <- sapply(combi$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][2]})
combi$Title <- sub(' ', '', combi$Title)
# Combine small title groups
combi$Title[combi$Title %in% c('Mme', 'Mlle')] <- 'Mlle'
combi$Title[combi$Title %in% c('Capt', 'Don', 'Major', 'Sir')] <- 'Sir'
combi$Title[combi$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] <- 'Lady'
# Convert to a factor
combi$Title <- factor(combi$Title)

# Engineered variable: Family size
combi$FamilySize <- combi$SibSp + combi$Parch + 1

# Engineered variable: Family
combi$Surname <- sapply(combi$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
combi$FamilyID <- paste(as.character(combi$FamilySize), combi$Surname, sep="")
combi$FamilyID[combi$FamilySize <= 2] <- 'Small'
# Delete erroneous family IDs
famIDs <- data.frame(table(combi$FamilyID))
famIDs <- famIDs[famIDs$Freq <= 2,]
combi$FamilyID[combi$FamilyID %in% famIDs$Var1] <- 'Small'
# Convert to a factor
combi$FamilyID <- factor(combi$FamilyID)

# Fill in Age NAs
summary(combi$Age)
Agefit <- rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title + FamilySize, 
                data=combi[!is.na(combi$Age),], method="anova")
combi$Age[is.na(combi$Age)] <- predict(Agefit, combi[is.na(combi$Age),])
# Check what else might be missing
summary(combi)
# Fill in Embarked blanks
summary(combi$Embarked)
which(combi$Embarked == '')
combi$Embarked[c(62,830)] = "S"
combi$Embarked <- factor(combi$Embarked)
# Fill in Fare NAs
summary(combi$Fare)
which(is.na(combi$Fare))
combi$Fare[1044] <- median(combi$Fare, na.rm=TRUE)

# Set deck by cabin
combi$Cabin <- as.character(combi$Cabin)
combi$Deck <- sapply(combi$Cabin, FUN=function(x) {
    if(x == '') {
      'U'
    } else {
      substring(x, 1, 1)
    }
})
combi$Deck <- factor(combi$Deck)

# Set ticket types
combi$Ticket <- as.character(combi$Ticket)
combi$TicketType <- sapply(combi$Ticket, FUN=function(x) {
  temp = strsplit(x, split=' ')[[1]][1]
  if(is.na(as.numeric(temp))) {
    temp
  } else {
    'num'
  }
})
combi$TicketType <- factor(combi$TicketType)

# Split back into test and train sets
train <- combi[1:891,]
test <- combi[892:1309,]

# Build condition inference tree Random Forest
set.seed(415)
fit <- cforest(as.factor(Survived) ~ Pclass + TicketType + Sex + Deck + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize + FamilyID,
               data = train, controls=cforest_unbiased(ntree=2000, mtry=3)) 

# RESULT
Prediction <- predict(fit, test, OOB=TRUE, type = "response")
submit <- data.frame(PassengerId = test$PassengerId, Survived = Prediction)
write.csv(submit, file = "ciforest.csv", row.names = FALSE)


# evaluation
# split for train/test data
trainIndex = createDataPartition(train$Survived, p = .7, list = FALSE)
eval_train = train[ trainIndex,]

eval_trainTMP <- NULL
eval_trainTMP$Survived <- eval_train$Survived
eval_trainTMP$Pclass <- eval_train$Pclass
eval_trainTMP$TicketType <- eval_train$TicketType
eval_trainTMP$Sex <- eval_train$Sex
eval_trainTMP$Deck <- eval_train$Deck
eval_trainTMP$Age <- eval_train$Age
eval_trainTMP$SibSp <- eval_train$SibSp
eval_trainTMP$Parch <- eval_train$Parch
eval_trainTMP$Fare <- eval_train$Fare
eval_trainTMP$Embarked <- eval_train$Embarked
eval_trainTMP$Title <- eval_train$Title
eval_trainTMP$FamilySize <- eval_train$FamilySize
eval_trainTMP$FamilyID <- eval_train$FamilyID

eval_train <- NULL
eval_train <- eval_trainTMP

eval_test  = train[-trainIndex,]
eval_act <- factor(eval_test$Survived)

set.seed(415)
fit_cf <- cforest(as.factor(Survived) ~ Pclass + TicketType + Sex + Deck + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize + FamilyID,
               data = eval_train, controls=cforest_unbiased(ntree=2000, mtry=3)) 
pred_cf <- predict(fit_cf, eval_test, OOB=TRUE, type = "response")

library(caret)
caret::confusionMatrix(pred_cf, eval_act, positive="1", mode="everything")

trainControl <- trainControl(method="repeatedcv", number=10, repeats=3)
metric <- "Accuracy"
eval_train <- as.data.frame(unclass(eval_train))
fit_nb <- train(as.factor(Survived)~., data=eval_train, method="knn", metric=metric, trControl=trainControl)
blelbe <- predict(fit_nb,eval_test)
caret::confusionMatrix(predict(fit_nb,eval_test),eval_act, positive="1", mode="everything")
