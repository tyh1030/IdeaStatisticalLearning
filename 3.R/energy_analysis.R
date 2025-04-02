## Load useful libraries
library("ggplot2")
library("fixest")
library("dplyr")
library("DBI")
library("RPostgres")
library("binsreg")
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
ds_source <- dbGetQuery(con, "select * from iotrawdata where instr_model='W349'")
# Disconnect
dbDisconnect(con)
