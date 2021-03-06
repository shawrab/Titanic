train <- read.csv("C:\\Users\\user\\Documents\\Titanic\\train.csv", header=T)
test <- read.csv("C:\\Users\\user\\Documents\\Titanic\\test.csv", header=T)


# Suppose all passenger are died
test$Survived <- rep(0, 418)

# make dataframe
prediction1 <- data.frame(PassengerId = test$PassengerId, Survived = test$Survived)
prediction1

# make a csv file
write.csv(prediction1, file= "pridiction1.csv", row.names = FALSE)

table(train$Pclass)
barplot(table(train$Pclass))

library("Amelia")
missmap(train, main = "Titanic train data missing map", col = c("yellow", "black"),
        legend = TRUE)

table(train$Survived)
barplot(table(train$Survived),
        names.arg = c("perished", "Survived"))

barplot(table(train$Pclass), names.arg = c("1st class", "2nd class", "3rd class"),
        main = "Passengerclass", col = "firebrick")
barplot(table(train$Sex), names.arg = c("Male", "Female"),
        main = "Sex", col = "firebrick")

hist(train$Age,
     main = "Age", col = "firebrick")

hist(train$SibSp,
     main = "SibSp", col = "firebrick")

hist(train$Parch,
     main = "Parents and children", col = "firebrick")

hist(train$Fare,
     main = "Fare of the passenger", col = "firebrick")

barplot(table(train$Embarked), main = " Embarkng place", 
        col = "steelblue")

# second prediction
# Load datasets
train <- read.csv("C:\\Users\\user\\Documents\\Titanic\\train.csv", header=T)
test <- read.csv("C:\\Users\\user\\Documents\\Titanic\\test.csv", header=T)

# EDA
summary(train$Sex)
table(train$Sex, train$Survived)
prop.table(table(train$Sex, train$Survived), 1) *100
prop.table(table(train$Sex, train$Survived), 2) *100
barplot(table(train$Sex, train$Survived), main = "Train data passenger",
        xlab = "", col = c("steelblue", "yellow"))

test$Survived <- 0
test$Survived[test$Sex == 'female'] <- 1
prediction2 <- data.frame(PassengerId = test$PassengerId, Survived = test$Survived)
write.csv(prediction2, file = "prediction2.csv", row.names = FALSE)

# 3rd prediction
# Load datasets
train <- read.csv("C:\\Users\\user\\Documents\\Titanic\\train.csv", header=T)
test <- read.csv("C:\\Users\\user\\Documents\\Titanic\\test.csv", header=T)

table(train$Pclass, train$Survived)
prop.table(table(train$Pclass, train$Survived),2) * 100

train$Fare2 <- "30+"
train$Fare2[train$Fare < 30 & train$Fare >= 20] <- "20-30"
train$Fare2[train$Fare < 20 & train$Fare >= 10] <- "10-20"
train$Fare2[train$Fare < 10 ] <- " < 10"


aggregate(Survived ~ Fare2 + Pclass + Sex, data = train, FUN = sum)
aggregate(Survived ~ Fare2 + Pclass + Sex, data = train, FUN = length)
aggregate(Survived ~ Fare2 + Pclass + Sex, data = train,
          FUN = function(x){sum(x)/length(x)})

test$Survived <- 0
test$Survived[test$Sex == 'female'] <- 1
test$Survived[test$Sex == 'female' & test$Pclass == 3 & test$Fare > 20 & test$Fare < 30] <- 0

prediction3 <- data.frame(PassengerId = test$PassengerId, Survived = test$Survived)
write.csv(prediction3, file = "prediction3.csv", row.names = FALSE)
getwd()


# 4th prediction
library("rpart")
library("rattle")
library("rpart.plot")
library("RColorBrewer")

tree1 <- rpart(Survived ~ Sex, data = train, method = "class")
fancyRpartPlot(tree1)
tree2 <- rpart(Survived ~ Pclass+Age, data = train, method = "class")
fancyRpartPlot(tree2)

tree3 <- rpart(Survived ~ Pclass + Sex+Age+SibSp+Parch+Fare+Embarked, data = train, 
               method = "class")
plot(tree3)
text(tree3)
fancyRpartPlot(tree3)

prediction4th <- predict(tree3, test, type = "class")
prediction4th

prediction4 <- data.frame(PassengerId = test$PassengerId, Survived = prediction4th)
write.csv(prediction4, file = "prediction4.csv",row.names = FALSE)


# 5th prediction
train <- read.csv("C:\\Users\\user\\Documents\\Titanic\\train.csv", header=T)
test <- read.csv("C:\\Users\\user\\Documents\\Titanic\\test.csv", header=T)

test$Survived <- NA
combined_set <- rbind(train, test)

# predicting child
combined_set$Child[combined_set$Age <= 14] <- 'Child'
combined_set$Child[combined_set$Age > 14] <- 'adult'
table(combined_set$Child, combined_set$Survived)
combined_set$Child <- factor(combined_set$Child)

