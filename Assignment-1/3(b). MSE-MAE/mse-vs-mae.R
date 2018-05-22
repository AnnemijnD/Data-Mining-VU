############################
#
# Author : Tanjina Islam
# Creation Date : 20th April, 2018
#
############################

# http://archive.ics.uci.edu/ml/datasets/Energy+efficiency#

# A. Tsanas, A. Xifara: 'Accurate quantitative estimation of energy performance of residential buildings using statistical machine learning tools', Energy and Buildings, Vol. 49, pp. 560-567, 2012 (the paper can be accessed from [Web Link]) 
# Weblink : http://people.maths.ox.ac.uk/tsanas/publications.html

library(multcomp)
library(lme4)
# install.packages("Metrics")
library(Metrics) # For MSE and MAE
library(caret)
# install.packages('randomForest')
library(randomForest)


energy_efficiency = read.csv("Energy_efficiency.csv")
energy_efficiency
attach(energy_efficiency)

round(cor(energy_efficiency$Overall.Height, energy_efficiency$Relative.Compactness),2) # to check co-relation

energy_efficiency$Relative.Compactness = as.factor(energy_efficiency$Relative.Compactness)
energy_efficiency$Surface.Area = as.factor(energy_efficiency$Surface.Area)
energy_efficiency$Wall.Area = as.factor(energy_efficiency$Wall.Area)
energy_efficiency$Roof.Area = as.factor(energy_efficiency$Roof.Area)
energy_efficiency$Overall.Height = as.factor(energy_efficiency$Overall.Height)
energy_efficiency$Orientation = as.factor(energy_efficiency$Orientation)
energy_efficiency$Glazing.Area = as.factor(energy_efficiency$Glazing.Area)
energy_efficiency$Glazing.Area.Distribution = as.factor(energy_efficiency$Glazing.Area.Distribution)


energy_efficiency_lm = lm(Heating.Load ~ Relative.Compactness + Surface.Area + Wall.Area + Roof.Area + Overall.Height + Orientation + Glazing.Area + Glazing.Area.Distribution, data = energy_efficiency)
alias(energy_efficiency_lm)
summary(energy_efficiency_lm)$coefficients
print(energy_efficiency_lm)



## Generating training and testing datasets ##

set.seed(12358)


train_index <- sample(1:nrow(energy_efficiency), 0.8*nrow(energy_efficiency))  # row indices for training data
energy_train_data <- energy_efficiency[train_index, ]  # training data
energy_test_data  <- energy_efficiency[-train_index, ]   # test data

# Building linear model on training data #

# Since Roof.area is negatively co-related with Overall.Height with [-0.97]. And,since  we can’t have 2 collinear variables in the same model.
# Surface.area is negatively co-related with Relative.Compactness with [-0.99]
# Relative.Compactness is positively co-related with Overall.Height with [0.83]

# We will remove Roof.area, Surface.area, Relative.Compactness from the model
# Since, Glazing.Area.Distribution gave us "NA" I omitted it while fitting the model. but I'm not sure


# build the model
energy_efficiency_lm1 <- lm(Heating.Load ~ Wall.Area + Overall.Height + Orientation + Glazing.Area , data = energy_train_data)

heat_load_pred <- predict(energy_efficiency_lm1, energy_test_data)  # predict Heating Load

summary(energy_efficiency_lm1)

# build the model
energy_efficiency_lm2 <- lm(Cooling.Load ~  Wall.Area + Overall.Height + Orientation + Glazing.Area, data = energy_train_data)

cool_load_pred <- predict(energy_efficiency_lm2, energy_test_data)  # predict Cooling Load

summary(energy_efficiency_lm2)

# For energy_efficiency_lm1 : Heating.Load
actuals_preds <- data.frame(cbind(actuals = energy_test_data$Heating.Load, predicteds = heat_load_pred))  # actuals_predicteds dataframe Heating.Load
print(actuals_preds)

## Calculate MSE ##

mse(actuals_preds$actuals, actuals_preds$predicteds)

#rmse(actuals_preds$actuals, actuals_preds$predicteds)

## Calculate MAE ##

mae(actuals_preds$actuals, actuals_preds$predicteds)

# For linear model 1 (Heating.load) MSE = 4.82079 and MAE = 1.715016, which is comparitively lower than MSE.

## For energy_efficiency_lm2 : Cooling.Load ##

actuals_preds <- data.frame(cbind(actuals = energy_test_data$Cooling.Load, predicteds = cool_load_pred))  # actuals_predicteds dataframe for Cooling.Load


print(actuals_preds)

## Calculate MSE ##

mse(actuals_preds$actuals, actuals_preds$predicteds)


## Calculate MAE ##

mae(actuals_preds$actuals, actuals_preds$predicteds)

# For linear model 2 (Cooling.Load) MSE = 6.253551 and MAE = 1.830472, which is comparitively lower than MSE.
# And if we compare those with model 1 then we can even see both MSE and MAE gave higher error rate for model 2.

### Linear Model using all variables ###

# build the model
energy_efficiency_lm3 <- lm(Heating.Load ~ Relative.Compactness + Surface.Area +  Wall.Area + Roof.Area + Overall.Height + Orientation + Glazing.Area + Glazing.Area.Distribution , data = energy_train_data)

heat_load_pred <- predict(energy_efficiency_lm3, energy_test_data)  # predict Heating Load

summary(energy_efficiency_lm3)

# For energy_efficiency_lm3 : Heating.Load
actuals_preds <- data.frame(cbind(actuals = energy_test_data$Heating.Load, predicteds = heat_load_pred))  # actuals_predicteds dataframe Heating.Load
print(actuals_preds)

