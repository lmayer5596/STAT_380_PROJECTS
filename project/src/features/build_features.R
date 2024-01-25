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