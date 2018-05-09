##########################################
#
# count_na.py
#
# Izak de Kom
#
# Python3 script to explore features:
#  - Summarize NA counts
#
#
#
##########################################

import numpy as np
import pandas as pd
from collections import OrderedDict

## read the training data
data = pd.read_csv('../data/train.csv')

print("Loaded %s features" % str(len(data.columns)))

## make lists to store the NA descriptives
names = []
na_count = []
non_na_count = []
na_fraction = []

## gather the NA descriptives
for i in data.columns:
    print("Processing feature: %s" % i)
    names.append(i)
    na = data.ix[:,i].isnull().sum()
    na_count.append(na)
    non_na = len(data) - na
    non_na_count.append(non_na)
    na_fraction.append(na/(na + non_na))

## make a dictionary of the NA summary
na_dict = OrderedDict()
na_dict['Feature'] = names
na_dict['NA_count'] = na_count
na_dict['NON_NA_count'] = non_na_count
na_dict['NA_fraction'] = na_fraction

## create a pandas dataframe from the dictionary na_dict
na_df = pd.DataFrame(data=na_dict)

## save the dataframe na_df
na_df.to_csv('../results/na_summary_features.csv')
