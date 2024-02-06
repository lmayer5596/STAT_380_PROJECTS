#reads in interim data
train <- fread('./project/volume/data/interim/train.csv')
test <- fread('./project/volume/data/interim/test.csv')
format <- fread('./project/volume/data/interim/format.csv')
#combines test and train data with only chosen variables
master <- rbind(test, train)

#saves SalePrice of training data
train_y <- train$SalePrice

#saves dummy variables for test and train
dummies <- dummyVars(SalePrice ~ ., data = master)
train <- predict(dummies, newdata = train)
test <- predict(dummies, newdata = test)

#puts the variables into data.table format
train <- data.table(train)
train$SalePrice <- train_y
test <- data.table(test)

#creates model using train data
lm_model <- lm(SalePrice ~ ., data = train)

#saves models into appropriate folder
saveRDS(dummies, './project/volume/models/SalePrice_lm.dummies')
saveRDS(lm_model, './project/volume/models/SalePrice_lm.model')

#predicts SalePrice on test data
test$SalePrice <- predict(lm_model, newdata = test)

#adds predictions to final submission format
format$SalePrice <- test$SalePrice

#turns the final data.table into a csv for submission
fwrite(format, './project/volume/data/processed/prediction.csv')

