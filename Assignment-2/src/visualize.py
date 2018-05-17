#####################################
#
# visualize.py
#
# Izak de Kom
#
# Visualize features
#
#
#
#
#####################################

import numpy as np
import seaborn as sns
from rpy2.robjects import pandas2ri
pandas2ri.activate()

import pandas as pd
import matplotlib.pyplot as plt

## load the data
print("Loading data...")
data = pd.read_csv('../sample_train_10prc.csv')
#data = pd.read_csv('../../../data/train.csv')

print("Loaded %s features and %s samples" % (str(len(data.columns)),str(len(data))))

## summarize
#print(data.ix[:,1].describe(include='numpy.number'))
#print(data['orig_destination_distance'].describe(include='numpy.number'))

## save a histogram of the prices
data['price_usd'].plot.hist(bins=100,range=(0,800))
plt.xlabel('Booking price (USD)', fontsize=8)
plt.ylabel('Frequency',fontsize=8)
plt.grid(True)
plt.savefig('../results/hist_price_usd.png', dpi=600)
plt.clf()

## save a histogram of the length of stay
xmax = 15
data['srch_length_of_stay'].plot.hist(bins=xmax,range=(0,xmax))
plt.xticks(range(xmax+1))
plt.xlabel('Length of stay (number of nights)', fontsize=8)
plt.ylabel('Frequency',fontsize=8)
plt.grid(True)
plt.savefig('../results/hist_srch_length_of_stay.png', dpi=600)
plt.clf()

## save a histogram of days between search and trip
data['srch_booking_window'].plot.hist(bins=300,range=(0,300))
plt.xlabel('Number of days between search and trip', fontsize=8)
plt.ylabel('Frequency',fontsize=8)
plt.grid(True)
plt.savefig('../results/hist_srch_booking_window.png', dpi=600)
plt.clf()

## save a histogram of the distance to the destination
data['orig_destination_distance'].plot.hist(bins=300,range=(0,12000))
plt.xlabel('Distance to the destination (Km)', fontsize=8)
plt.ylabel('Frequency',fontsize=8)
plt.grid(True)
plt.savefig('../results/hist_orig_destination_distance.png', dpi=600)
plt.clf()

## calculate the correlation matrix and build a heatmap
corr = data.ix[:,[5,6,9,10,12,13,14,16,19,20,21,22,23,24,25,26]].corr()

## Generate a mask for the upper triangle
mask = np.zeros_like(corr, dtype=np.bool)
mask[np.triu_indices_from(mask)] = True

## Set up the matplotlib figure
f, ax = plt.subplots(figsize=(12, 12))

## Generate a custom diverging colormap
cmap = sns.diverging_palette(220, 10, as_cmap=True)

plt.rcParams.update({'font.size': 22})
## build heatmap
#sns.set(font_scale=10)
sns.set(style="white")
sns.heatmap(corr,mask=mask,cmap=cmap, xticklabels=corr.columns, yticklabels=corr.columns, annot=True, fmt=".2f",annot_kws={"size": 12},cbar_kws={"shrink": .5},linewidths=.5)

## save heatmap
plt.savefig('../results/feature_correlation_heatmap.png', dpi=300,bbox_inches='tight')
plt.clf()