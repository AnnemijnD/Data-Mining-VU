############################
#
# konrad karas: 'what makes a good day' cleanup
#
############################


raw_data = read.csv('ODI-2018.csv', header = TRUE, stringsAsFactors = FALSE)

library(RecordLinkage) # console: install.packages('RecordLinkage')

gday1 = as.vector(raw_data$What.makes.a.good.day.for.you..1..)
gday2 = as.vector(raw_data$What.makes.a.good.day.for.you..2..)
gday = c(gday1,gday2)

for(i in 1:(length(gday))) {
  gday[i] = tolower(gday[i])
}


groups = list()

for(i in 1:(length(gday)-1)) {
  if(nchar(gday[i]) == 0) {
    next
  }
  word = gday[i]
  print('CURRENT WORD:')
  print(word)
  if(length(groups) == 0) {
    groups[[1]] <- c(word)
    next
  }
  maxScore = 0
  bestGroupIndex = -1
  for(a in 1:length(groups)) {
    groupScore = 0
    group = groups[[a]]
    for(b in 1:length(group)) {
      word_cmp = group[b]
      print('COMPARING TO:')
      print(word_cmp)
      if(grepl(word, word_cmp) || grepl(word_cmp, word)) {
        groupScore = groupScore + 1
      }else {
        groupScore = groupScore + levenshteinSim(word,word_cmp)
      }
    }
    groupScore = groupScore/length(group)
    print('groupScore:')
    print(groupScore)
    
    if(groupScore > 0.5 && groupScore > maxScore) {
      maxScore = groupScore
      bestGroupIndex = a
    }
  }
  print('bestGroupIndex:')
  print(bestGroupIndex)
  if(bestGroupIndex > 0) {
    groups[[bestGroupIndex]] <- c(groups[[bestGroupIndex]], word)
  } else {
    groups[[length(groups)+1]] <- c(word)
  }
}


#REPLACE VALUES IN DATAFRAME

for(i in 1:nrow(raw_data)) {
  print("Step")
  print(i)
  record = raw_data[i,]
  print(record)
  par1 = tolower(record$What.makes.a.good.day.for.you..1..)
  par2 = tolower(record$What.makes.a.good.day.for.you..2..)
  
  for(x in 1:length(groups)) {
    group = groups[[x]]
    for(y in 1:length(group)) {
      word = group[y]
      if(!is.na(par1) && grepl(par1,word)) raw_data[i,15] <- group[1]
      if(!is.na(par2) && grepl(par2,word)) raw_data[i,16] <- group[1]
    }
  }
}
raw_data[sapply(raw_data, is.character)] <- lapply(raw_data[sapply(raw_data, is.character)], 
                                                   as.factor)


write.csv(raw_data, file = "ODI_KOKAR.csv", row.names = FALSE)