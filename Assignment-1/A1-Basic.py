# Author : Tanjina Islam
# Creation Date : 10th April, 2018

# Load CSV
import csv
# Load numpy
import numpy

# Just for testing #

filename = 'ODI-2018.csv'
raw_data = open(filename, 'rt')
reader = csv.reader(raw_data, delimiter=',', quoting=csv.QUOTE_NONE)
x = list(reader)
data = numpy.array(x).astype(dtype=object)
print(data.size)
print(data.__sizeof__())



