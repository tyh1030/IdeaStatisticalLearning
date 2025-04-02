## Load useful libraries
#library("fixest")
#library("binsreg")
library("dplyr")
library("ggplot2")
library("DBI")
library("RPostgres")
library("yaml")
# 1. Load data
#setwd("./")
#ds_source = read.csv('./source.data/climate_mortality.csv') #replace with pathname in your computer
# Load configuration
config <- yaml::read_yaml("config.yml")
# Connect to the database
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = config$postgres$dbname,
  host = config$postgres$host,
  port = config$postgres$port,
  user = config$postgres$user,
  password = config$postgres$password
)
ds_source_V <- dbGetQuery(con, "select * from iotrawdata where instr_model='V257'")
ds_source_A <- dbGetQuery(con, "select * from iotrawdata where instr_model='I295'")
ds_source_W <- dbGetQuery(con, "select * from iotrawdata where instr_model='W349'")
# Disconnect
dbDisconnect(con)

# Compute statistics
summary_stats_V <- ds_source_V %>%
  group_by(asset_id) %>%
  summarise(
    mean = mean(rawvalue),
    median = median(rawvalue),
    std_error = sd(rawvalue) / sqrt(n())
  )

print(summary_stats_V)
# Visualizing with ggplot2


ggplot(summary_stats_V, aes(x = asset_id, y = mean)) +
  geom_col(fill = "lightblue") +
  geom_errorbar(aes(ymin = mean - std_error, ymax = mean + std_error), width = 0.2) +
  geom_point(aes(y = median), color = "red", size = 3) + 
  labs(title = "Mean, Median (Red Dots) and Standard Error",
       y = "Value",
       x = "Asset type") +
  theme_minimal()



