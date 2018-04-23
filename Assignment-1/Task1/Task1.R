

odi_data <- read.csv("ODI-2018_clean.csv")
odi_data

odi_data <- odi_data[-c (1),]
odi_data

attach(odi_data)

pie(table(What.is.your.gender.))

barplot(table(What.programme.are.you.in.), main="Program of Study",
        xlab="Program of Study",
        ylab="Number of Student",
        col="lightblue",
        ylim = c(0,60))
# Such diverse group of students = 26 different study backgroud
# Artifitial Intelliegence = 48 (max number of students)
# One invalid entry found in the program of study field (i.e 12-05-1995)

# Total number of records : 218 
# Real record : 217. 1st record : empty (maybe for header!)
# Total number of attributes: 16

# More male(150) students are taking this course compared to female(63)
# Gender unknown : 4  




ml = as.factor(Have.you.taken.a.course.on.machine.learning.)
barplot(prop.table(table(ml)),  main="Histogram of Prior knowledge of Machine Learning",
        xlab= "Response of students",
        ylab="Frequency",
        col="lightblue",
        ylim = c(0, 0.8))
# Taken Machine Learning : yes = 120, No = 94, Unknown = 3
# Highest frequency = Yes (~0.6)

byr = as.numeric(birth_year)
hist(byr, main="Histogram of Student's Birth Year",
     xlab="Birth Year",
     ylab="Number of Student",
     col="lightblue",
     ylim = c(0,200))
# Birth Year : Na = 53(max), some interesting input = 1768, 1931, 2000, 2018
# majority of student have birthyear = (1950 - 2000)
# (1750-1800) = 1 student, (1900-1950) = 1, (2000-2050) = 3


qqnorm(as.numeric(Give.a.random.number), main = "Normal Q-Q Plot of Random number")
qqline(as.numeric(Give.a.random.number), col = 'red')
# doesn't seem normal. rather it seems like stepped!
# highest frequency = 7
# Max limit was 100 but there are some strange/invalid input for example : rnorm(n=1,mu=12,sigma=1)


### Have you taken statistics ###

stat = as.factor(Have.you.taken.a.course.on.statistics.)
barplot(prop.table(table(stat)),  main="Histogram of Prior knowledge of Statistics",
        xlab= "Response of students",
        ylab="Frequency",
        col="lightblue",
        ylim = c(0, 1))
# Highest frequency = Yes (~0.85)
# yes = 189, No = 23, Unknown = 5
