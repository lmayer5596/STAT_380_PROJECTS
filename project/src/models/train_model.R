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

