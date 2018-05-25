# This script creates sample from 10% of data by srch_id


import pandas as pd
import numpy as np
import random

df = pd.read_csv("train.csv")

# get list of srch_id
srch_id_list = df["srch_id"].values

#create list with unique values
id_set = set(srch_id_list)

#retrieve only 10% of unique ids
num_to_select = len(id_set)/10

# generate random list of ids
random_ids = random.sample(id_set, num_to_select)

# retrieve data
result_sample = df.loc[df['srch_id'].isin(random_ids)]


result_sample.to_csv("sample_train_10prc_by_srch_id.csv");