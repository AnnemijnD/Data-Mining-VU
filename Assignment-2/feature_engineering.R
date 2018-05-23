#load data
data = read.csv('data_sample/sample_train_10prc_no_missing_val.csv')
attach(data)

# 01 : extract hour, day and motnh from date_time feature
# date_time -> date_hour, date_day, date_month
data$date_time <- as.character(data$date_time)
data$date_day <- sapply(data$date_time, FUN=function(x) {strsplit(x, split='[- :]')[[1]][3]})
data$date_month <- sapply(data$date_time, FUN=function(x) {strsplit(x, split='[- :]')[[1]][2]})
data$date_hour <- sapply(data$date_time, FUN=function(x) {strsplit(x, split='[- :]')[[1]][4]})
# mark features as factors with fixed levels
data$date_day <- factor(data$date_day)
data$date_month <- factor(data$date_month)
data$date_hour <- factor(data$date_hour)

# 02 : set children_flag if search query contains children
data$children_flag <- sapply(data$srch_children_count, FUN=function(x) {
  if(x > 0) 1
  else 0
})
data$children_flag <- factor(data$children_flag)

# 03 : price_diff_usd = | visitor_hist_adr_usd - price_usd |
data["price_diff_usd"] <- abs(visitor_hist_adr_usd - price_usd)

# 04 : star_rating_diff = | visitor_hist_adr_usd - price_usd |
data["star_rating_diff"] <- abs(visitor_hist_starrating - prop_starrating)

# 05 : prop_star_rating_monotonic = | prop_starrating - mean(prop_starrating[booking_bool]) |
data["prop_star_rating_monotonic"] <- abs(prop_starrating - mean(prop_starrating[booking_bool]))

# 06 : hotel rank in region
data$srch_destination_id <- factor(data$srch_destination_id)


# Write CSV in R
write.csv(data_sample, file = "sample_train_10prc_feature_eng.csv")