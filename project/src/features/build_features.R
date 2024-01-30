#source('./project/required/requirements.R')

library(data.table)
library(stringr)
library(caret)
library(Metrics)

#reads in the full data set
main_data <- fread("./project/volume/data/raw/Stat_380_housedata.csv")

#reads in the cond and qual data set
QC_data <- fread('./project/volume/data/raw/Stat_380_QC_table.csv')

#merges the two data sets by the qc_code
all_data <- merge(main_data, QC_data, all.x = TRUE)

#selects the rows which are labelled as train
train <- all_data[grep('^train', Id)][, .(qc_code, LotArea, TotalBsmtSF, GrLivArea, SalePrice)]
#selects the rows which are labelled as test
test <- all_data[grep('^test', Id)][, .(qc_code, LotArea, TotalBsmtSF, GrLivArea, SalePrice)]
#makes all SalePrice values equal to 0
test$SalePrice <- 0

fwrite(test, './project/volume/data/interim/test.csv')
fwrite(train, './project/volume/data/interim/train.csv')
fwrite(all_data, './project/volume/data/interim/all_data.csv')
