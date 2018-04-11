#################################
#
# April 11th 2018
# Izak de Kom
#
# Clean birthday and bedtime data
#
# Note: python3
#
#################################

import sys
import re
from operator import itemgetter

file = open('ODI-2018.csv')
months = {"january": 1,"february": 2,"march": 3,"april": 4,"may": 5,"june": 6,"july": 7,"august": 8,"september": 9,"october": 10,"november": 11,"december": 12,\
		  "januari": 1, "februari": 2, "maart": 3, "april": 4, "mei": 5, "juni": 6, "juli": 7, "augustus": 8,"september": 9, "oktober": 10, "november": 11, "december": 12}

data = []
for line in file:
	data.append(line.split(','))


# birthday is index 8
# bedtime is index 13
indices = [8, 13]

new_data = []
for line in data:
	new_data.append((list(itemgetter(*indices)(line))))

def get_year(line):

	# try to extract full years
	for y in range(1699,2050):

		if str(y) in line:
			year = str(y)
			break

	# try to extract years like '93'
		for y in range(32,100):

			if str(y) in line:
				year = '19' + str(y)
				break

		# give up
		else:
			year = "NA"

	return(year)

def get_month(line, year):

	# remove the year string from the data
	if year != "NA":
		line = re.sub(year,'',line)

	# get lowercase of string
	line = line.lower()

	# search for month names in string
	for item in months:

		if item in line:
			month = months[item]
			return(month)

		# give up
		else:
			month = "NA"

	# extract months from numbers by excluding numbers that can only be days, like '13'
	for i in range(13,32):

		if str(i) in line:
			line = re.sub(str(i),'',line)
			line = re.sub(r'\W+', '', line)
			month = line = re.sub('0', '', line)
			return(month)

	# esle, get the second number, so assume the date is in the day-month-year format
	line = re.split('[^a-zA-Z0-9]', line)
	line = list(filter(None,line))

	if len(line) > 1:
		if not line[1].isalpha():
			month = int(line[1])

	return(month)

def get_day(line, year):

	# if a year was found, remove it from the data
	if year != "NA":
		line = re.sub(year,'',line)

	# get lowercase of the string
	line = line.lower()

	# if month name in string, remove it
	for month in months.keys():
		if month in line:
			line = re.sub(month, '', line)
			break

	# find day by 'th', like in 'august 13th'
	if 'th' in line and len(re.findall('\d+', line)) > 0:
		temp = re.sub('th','',line)
		temp = re.sub(' ', '', line)

		# extract the day number
		digits = re.findall('\d+', temp)
		day = digits[0]
		return(day)

	# if a number between 13 and 32 is in the string, this has to be the day
	for i in range(13,32):

		if str(i) in line:
			day = str(i)
			return(day)

		# give up
		else:
			day = "NA"

	# esle, get the first number, so assume the date is in the day-month-year format
	line = re.split('[^a-zA-Z0-9]', line)
	line = list(filter(None,line))

	if len(line) > 1:
		if not line[0].isalpha():
			day = int(line[0])

	return(day)

# clean the data for all samples
for i in new_data[2:]:

	# get date
	year = get_year(i[0])
	month = get_month(i[0],year)
	day = get_day(i[0], year)

	# format day-month-year
	date = str(day) + '-' + str(month) + '-' + str(year)

	print(i[0].lower() + ' --> ' + date)
