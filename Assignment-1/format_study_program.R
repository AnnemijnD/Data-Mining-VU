library(rapportools)
data_table = read.csv("ODI-2018.csv")
data_table = data_table[-c(1), -c(1,10,11,12)]

attach(data_table)

# Rename column names

new_col_name = c("Program of Study", "Taken Machine Learning", "Taken Information Retrieval", "Taken Statistics", "Taken Databases", "Gender", 
                 "Chocolate Makes You", "Birthday", "Random Number", "Time to Bed", "Option-1 for a Good day", "Option-2 for a Good Day")

C = 12
i = 1

for(x in 1:C){
  names(data_table)[x] <- new_col_name[i]
  i = i + 1
}

attach(data_table)
data_table

program = data.frame(`Program of Study`)
attach(program)
program

study_program = data.frame(`Program of Study`)
attach(study_program)


study_program$Program.of.Study <- gsub("^cs|CS", "Computer Science", study_program$Program.of.Study)
study_program$Program.of.Study  <- gsub("BA", "Business Analytics", study_program$Program.of.Study)
study_program$Program.of.Study  <- gsub("AI|Ai|A\\.\\sI\\.|\\w{2}\\spremaster$|\\w+\\s\\(\\w+)$", "Artificial Intelligence", study_program$Program.of.Study)


#study_program$Program.of.Study  <- gsub("\\d{2}[-]{1}\\d{2}[-]{1}\\d{4}", "N/A", study_program$Program.of.Study) 
study_program$Program.of.Study  <- gsub("(PhD)\\s(\\w){3}", "PhD", study_program$Program.of.Study) 

study_program$Program.of.Study  <- gsub("Master\\s|M\\s|MSc\\s|Msc\\s|MSC\\s|MA\\s|Msc\\.\\s|Masters\\s", " ", study_program$Program.of.Study) 
study_program$Program.of.Study  <- gsub("\\&|\\:|\\(|\\)|VU", " ", study_program$Program.of.Study)



# study = as.vector(data_table$`Program of Study`)
# for(i in 1: length(study)){
#  program$Program.of.Study <- tocamel(study[i],sep = " ")
# }


write.csv(study_program, file = "formated_program.csv")

