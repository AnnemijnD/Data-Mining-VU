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

