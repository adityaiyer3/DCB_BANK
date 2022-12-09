## Load Packages and Set Seed
set.seed(1)


## Read in Logistic Regression data

logit <- read.csv(file.choose()) ## Choose Test.csv file
logit_train <- read.csv(file.choose()) ## Choose Train.csv file

#Converting into Categorical Data (Data Cleaning) FOR Train Data
logit_train$job <- as.factor(logit_train$job)
logit_train$marital <- as.factor(logit_train$marital)
logit_train$education <- as.factor(logit_train$education)
logit_train$default <- as.factor(logit_train$default)
logit_train$housing <- as.factor(logit_train$housing)
logit_train$loan <- as.factor(logit_train$loan)
logit_train$contact <- as.factor(logit_train$contact)
logit_train$poutcome <- as.factor(logit_train$poutcome)
logit_train$month <- as.factor(logit_train$month)
logit_train$day <- as.factor(logit_train$day)

# Converting Dependent variable to 0 and 1
logit_train$y <- ifelse(logit_train$y == "no",0,1)

#Converting Dependent variable to Categorical Data
logit_train$y <- as.factor(logit_train$y)

#Adding Interactions
logit_train$date <- interaction(logit_train$month,logit_train$day, sep = '/',lex.order = TRUE)
logit_train$all_loan <- interaction(logit_train$loan,logit_train$housing, sep = ':',lex.order = TRUE)
logit_train$balance_ln <- ifelse(logit_train$balance < 0, -log(abs(logit_train$balance)),log(abs(logit_train$balance+1)))
logit_train$duration_ln <- log(logit_train$duration+1)

#Plotting the Regression Model
logit_bootstep <- glm(formula = y ~job + education + date + marital + all_loan + balance_ln + contact + date + duration_ln + campaign + previous + poutcome, data=logit_train, family= "binomial")
summary(logit_bootstep)

########################PREDICTION FOR TEST DATA####################################

#Converting into Categorical Data (Data Cleaning) FOR TEST DATA

logit$job <- as.factor(logit$job)
logit$marital <- as.factor(logit$marital)
logit$education <- as.factor(logit$education)
logit$default <- as.factor(logit$default)
logit$housing <- as.factor(logit$housing)
logit$loan <- as.factor(logit$loan)
logit$contact <- as.factor(logit$contact)
logit$poutcome <- as.factor(logit$poutcome)
logit$month <- as.factor(logit$month)
logit$day <- as.factor(logit$day)

#Adding Interactions

logit$date <- interaction(logit$month,logit$day, sep = '/',lex.order = TRUE)
logit$all_loan <- interaction(logit$loan,logit$housing, sep = ':',lex.order = TRUE)
logit$balance_ln <- ifelse(logit$balance < 0, -log(abs(logit$balance)),log(abs(logit$balance+1)))
logit$duration_ln <- log(logit$duration+1)

#Predicting of Probability
logit_Predict <- predict(logit_bootstep, 
                         logit, type = "response")

#Converting the Probability to "Yes" and "No" with threshold as 0.11
logit$y <- ifelse(logit_Predict >0.11, "Yes", "No")

#Final Data set after removing extra columns
logit_Final = subset(logit, select = -c(date,all_loan,balance_ln,duration_ln) )

#Writing a CSV files with the Prediction

write.csv(logit_Final, file = file.choose(new=TRUE), row.names = FALSE)
