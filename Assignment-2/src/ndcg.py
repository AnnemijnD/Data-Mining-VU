import pandas as pd
import numpy as np
import math
import sys

path = sys.argv[1]
prediction = pd.read_csv(path)

def ndcg(data, zeromax=math.nan):
    score = []
    qcount = 1
    queries = data['srch_id'].nunique()

    for id in data['srch_id'].unique():
        print("Scoring query %s of %s" % (qcount, queries), end="\r")

        query = data.loc[data['srch_id'] == id]
        iquery = query.sort_values(['booking_bool', 'click_bool'], ascending=[False, False])
        iquery['irel'] = iquery['booking_bool']*4 + query['click_bool']

        idcg = 0
        i = 0
        for irel in iquery['irel'].values:
            i += 1
            irel = np.asscalar(irel)
            idcg += (2**irel-1)/math.log2(i+1)

        query = query.sort_values(['prediction_book', 'prediction_click'], ascending=[False, False])
        query['rel'] = query['booking_bool']*4 + query['click_bool']

        i = 0
        dcg = 0
        for rel in query['rel'].values:
            i += 1
            dcg += (2**rel-1)/math.log2(i+1)

        if idcg == 0:
            ndcg = zeromax
        else:
            ndcg = dcg/idcg

        qcount += 1
        score.append(ndcg)

    return(np.nanmean(score))

print(ndcg(prediction), end="\r")