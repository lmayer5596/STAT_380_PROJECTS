source('./project/required/requirements.R')
source('./project/src/features/build_features.R')
source('./project/src/models/train_model.R')

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
predict_merge <- merge(test, predict, all.x = TRUE, by = c('Cond', 'Qual', 'FullBath', 'TotRmsAbvGrd'))

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

#changing