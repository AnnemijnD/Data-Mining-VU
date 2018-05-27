#Import libraries:
import sys
import math
import pickle
import pandas as pd
import numpy as np

################################################
# test gbm on all test data
################################################

# read data
test = pd.read_csv('../test_preproc_feature_eng_position.csv')
test = test[:-4500000]
# read models
# gbm click
with open("../rf_click.sav", 'rb') as file:
    rf_click = pickle.load(file)
# gbm book
with open("../rf_book.sav", 'rb') as file:
    rf_book = pickle.load(file)

# predict click
predictors = list(test.columns.values.tolist())
predictors.remove('Unnamed: 0')
predictors.remove('date_time')

click_prob = rf_click.predict_proba(test[predictors])
test["prediction_click"] = pd.Series(click_prob[:,1])

# predict book
predictors = list(test.columns.values.tolist())
predictors.remove('Unnamed: 0')
predictors.remove('date_time')

book_prob = rf_book.predict_proba(test[predictors])[:, 1]
test["prediction_book"] = pd.Series(book_prob)

# save prediction
result = test.ix[:, ['srch_id', 'prop_id','prediction_book','prediction_click']]
result.to_csv('../results/rf_test_prediction.csv')