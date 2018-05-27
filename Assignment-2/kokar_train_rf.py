# Load the library with the iris dataset
from sklearn.datasets import load_iris

# Load scikit's random forest classifier library
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn import metrics


# Load pandas
import pandas as pd
pd.options.mode.chained_assignment = None

# Load numpy
import numpy as np
import pickle

# Set random seed
np.random.seed(0)

# Create a dataframe with the four feature variables
df = pd.read_csv("feature_eng_result.csv")

# Split train / test 75/25 %
train, test = train_test_split(df, test_size=0.25)

# get features
features = test.drop(['click_bool','position','Unnamed: 0','booking_bool','date_time','srch_id','gross_bookings_usd'], axis=1).columns

# Set click_bool as factor to be predicted
y = pd.factorize(train['click_bool'])[0]

# Create a random forest Classifier. By convention, clf means 'Classifier'
clf = RandomForestClassifier(n_estimators=100, n_jobs=2, random_state=0, verbose=1)


# Train the Classifier to take the training features and learn how they relate
clf.fit(train[features], y)

# save the model
filename = 'rf_click.sav'
pickle.dump(clf, open(filename, 'wb'))

# Create predicted_clicks column for test dataset
test["prediction_click"] = clf.predict_proba(test[features])[:, 1]

# Create predicted_clicks column for train dataset
train["prediction_click"] = clf.predict_proba(train[features])[:, 1]

# AFTER PREDICTING  CLICK_BOOL, NOW WE CAN TRY TO PREDICT BOOKING_BOOL

# get features (click_bool removed because we use predicted_clicks now)
features = test.drop(['click_bool','position','Unnamed: 0','booking_bool','date_time','srch_id','gross_bookings_usd'], axis=1).columns

# Set click_bool as factor to be predicted
y = pd.factorize(train['booking_bool'])[0]

# Create a random forest Classifier. By convention, clf means 'Classifier'
clf = RandomForestClassifier(n_estimators=100, n_jobs=2, random_state=0, verbose=1)


# Train the Classifier to take the training features and learn how they relate
clf.fit(train[features], y)

# save the model
filename = 'rf_book.sav'
pickle.dump(clf, open(filename, 'wb'))

# Create predicted_clicks column for test dataset
test["prediction_book"] = clf.predict_proba(test[features])[:, 1]

# generate binary predictions for kappa:
test_predictions_binary = clf.predict(test[features])

print("Kappa : %.4g" % metrics.cohen_kappa_score(test["booking_bool"].values, test_predictions_binary))

file = open('rf_book_kappa.txt', 'w')
file.write(str(metrics.cohen_kappa_score(test["booking_bool"].values, test_predictions_binary)))
file.close()

test.to_csv("python_rf_result.csv")
