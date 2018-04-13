############################
#
# 11th April 2018
# Exploratory data analysis
#
############################

# read data
raw_data = read.csv('ODI-2018.csv')

# plot some data
gender = plot(raw_data$What.is.your.gender.)

# can be saved with: 
#savePlot('gender_plot.png', type = "png")

new_data = raw_data[, -c (1,10,11,12)]
new_data

attach(new_data)
pairs(new_data) # Not required just to observe!

yes_db = new_data$Have.you.taken.a.course.on.machine.learning. which()


## Data Cleaning
## Make a new data table 
## Find interesting attributes
## Make plots