# predicting mother
combined_set$Mother <- 'Not mother'
combined_set$Mother[combined_set$Sex == 'female' & combined_set$Age > 18 & combined_set$Parch > 0] <- 'Mother'
table(combined_set$Mother, combined_set$Survived)
combined_set$Mother <- factor(combined_set$Mother)

combined_set$Name[1]
strsplit(combined_set$Name, split = '[,.]')[[2]][2]
combined_set$Title <- sapply(combined_set$Name, FUN = function(x){strsplit(x, split = '[,.]')[[1]][2]})

combined_set$Title <- sub(' ', '', combined_set$Title)
table(combined_set$Title)

combined_set$Title[combined_set$Title %in% c('Mme', 'Mlle')] <- 'Mlle'
combined_set$Title[combined_set$Title %in% c('Capt', 'Don', 'Major', 'Sir')] <- 'Sir'
combined_set$Title[combined_set$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] <- 'Lady'

combined_set$Title <- factor(combined_set$Title)
combined_set$Mother <- 'Not mother'
combined_set$Mother[combined_set$Sex == 'female' & combined_set$Age > 18 &
                      combined_set$Parch > 0 & combined_set$Title != 'Miss'] <- 'Mother'
# Cabin and deck
combined_set$Cabin[1:10]
combined_set$Cabin <- as.character(combined_set$Cabin)
strsplit(combined_set$Cabin[2], NULL)[[1]][1]
combined_set$Deck <- factor(sapply(combined_set$Cabin, FUN = function(x) strsplit(x, NULL)[[1]][1]))

# Fare grouping
combined_set$Fare_type[combined_set$Fare <= 50 ] <- 'low'
combined_set$Fare_type[combined_set$Fare > 50 & combined_set$Fare <= 100 ] <- 'med1'
combined_set$Fare_type[combined_set$Fare > 100 & combined_set$Fare <= 150 ] <- 'med2'
combined_set$Fare_type[combined_set$Fare > 150 & combined_set$Fare <= 500 ] <- 'high'
combined_set$Fare_type[combined_set$Fare > 500 ] <- 'vhigh'
aggregate(Survived ~ Fare_type, data = combined_set, FUN = mean)

# Family Member
combined_set$FamilySize <- combined_set$Parch + combined_set$SibSp + 1
round(prop.table(table(combined_set$FamilySize, combined_set$Survived), 1),2)

# Family name
combined_set$Name[1]
strsplit(combined_set$Name[1], split = '[,.]')
combined_set$Surname <- sapply(combined_set$Name, FUN = function(x) strsplit(x, split = "[,]")[[1]][1])
combined_set$FamilyId <- paste(as.character(combined_set$FamilySize), combined_set$Surname, sep = "")

combined_set$FamilySizeGroup[combined_set$FamilySize == 1] <- "single"
combined_set$FamilySizeGroup[combined_set$FamilySize < 5 & combined_set$FamilySize > 1] <- "smaller"
combined_set$FamilySizeGroup[combined_set$FamilySize > 4] <- "large"

combined_set$FamilyId[combined_set$FamilySize == 1] <- "single"
combined_set$FamilyId[combined_set$FamilySize < 5 & combined_set$FamilySize >1] <- "smaller"
combined_set$FamilyId[combined_set$FamilySize > 4] <- "large"
table(combined_set$FamilyId)

# Change into factor
combined_set$FamilyId <- factor(combined_set$FamilyId)
combined_set$FamilySizeGroup <- factor(combined_set$FamilySizeGroup)

# isolate train and test dataset
train <- combined_set[1:891,]
test <- combined_set[892:1309,]

library(rpart)
library(rattle)
library(RColorBrewer)
library(rpart.plot)
fit <- rpart(Survived ~ Pclass+Sex+Age+SibSp+Parch+Fare+Embarked+Title+FamilySize+
               FamilyId, data = train, method = "class")
fancyRpartPlot(fit)

prediction_5th <- predict(fit, test, type = "class")
submit <- data.frame(PassengerId = test$PassengerId, Survived = prediction_5th)
write.csv(submit, file = "prediction5.csv", row.names = FALSE)
dim(combined_set)

# 6th prediction
train <- read.csv("C:\\Users\\user\\Documents\\Titanic\\train.csv", header=T)
test <- read.csv("C:\\Users\\user\\Documents\\Titanic\\test.csv", header=T)

test$Survived <- NA
combined_set <- rbind(train, test)

# predicting child
combined_set$Child[combined_set$Age <= 14] <- 'Child'
combined_set$Child[combined_set$Age > 14] <- 'adult'
table(combined_set$Child, combined_set$Survived)
combined_set$Child <- factor(combined_set$Child)

# predicting mother
combined_set$Mother <- 'Not mother'
combined_set$Mother[combined_set$Sex == 'female' & combined_set$Age > 18 & combined_set$Parch > 0] <- 'Mother'
table(combined_set$Mother, combined_set$Survived)
combined_set$Mother <- factor(combined_set$Mother)

combined_set$Name[1]
strsplit(combined_set$Name, split = '[,.]')[[2]][2]
combined_set$Title <- sapply(combined_set$Name, FUN = function(x){strsplit(x, split = '[,.]')[[1]][2]})

