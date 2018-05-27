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

# read models
# gbm click
with open("gbm_click.sav", 'rb') as file:
    gbm_click = pickle.load(file)
# gbm book
with open("gbm_book.sav", 'rb') as file:
    gbm_book = pickle.load(file)

# predict click
predictors = list(test.columns.values.tolist())
predictors.remove('Unnamed: 0')
predictors.remove('date_time')

click_prob = gbm_click.predict_proba(test[predictors])[:, 1]
test["prediction_click"] = pd.Series(click_prob)

# predict book
predictors = list(test.columns.values.tolist())
predictors.remove('Unnamed: 0')
predictors.remove('date_time')

book_prob = gbm_book.predict_proba(test[predictors])[:, 1]
test["prediction_book"] = pd.Series(book_prob)

# save prediction
result = test.ix[:, ['srch_id', 'prop_id','prediction_book','prediction_click']]
result.to_csv('../results/gbm_test_prediction.csv')
