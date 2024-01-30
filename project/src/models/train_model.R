source('./project/src/features/build_features.R')

train <- fread('./project/volume/data/interim/train.csv')
test <- fread('./project/volume/data/interim/test.csv')
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

