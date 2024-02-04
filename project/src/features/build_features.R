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
train <- all_data[grep('^train', Id)][, .(YearBuilt, LotArea, GrLivArea, CentralAir, TotalBsmtSF, Qual, SalePrice)]
#selects the rows which are labelled as test
test <- all_data[grep('^test', Id)][, .(Id, YearBuilt, LotArea, GrLivArea, CentralAir, TotalBsmtSF, Qual, SalePrice)]
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

