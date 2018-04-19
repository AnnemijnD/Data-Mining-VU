
library(rpart)
library(rpart.plot)
library(RColorBrewer)
library(randomForest)
library(party)
set.seed(415)


test = read.csv('test.csv')
train = read.csv('train.csv')

# FEATURE ENGINEERING
test$Survived <- NA
combi <- rbind(train, test)

# 1. name - retrieve title from name
combi$Name <- as.character(combi$Name) # set names as strings not feature of dataframe
combi$Title <- sapply(combi$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][2]}) #retrieve title from name
combi$Title <- sub(' ', '', combi$Title) # remove spaces
combi$Title[combi$Title %in% c('Mme', 'Mlle')] <- 'Mlle' # replace french titles
combi$Title[combi$Title %in% c('Capt', 'Don', 'Major', 'Sir')] <- 'Sir'
combi$Title[combi$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] <- 'Lady'

combi$Title <- factor(combi$Title) # set title as factor

# 2. family size
combi$FamilySize <- combi$SibSp + combi$Parch + 1

# 3. surnames
combi$Surname <- sapply(combi$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})

# 4. group by family
combi$FamilyID <- paste(as.character(combi$FamilySize), combi$Surname, sep="")
combi$FamilyID[combi$FamilySize <= 2] <- 'Small'
# 4.1 cleanup familyID - families smaller than 3
famIDs <- data.frame(table(combi$FamilyID))
famIDs <- famIDs[famIDs$Freq <= 2,]
# 4.2 clean data
combi$FamilyID[combi$FamilyID %in% famIDs$Var1] <- 'Small'
# 4.3 family as factor
combi$FamilyID <- factor(combi$FamilyID)

# predict age
Agefit <- rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title + FamilySize,
                data=combi[!is.na(combi$Age),], 
                method="anova")
combi$Age[is.na(combi$Age)] <- predict(Agefit, combi[is.na(combi$Age),])

# mark unknown embarked as Southampton
summary(combi$Embarked)
which(combi$Embarked == '')
combi$Embarked[c(62,830)] = "S"
combi$Embarked <- factor(combi$Embarked)

# set unknown fare as meadian
which(is.na(combi$Fare))
combi$Fare[1044] <- median(combi$Fare, na.rm=TRUE)

# SPLIT DATA AGAIN
train <- combi[1:891,]
test <- combi[892:1309,]

# DECISION TREE
fit <- cforest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize + FamilyID,
               data = train, controls=cforest_unbiased(ntree=2000, mtry=3)) 

#rpart.plot(fit)


# PREDICTIONS
Prediction <- predict(fit, test, OOB=TRUE, type = "response")
submit <- data.frame(PassengerId = test$PassengerId, Survived = Prediction)

# SAVE RESULTS
write.csv(submit, file = "result.csv", row.names = FALSE)

result = read.csv('result.csv')

