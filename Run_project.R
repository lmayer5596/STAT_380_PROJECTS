library(data.table)
library(stringr)

#reads in the full data set
main_data <- fread("./project/volume/data/raw/Stat_380_housedata.csv")

#reads in the cond and qual data set
QC_data <- fread('./project/volume/data/raw/Stat_380_QC_table.csv')

#merges the two data sets by the qc_code
all_data <- merge(main_data, QC_data, all.x = TRUE)
fwrite(all_data, './project/volume/data/interim/all_data.csv')

#selects the rows which are labelled as train
train <- all_data[grep('^train', Id)]

#selects the rows which are labelled as test AND removes the empty SalePrice column
test <- all_data[grep('^test', Id)][, !('SalePrice')]

#takes the mean SalePrice from a group of the selected variables
predict <- train[,.(SalePrice = mean(SalePrice, na.rm = TRUE)), by = c('Cond', 'Qual', 'FullBath', 'TotRmsAbvGrd')]

#merges the previous table to the test data, this gives an average SalePrice to rows which match the specific groups from above
predict_merge <- merge(predict, test, all.y = TRUE, by = c('Cond', 'Qual', 'FullBath', 'TotRmsAbvGrd'))

#finds the mean SalePrice of all rows
mean_val <- train[, mean(SalePrice)]

#removes 'test_' from the Id column, turns the Id number into a numeric type, orders the rows by Id number, and pastes 'test_' before the Id number, then selects only Id and SalePrice columns
predict_merge <- predict_merge[, Id := as.numeric(substring(Id, 6))][order(Id)][, Id := str_glue('test_{as.character(Id)}')][, c('Id', 'SalePrice')]
#replaces any empty SalePrice cells with the mean of all rows
predict_merge <- predict_merge[is.na(SalePrice), SalePrice := mean_val]

#turns the final data.table into a csv for submission
fwrite(predict_merge, './project/volume/data/processed/prediction.csv')




