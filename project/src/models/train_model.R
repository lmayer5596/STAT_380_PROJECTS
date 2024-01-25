#takes the mean SalePrice from a group of the selected variables
predict <- train[,.(SalePrice = mean(SalePrice, na.rm = TRUE)), by = c('Cond', 'Qual', 'FullBath', 'TotRmsAbvGrd')]

#merges the previous table to the test data, this gives an average SalePrice to rows which match the specific groups from above
predict_merge <- merge(test, predict, all.x = TRUE, by = c('Cond', 'Qual', 'FullBath', 'TotRmsAbvGrd'))

#finds the mean SalePrice of all rows
mean_val <- train[, mean(SalePrice)]

#removes 'test_' from the Id column, turns the Id number into a numeric type, orders the rows by Id number, and pastes 'test_' before the Id number, then selects only Id and SalePrice columns
predict_merge <- predict_merge[, Id := as.numeric(substring(Id, 6))][order(Id)][, Id := str_glue('test_{as.character(Id)}')][, c('Id', 'SalePrice')]
#replaces any empty SalePrice cells with the mean of all rows
predict_merge <- predict_merge[is.na(SalePrice), SalePrice := mean_val]

#turns the final data.table into a csv for submission
fwrite(predict_merge, './project/volume/data/processed/prediction.csv')

