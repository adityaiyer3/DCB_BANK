## Load Packages and Set Seed
set.seed(1)
library(MASS)

## Read in Logistic Regression data

logit <- read.csv(file.choose()) ## Choose Train.csv file

#Adding Sr. No. to the data points

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

#Converting Dependent Variable into 0 and 1.

logit$y <- ifelse(logit$y == "no",0,1)

#Converting Dependent Variable to Categorical Data
logit$y <- as.factor(logit$y)

#Running Saturated Logistic Regression
logit_result <- glm(formula = y ~ ., data=logit, family= "binomial")

#Running Backward Step Elimination (Under MASS library)

# NOTE: THE NEXT COMMAND WILL TAKE SEVERAL MINUTES TO EXECUTE.

logit_backwards <- stepAIC(logit_result, direction = "backward", trace = FALSE)

#Summary of Backward Elimination Model

summary(logit_backwards)

logit$predict <- predict(logit_backwards, logit, type = "response")


write.csv(logit, file = file.choose(new=TRUE), row.names = FALSE)
