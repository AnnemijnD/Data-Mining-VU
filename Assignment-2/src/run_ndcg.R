######################################################################################
#
# Arguments:
# model: model variable
# data: complete test dataframe
# features: vector with indices (column numbers of the used features in the test data)
#
# Example:
# source("src/run_ndcg.R")
# result1 = run_ndcg(gbm,test,c(67,58,15,9,11,26))
#
######################################################################################

source("src/ndcg.R")

run_ndcg = function(model,data,features,ignore_null=F,debug=F){
  
  x=cbind(data$srch_id,
          data$prop_id,
          data$click_bool,
          data$booking_bool,
          predict(model,data[,features], type = "response"))
  colnames(x) = c("srch_id", "prop_id", "click_bool","booking_bool", "booking_prob")
  x = as.data.frame(x)
  x = x[order(x$srch_id,x$booking_prob, decreasing = T),]
  result=nDCG(x, ignore_null,debug)
  result
}
