#GROUPING BY CATEGORICAL VARIABLES WITH GROUP MEANS

#takes the mean SalePrice from a group of the selected variables
predict <- train[,.(SalePrice = mean(SalePrice, na.rm = TRUE)), by = c('Cond', 'FullBath', 'CentralAir')]
#merges the previous table to the test data, this gives an average SalePrice to rows which match the specific groups from above
predict_merge <- merge(test, predict, all.x = TRUE, by = c('Cond', 'FullBath', 'CentralAir'))

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