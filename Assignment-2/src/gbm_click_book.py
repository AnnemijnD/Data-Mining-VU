#Import libraries:
import sys
import math
import pickle
import pandas as pd
import numpy as np
from sklearn.ensemble import GradientBoostingClassifier  #GBM algorithm
from sklearn import model_selection, metrics   #Additional scklearn functions
from sklearn.model_selection import GridSearchCV   #Perforing grid search


import matplotlib.pylab as plt
from matplotlib.pylab import rcParams
rcParams['figure.figsize'] = 12, 4

train = pd.read_csv('../feature_eng_result.csv')
train = train[:-490000]

def modelfit(model, train, predictors, response, prediction, CV=True, printFeatureImportance=True, cv_folds=5):
    # Fit the algorithm on the data
    model.fit(train[predictors], train[response])

    # Predict training set:
    dtrain_predictions = model.predict(train[predictors])
    dtrain_predprob = model.predict_proba(train[predictors])[:, 1]

    result = train#pd.DataFrame(dict(srch_id=train['srch_id'],prop_id=train['prop_id'],booking_bool=train['booking_bool'],click_bool=train['click_bool']))
    result[prediction] = pd.Series(dtrain_predprob)

    # Perform cross-validation:
    if CV:
        cv_score = model_selection.cross_val_score(model, train[predictors], train[response], cv=cv_folds,
                                                    scoring='roc_auc')

    # Print model report:
    print("\nModel Report")
    print("Kappa : %.4g" % metrics.cohen_kappa_score(train[response].values, dtrain_predictions))
    #print("AUC Score (Train): %f" % metrics.roc_auc_score(train['click_bool'], dtrain_predprob))
    file = open('gbm_book_kappa.txt', 'w')
    file.write(str(metrics.cohen_kappa_score(train[response].values, dtrain_predictions)))
    file.close()

    if CV:
        print("CV Score : Mean - %.7g | Std - %.7g | Min - %.7g | Max - %.7g" % (
        np.mean(cv_score), np.std(cv_score), np.min(cv_score), np.max(cv_score)))

    # Print Feature Importance:
    if printFeatureImportance:
        feat_imp = pd.Series(model.feature_importances_, predictors).sort_values(ascending=False)
        feat_imp.plot(kind='bar', title='Feature Importances')
        plt.ylabel('Feature Importance Score')
        plt.savefig('../results/feature_importance_gbm_%s.png' % prediction, dpi=300, bbox_inches='tight')

    return(result)

#Choose all predictors except these:
predictors = list(train.columns.values.tolist())
predictors.remove('click_bool')
predictors.remove('booking_bool')
predictors.remove('gross_bookings_usd')
predictors.remove('position')
predictors.remove('Unnamed: 0')
predictors.remove('date_time')

gbm0 = GradientBoostingClassifier(random_state=10, verbose=1, n_estimators=1000)

result = modelfit(gbm0, train, predictors, "click_bool",'prediction_click',CV=False)

# save the model
filename = 'gbm_click.sav'
pickle.dump(gbm0, open(filename, 'wb'))

'''
gbm0 = pickle.load(open('gbm_click.sav', 'rb'))
# Predict training set:
dtrain_predictions = gbm0.predict(train[predictors])
dtrain_predprob = gbm0.predict_proba(train[predictors])[:, 1]
result = pd.DataFrame(dict(srch_id=train['srch_id'],prop_id=train['prop_id'],booking_bool=train['booking_bool'],click_bool=train['click_bool']))
#result = pd.concat([train['srch_id'],train['prop_id'],train['booking_bool'],train['click_bool']])
result['prediction_click'] = pd.Series(dtrain_predprob)
'''

result.to_csv('../results/gbm_click_result.csv')


#######################################################################################
# Now model booking bool based on all including prediction_click, excluding click_bool
#######################################################################################

train = pd.read_csv('../results/gbm_click_result.csv')

#Choose all predictors except these:
predictors = list(train.columns.values.tolist())
predictors.remove('click_bool')
predictors.remove('booking_bool')
predictors.remove('gross_bookings_usd')
predictors.remove('position')
predictors.remove('Unnamed: 0')
predictors.remove('date_time')
predictors.remove('Unnamed: 0.1')

gbm1 = GradientBoostingClassifier(random_state=10, verbose=1, n_estimators=1000)

result = modelfit(gbm1, train, predictors, "booking_bool", 'prediction_book',CV=False)

# save the model
filename = 'gbm_book.sav'
pickle.dump(gbm1, open(filename, 'wb'))

result.to_csv('../results/gbm_book_result.csv')

###############################################################
# prediction based on full training set
###############################################################
# test = pd.read_csv('../train_feature_eng.csv')
# predictors = list(test.columns.values.tolist())
# predictors.remove('click_bool')
# predictors.remove('booking_bool')
#predictors.remove('position_model') ### add again when available
# predictors.remove('gross_bookings_usd')
# predictors.remove('position')
# predictors.remove('Unnamed: 0')
# predictors.remove('date_time')
# click_prob = gbm0.predict_proba(test[predictors])[:, 1]
# test[prediction] = pd.Series(click_prob)