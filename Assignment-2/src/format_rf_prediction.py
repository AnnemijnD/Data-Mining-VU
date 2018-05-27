import pandas as pd

data = pd.read_csv('../rf_test_prediction.csv')
data = data.drop(columns=['Unnamed: 0'])

data = data.sort_values(['srch_id','prediction_book','prediction_click'], ascending=[True, False, False])
data = data.drop(columns=['prediction_book','prediction_click'])
data.columns = ['SearchId', 'PropertyId']

data.to_csv('../results/rf_test_prediction_submission.csv', index=False)

print("Done")
