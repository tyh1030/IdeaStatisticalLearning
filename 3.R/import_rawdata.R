library(DBI)
library(RPostgres)
# 1. set the import file path and the postgresql connection 
##### the path of testing data
#setwd("./")
getwd()
##### the the postgresql connection 
con <- dbConnect(RPostgres::Postgres(),
                 dbname = "db_iot",
                 host = "127.0.0.1",
                 port = 5432,
                 user = "iscom",
                 password = "7o598966")
# 2. Load data and import it which the action automatically create the table schema and the data
##### import iot raw data
a_panel_data = read.csv('./import_data.csv')
dbWriteTable(con, "iotrawdata", a_panel_data, overwrite = FALSE, append = TRUE)

# Disconnect
dbDisconnect(con)





























