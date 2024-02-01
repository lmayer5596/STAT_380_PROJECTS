source('./project/required/requirements.R')
source('./project/src/features/build_features.R')
source('./project/src/models/train_model.R')

library(data.table)
library(stringr)

#CATEGORICAL GROUPING METHOD

#takes the mean SalePrice from a group of the selected variables
predict <- train[,.(SalePrice = mean(SalePrice, na.rm = TRUE)), by = c('Cond', 'FullBath', 'CentralAir')]
View(predict)
#merges the previous table to the test data, this gives an average SalePrice to rows which match the specific groups from above
predict_merge <- merge(test, predict, all.x = TRUE, by = c('Cond', 'FullBath', 'CentralAir'))

View(test)
#finds the mean SalePrice of all rows
mean_val <- train[, mean(SalePrice)]

#creates a number column for sorting purposes
predict_merge$sort_col <- gsub('test_', '', predict_merge$Id)
#turns the number into a numeric type
predict_merge$sort_col <- as.numeric(predict_merge$sort_col)
#orders the cases by number
predict_merge <- predict_merge[order(sort_col)]
#selects Id and SalePrice for submission
predict_merge <- predict_merge[, c('Id', 'SalePrice')]

#replaces any empty SalePrice cells with the mean of all rows
predict_merge <- predict_merge[is.na(SalePrice), SalePrice := mean_val]

#turns the final data.table into a csv for submission
fwrite(predict_merge, './project/volume/data/processed/prediction.csv')


#linear regression
#dummies <- dummyVars(SalePrice ~ ., data = all_data)
#train <- predict(dummies, newdata = train)
#test <- predict(dummies, newdata = test)

#LINEAR REGRESSION METHOD

#source('./project/required/requirements.R')

library(data.table)
library(caret)
library(Metrics)

#reads in the full data set
main_data <- fread("./project/volume/data/raw/Stat_380_housedata.csv")

#reads in the cond and qual data set
QC_data <- fread('./project/volume/data/raw/Stat_380_QC_table.csv')

#merges the two data sets by the qc_code
all_data <- merge(main_data, QC_data, all.x = TRUE)

#selects the rows which are labelled as train
train <- all_data[grep('^train', Id)][, .(LotArea, GrLivArea, CentralAir, Cond, Qual, SalePrice)]
#selects the rows which are labelled as test
test <- all_data[grep('^test', Id)][, .(Id, LotArea, GrLivArea, CentralAir, Cond, Qual, SalePrice)]
#makes all SalePrice values equal to 0
test$SalePrice <- 0

#creates a number column for sorting purposes
test$sort_col <- gsub('test_', '', test$Id)
#turns the number into a numeric type
test$sort_col <- as.numeric(test$sort_col)
#orders the cases by number
test <- test[order(sort_col)]

test <- test[, !c('Id', 'sort_col')]

format <- fread('./project/volume/data/raw/example_sub.csv')
format$SalePrice <- 0

fwrite(test, './project/volume/data/interim/test.csv')
fwrite(train, './project/volume/data/interim/train.csv')
fwrite(all_data, './project/volume/data/interim/all_data.csv')
fwrite(format, './project/volume/data/interim/format.csv')

source('./project/src/features/build_features.R')

train <- fread('./project/volume/data/interim/train.csv')
test <- fread('./project/volume/data/interim/test.csv')
format <- fread('./project/volume/data/interim/format.csv')
master <- rbind(test, train)

train_y <- train$SalePrice

dummies <- dummyVars(SalePrice ~ ., data = master)
train <- predict(dummies, newdata = train)
test <- predict(dummies, newdata = test)

train <- data.table(train)
train$SalePrice <- train_y
test <- data.table(test)

lm_model <- lm(SalePrice ~ ., data = train)

summary(lm_model)

saveRDS(dummies, './project/volume/models/SalePrice_lm.dummies')
saveRDS(lm_model, '.project/volume/models/SalePrice_lm.model')

test$SalePrice <- predict(lm_model, newdata = test)
View(test)

format$SalePrice <- test$SalePrice

#turns the final data.table into a csv for submission
fwrite(format, './project/volume/data/processed/prediction.csv')


#LOGISTIC REGRESSION