## Calculate MSE ##

mse(actuals_preds$actuals, actuals_preds$predicteds)

#rmse(actuals_preds$actuals, actuals_preds$predicteds)

## Calculate MAE ##

mae(actuals_preds$actuals, actuals_preds$predicteds)

# For linear model 3 (Heating.load) MSE = 1.293777 and MAE = 0.8284892, which is comparitively lower than MSE.

# build the model
energy_efficiency_lm4 <- lm(Cooling.Load ~ Relative.Compactness + Surface.Area +  Wall.Area + Roof.Area + Overall.Height + Orientation + Glazing.Area + Glazing.Area.Distribution, data = energy_train_data)

cool_load_pred <- predict(energy_efficiency_lm4, energy_test_data)  # predict Cooling Load

summary(energy_efficiency_lm4)

## For energy_efficiency_lm4 : Cooling.Load ##

actuals_preds <- data.frame(cbind(actuals = energy_test_data$Cooling.Load, predicteds = cool_load_pred))  # actuals_predicteds dataframe for Cooling.Load


print(actuals_preds)

## Calculate MSE ##

mse(actuals_preds$actuals, actuals_preds$predicteds)

## Calculate MAE ##

mae(actuals_preds$actuals, actuals_preds$predicteds)

# For linear model 4 (Cooling.load) MSE = 3.394541 and MAE = 1.366495, which is comparitively lower than MSE.


########################################


## Set up a model matrix for Tree Regression ##


library(rpart)

rt1 <- rpart(Heating.Load ~ Relative.Compactness + Surface.Area + Wall.Area + Roof.Area + Overall.Height + Orientation + Glazing.Area + Glazing.Area.Distribution, data = energy_train_data)
rt1_pred <- predict(rt1, energy_test_data) 
summary(rt1)

## For rt1 : Heating.Load ##

actuals_preds <- data.frame(cbind(actuals = energy_test_data$Heating.Load, predicteds = rt1_pred))  # actuals_predicteds dataframe for Heating.Load
actuals_preds

## Calculate MSE ##

mse(actuals_preds$actuals, actuals_preds$predicteds)


## Calculate MAE ##

mae(actuals_preds$actuals, actuals_preds$predicteds)

## Using Regression Tree model(rt1) as outcome, Heating.Load MSE = 6.590418 and MAE = 2.100943

## For rt2 : Cooling.Load ##

rt2 <- rpart(Cooling.Load ~ Relative.Compactness + Surface.Area + Wall.Area + Roof.Area + Overall.Height + Orientation + Glazing.Area + Glazing.Area.Distribution, data = energy_train_data)
rt2_pred <- predict(rt2, energy_test_data) 
summary(rt2)

actuals_preds <- data.frame(cbind(actuals = energy_test_data$Cooling.Load, predicteds = rt2_pred))  # actuals_predicteds dataframe for Cooling.Load
actuals_preds

## Calculate MSE ##

mse(actuals_preds$actuals, actuals_preds$predicteds)


## Calculate MAE ##

mae(actuals_preds$actuals, actuals_preds$predicteds)

## Using Regression Tree model(rt2) as outcome, Cooling.Load MSE = 8.46072 and MAE = 2.08415

### 
set.seed(12358)

rf1 <- randomForest(Heating.Load ~ Relative.Compactness + Surface.Area + Wall.Area + Roof.Area + Overall.Height + Orientation + Glazing.Area + Glazing.Area.Distribution, data = energy_train_data, importance = TRUE, ntree=1000)
rf1_pred <- predict(rf1, energy_test_data) 

summary(rf1)

actuals_preds <- data.frame(cbind(actuals = energy_test_data$Heating.Load, predicteds = rf1_pred))  # actuals_predicteds dataframe for Heating.Load
actuals_preds

# Using the importance()  function to calculate the importance of each variable
imp <- as.data.frame(sort(importance(rf1)[,1],decreasing = TRUE),optional = T)
names(imp) <- "% Inc MSE"
imp

## Calculate MSE ##

mse(actuals_preds$actuals, actuals_preds$predicteds)


## Calculate MAE ##

mae(actuals_preds$actuals, actuals_preds$predicteds)

## Using Regression Forest model(rf1) as outcome, Heating.Load MSE = 1.359643 and MAE = 0.9065152
## The Glazing.Area was considered the most important predictor; it is estimated that, in the absence of that variable, the error would increase by 72.35424%. 

set.seed(12358)

rf2 <- randomForest(Cooling.Load ~ Relative.Compactness + Surface.Area + Wall.Area + Roof.Area + Overall.Height + Orientation + Glazing.Area + Glazing.Area.Distribution, data = energy_train_data, importance = TRUE, ntree=1000)
rf2_pred <- predict(rf2, energy_test_data) 

summary(rf2)

actuals_preds <- data.frame(cbind(actuals = energy_test_data$Cooling.Load, predicteds = rf2_pred))  # actuals_predicteds dataframe for Cooling.Load
actuals_preds

# Using the importance()  function to calculate the importance of each variable
imp <- as.data.frame(sort(importance(rf2)[,1],decreasing = TRUE),optional = T)
names(imp) <- "% Inc MSE"
imp

## Calculate MSE ##

mse(actuals_preds$actuals, actuals_preds$predicteds)


## Calculate MAE ##

mae(actuals_preds$actuals, actuals_preds$predicteds)

## Using Regression Forest model(rf2) as outcome, Heating.Load MSE = 3.698156 and MAE = 1.348301
## The Glazing.Area was considered the most important predictor; it is estimated that, in the absence of that variable, the error would increase by 75.251132%.