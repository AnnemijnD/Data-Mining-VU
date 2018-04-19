############################
#
# Author : Tanjina Islam
# Creation Date : 17th April, 2018
#
############################

# For Naive Bayes Modelling
library(caret)
library(e1071)
# For processing text into corpus
library(tm)
# for nice table
library(pander)
# For simplifying selections
library(dplyr)
# library for parellel processing
library(doParallel)

library(stringr)
library(tidyr)
library(wordcloud)

# To create a local 4-node snow cluster

num_of_cluster <- makeCluster(detectCores(), type = "SOCK")
registerDoParallel(num_of_cluster)  # For linux/mac use library(doMC) and registerDoMC(cores = 4)

# Print process Ids

foreach(i=1:length(num_of_cluster)) %dopar% Sys.getpid()

# Method for dispalying frequency into table

frequency_table <- function(x, caption) {
  
  round(100*prop.table(table(x)), 1)
}

# Method for summarise model comparison

summarise_comp <- function(predictive_model) {
  
  model_summary <- list(True_Neg=predictive_model$table[1,1],  # True Negatives
               True_Pos = predictive_model$table[2,2],  # True Positives
               False_Neg = predictive_model$table[1,2],  # False Negatives
               False_Pos = predictive_model$table[2,1],  # False Positives
               accuracy = predictive_model$overall["Accuracy"],  # Accuracy
               sensitivity = predictive_model$byClass["Sensitivity"],  # Sensitivity
               specificity = predictive_model$byClass["Specificity"])  # Specificity
  lapply(model_summary, round,4)
}

# Method to convert numeric entries into factors
convert_counts <- function(x) {
  x <- ifelse(x > 0, 1, 0)
  x <- factor(x, levels = c(0, 1), labels = c("Absent", "Present"))
}

## Load the SMS Data ##

sms_raw_data = read.csv("SmsCollection.csv", header=TRUE, sep="\t", quote="", stringsAsFactors = FALSE)

# Split label and text

label_split = strsplit(sms_raw_data$label.text, ";")
label_apply = sapply(label_split , '[', 1)

text_split = strsplit(sms_raw_data$label.text, ";")
text_apply = sapply(label_split , '[', 2)

# assign new column for label and text 

sms_raw_data <- transform(sms_raw_data, label = label_apply, text = text_apply)

# delete unspilted column

sms_raw_data <- sms_raw_data[-c(1)] 
str(sms_raw_data)

# randomization

set.seed(12358)
sms_raw_data <- sms_raw_data[sample(nrow(sms_raw_data)),]

# use label as a factor

sms_raw_data$label <- factor(sms_raw_data$label)

# use text as characters

sms_raw_data$text <- as.character(sms_raw_data$text)

## Data Processing ##

sms_corpus <- VCorpus(VectorSource(sms_raw_data$text))
print(sms_corpus)
inspect(sms_corpus[1:2])
as.character(sms_corpus[[1]])

lapply(sms_corpus[1:2], as.character)

## Data cleanup/transformation ##

sms_corpus_clean <- sms_corpus %>%
  tm_map(content_transformer(tolower)) %>%
  tm_map(removeNumbers) %>%
  tm_map(removeWords, stopwords(kind = "en")) %>%
  tm_map(removePunctuation) %>%
  tm_map(stripWhitespace)

sms_dtm <- DocumentTermMatrix(sms_corpus_clean)
sms_dtm

## Generating training and testing datasets ##

train_index <- createDataPartition(sms_raw_data$label, p=0.75, list=FALSE)
sms_raw_train <- sms_raw_data[train_index,]
sms_raw_test <- sms_raw_data[-train_index,]

str(sms_raw_train)
sms_corpus_clean_train <- sms_corpus_clean[train_index]
sms_corpus_clean_test <- sms_corpus_clean[-train_index]
sms_dtm_train <- sms_dtm[train_index,]
sms_dtm_test <- sms_dtm[-train_index,]

sms_train_labels <- sms_raw_train$label
sms_test_labels  <- sms_raw_test$label

## Frequency Comparison among Datasets ##

ft_raw <- frequency_table(sms_raw_data$label)
ft_train <- frequency_table(sms_train_labels)
ft_test <- frequency_table(sms_test_labels)
ft_df <- as.data.frame(cbind(ft_raw, ft_train, ft_test))

colnames(ft_df) <- c("Raw Dataset", "Training Dataset", "Test Dataset")

pander(ft_df, style="rmarkdown",
       caption=paste0("Frequency comparison among different datasets based on SMS label"))

# create Wordcloud from cleaned vcorpus to look at the most frequent words

wordcloud(sms_corpus_clean, min.freq = 60, random.order = FALSE)
spam <- subset(sms_raw_data, label == "spam")
ham  <- subset(sms_raw_data, label == "ham")
wordcloud(spam$text, max.words = 50, scale = c(5, 0.5))
wordcloud(ham$text, max.words = 50, scale = c(3.5, 0.5))

# most frequent words (appeared at least 5 times in dataset)
sms_freq_words <- findFreqTerms(sms_dtm_train, lowfreq =  5)


sms_dtm_freq_train <- sms_dtm_train[ , sms_freq_words]
sms_dtm_freq_test <- sms_dtm_test[ , sms_freq_words]


sms_train <- apply(sms_dtm_freq_train, MARGIN = 2, convert_counts)
sms_test  <- apply(sms_dtm_freq_test, MARGIN = 2, convert_counts)

## Training the data using Naive Bayes Model ##

######################################

# control = trainControl(method="repeatedcv", number=10, repeats=2)
# set.seed(12358)


# sms_model1 <- train(sms_train, sms_train_labels, method = "naive_bayes", trControl=control)
# sms_model1

# set.seed(12358)
# sms_model2 <- train(sms_train, sms_train_labels, method = "naive_bayes", tuneGrid=data.frame(.fL=1, .usekernel=FALSE), trControl=control)
# sms_model2

######################################

# Got error while using the above training functions >>> in tuneGrid for model 2. Maybe Library related prob idk!!!

# But the following function works for both model

sms_model_1 <- naive_bayes(sms_train, sms_train_labels)
sms_model_1

sms_model_2 <- naive_bayes(sms_train, sms_train_labels, laplace = 1, usekernel = FALSE)
sms_model_2

## Evaluate performance ##

sms_test_pred <- predict(sms_model_1, sms_test)
sms_test_pred_result <- confusionMatrix(sms_test_pred, sms_test_labels, positive="spam")
sms_test_pred_result

sms_test_pred_2 <- predict(sms_model_2, sms_test)
sms_test_pred_2_result <- confusionMatrix(sms_test_pred_2, sms_test_labels, positive="spam")
sms_test_pred_2_result

# Summarise performance into tabular form
model_1 <- summarise_comp(sms_test_pred_result)
model_2 <- summarise_comp(sms_test_pred_2_result)
model_comp <- as.data.frame(rbind(model_1, model_2))
rownames(model_comp) <- c("Model-1:[Naive Bayes]", "Model-2:[Naive Bayes+laplace]")
pander(model_comp, style="rmarkdown", split.tables=Inf, keep.trailing.zeros=TRUE,
       caption="Performance Table for two models")