combined_set$Title <- sub(' ', '', combined_set$Title)
table(combined_set$Title)

combined_set$Title[combined_set$Title %in% c('Mme', 'Mlle')] <- 'Mlle'
combined_set$Title[combined_set$Title %in% c('Capt', 'Don', 'Major', 'Sir')] <- 'Sir'
combined_set$Title[combined_set$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] <- 'Lady'

combined_set$Title <- factor(combined_set$Title)
combined_set$Mother <- 'Not mother'
combined_set$Mother[combined_set$Sex == 'female' & combined_set$Age > 18 &
                      combined_set$Parch > 0 & combined_set$Title != 'Miss'] <- 'Mother'
# Cabin and deck
combined_set$Cabin[1:10]
combined_set$Cabin <- as.character(combined_set$Cabin)
strsplit(combined_set$Cabin[2], NULL)[[1]][1]
combined_set$Deck <- factor(sapply(combined_set$Cabin, FUN = function(x) strsplit(x, NULL)[[1]][1]))

# Fare grouping
combined_set$Fare_type[combined_set$Fare <= 50 ] <- 'low'
combined_set$Fare_type[combined_set$Fare > 50 & combined_set$Fare <= 100 ] <- 'med1'
combined_set$Fare_type[combined_set$Fare > 100 & combined_set$Fare <= 150 ] <- 'med2'
combined_set$Fare_type[combined_set$Fare > 150 & combined_set$Fare <= 500 ] <- 'high'
combined_set$Fare_type[combined_set$Fare > 500 ] <- 'vhigh'
aggregate(Survived ~ Fare_type, data = combined_set, FUN = mean)

# Family Member
combined_set$FamilySize <- combined_set$Parch + combined_set$SibSp + 1
round(prop.table(table(combined_set$FamilySize, combined_set$Survived), 1),2)

# Family name
combined_set$Name[1]
strsplit(combined_set$Name[1], split = '[,.]')
combined_set$Surname <- sapply(combined_set$Name, FUN = function(x) strsplit(x, split = "[,]")[[1]][1])
combined_set$FamilyId <- paste(as.character(combined_set$FamilySize), combined_set$Surname, sep = "")

combined_set$FamilySizeGroup[combined_set$FamilySize == 1] <- "single"
combined_set$FamilySizeGroup[combined_set$FamilySize < 5 & combined_set$FamilySize > 1] <- "smaller"
combined_set$FamilySizeGroup[combined_set$FamilySize > 4] <- "large"

combined_set$FamilyId[combined_set$FamilySize == 1] <- "single"
combined_set$FamilyId[combined_set$FamilySize < 5 & combined_set$FamilySize >1] <- "smaller"
combined_set$FamilyId[combined_set$FamilySize > 4] <- "large"
table(combined_set$FamilyId)

# Change into factor
combined_set$FamilyId <- factor(combined_set$FamilyId)
combined_set$FamilySizeGroup <- factor(combined_set$FamilySizeGroup)


library(rpart)
library(rattle)
library(RColorBrewer)
library(rpart.plot)
# fill missing value
fillAge <- rpart(Survived~Pclass+Mother+FamilySize+Sex+SibSp+Parch+Deck+Fare+
                   Embarked+Title+FamilyId+FamilySizeGroup,
                 data = combined_set[!is.na(combined_set$Age),], method = "anova")
combined_set$Age[is.na(combined_set$Age)] <- predict(fillAge, combined_set[is.na(combined_set$Age),])

summary(combined_set$Embarked)
which(combined_set$Embarked == "")
combined_set$Embarked[c(62, 830)] <- "S"

summary(combined_set$Fare)
combined_set$Fare[is.na(combined_set$Fare)] <- mean(combined_set$Fare, na.rm = TRUE)
library(mice)
library("lattice")

md.pattern(combined_set)
train <- combined_set[1:891,]
test <- combined_set[892:1309,]

dtree <- rpart(Survived~Pclass+Mother+FamilySize+Sex+SibSp+Parch+Deck+Fare+
                 Embarked+Title+FamilyId+FamilySizeGroup,
               data = combined_set, method = "class")
prediction6 <- predict(dtree, test, type = "class")
prediction_6 <- data.frame(PassengerId = test$PassengerId, Survived = prediction6 )
write.csv(prediction_6, file = "predictio6.csv", row.names = FALSE)

# Seven prediction

# load Random Forest packages
library("randomForest")


rftrain01 <- combined_set[1:891, c("Pclass", "Title")]
head(rftrain01)
rflabel <- as.factor(train$Survived)

fit1 <- randomForest(rftrain01, rflabel, ntree = 1000, importance = TRUE)

varImpPlot(fit1)
fit1
str(combined_set$FamilyId)

library("party")

train <- combined_set[1:891,]
test <- combined_set[892:1309,]

fit2 <- cforest(as.factor(Survived) ~ Pclass+Sex+Age+SibSp+Parch+Fare+Embarked+Title+
                  FamilySize+FamilyId, data = train, controls = cforest_unbiased(ntree = 2000, mtry = 3))

