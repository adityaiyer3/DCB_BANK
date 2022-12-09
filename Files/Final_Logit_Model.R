## Load Packages and Set Seed
set.seed(1)
library("cvms")
library("tibble")
library("bootStepAIC")
library("ROCR")
library("gplots")
library("ggplot2")
library("ggimage")
#Read in Logistic Regression data

logit <- read.csv(file.choose()) ## Choose Train.csv file

#Adding Sr. No.to the data set
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

#Adding Interactions
logit$date <- interaction(logit$month,logit$day, sep = '/',lex.order = TRUE)
logit$all_loan <- interaction(logit$loan,logit$housing, sep = ':',lex.order = TRUE)
logit$balance_ln <- ifelse(logit$balance < 0, -log(abs(logit$balance)),log(abs(logit$balance+1)))
logit$duration_ln <- log(logit$duration+1)

#Running Saturated Logistic Regression
logit_result <- glm(formula = y ~ ., data=logit, family= "binomial")
summary(logit_result)
#Running Bootstrap variable selection

# NOTE: THE NEXT COMMAND WILL TAKE SEVERAL MINUTES TO EXECUTE.

logit_boot <- boot.stepAIC(logit_result,logit, B=10)

#Running Model obtained through Bootstrap method
logit_bootstep <- glm(formula = y ~job + education + date + marital + all_loan + balance_ln + contact + date + duration_ln + campaign + previous + poutcome, data=logit, family= "binomial")
summary(logit_bootstep) #Summary of the obtained model

#Prediction using Threshold as 0.5
logit$predict <- ifelse(predict(logit_bootstep, logit, type = "response")>0.5,"Yes","No")
Predictions <- predict(logit_bootstep, logit, type = "response")

#Confusion Matrix at Threshold = 0.5
tibble_cfm <-  tibble("Actual" = ifelse(logit$y == 1,"Yes","No"),
                      "prediction" = ifelse(Predictions > 0.5,"Yes","No"))
confusion_Matrix <- table(tibble_cfm)
cfm <- as_tibble(confusion_Matrix)
cfm
plot_confusion_matrix(cfm, 
                      target_col = "Actual", 
                      prediction_col = "prediction",
                      counts_col = "n")


#Determining optimum Threshold

install.packages("ROCR")
ROCRpred <- prediction(Predictions,logit_bootstep$y)
ROCRperf <- performance(ROCRpred, "tpr", "fpr")

#ROC Curve
plot(ROCRperf, colorize=TRUE, print.cutoffs.at=seq(0,1,by=0.1), 
     text.adj=c(-0.2,1.7))

#Plot the Characteristic of "TPR-FPR" w.r.t Threshold

i=0.01
a=1
TPR_Minus_FPR <- list()
Threshold <- list()
while (i<1)
{ 
  confusion_Matrix <- table(logit$y,Predictions > i)
  tp = confusion_Matrix[2,2]
  tn = confusion_Matrix[1,1]
  fp = confusion_Matrix[1,2]
  fn = confusion_Matrix[2,1]
  tpr = tp/(tp+fn)
  fpr = fp/(fp+tn)
  TPR_Minus_FPR[a]<- tpr-fpr
  Threshold[a] <- i
  a=a+1
  i=i+0.05
}
textplot(cbind(TPR_Minus_FPR,Threshold))


#Confusion Matrix at threshold = 0.11
tibble_cfm_0.11 <-  tibble("Actual" = ifelse(logit$y == 1,"Yes","No"),
                      "prediction" = ifelse(Predictions > 0.11,"Yes","No"))
confusion_Matrix_0.11 <- table(tibble_cfm_0.11)
cfm_0.11 <- as_tibble(confusion_Matrix_0.11)
plot_confusion_matrix(cfm_0.11, 
                      target_col = "Actual", 
                      prediction_col = "prediction",
                      counts_col = "n")
