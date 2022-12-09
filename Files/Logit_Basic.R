## Load Packages and Set Seed
set.seed(1)


## Read in Logistic Regression data

logit <- read.csv(file.choose()) ## Choose Train.csv file

#Adding Sr. No.
logit$sr_no <- seq.int(nrow(logit))

#Converting into Categorical Data (Data Cleaning)

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

#Converting Dependent Variable into 0 and 1 (From "Yes" and "No")

logit$y <- ifelse(logit$y == "no",0,1)

#Converting dependent variable to Categorical Data for Logistical Regression to work
logit$y <- as.factor(logit$y)

#Running Saturated Logistic Regression
logit_result <- glm(formula = y ~ ., data=logit, family= "binomial")
summary(logit_result) # Extracting summary of the model

#Adding the Predicted Values to the Dataset
logit$predict <- predict(logit_result, logit, type = "response")
