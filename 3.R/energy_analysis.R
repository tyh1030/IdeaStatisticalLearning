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
ds_w_raw_data <- dbGetQuery(con, "select * from iotrawdata where instr_model='W349'")
ds_w_hourly_data <- dbGetQuery(con, "select * from vw_houly_kw_used")
ds_w_daily_data <- dbGetQuery(con, "select * from vw_daily_kw_used")
ds_w_monthly_data <- dbGetQuery(con, "select * from vw_monthly_kw_used")
# Disconnect
dbDisconnect(con)

# Compute statistics
# example of summary statistics--01
summary_w_raw_data <- ds_w_raw_data %>%
  group_by(asset_id) %>%
  summarise(
    range= max(rawvalue) - min(rawvalue),
    counts = n(),
    mean = mean(rawvalue),
    median = median(rawvalue),
    Q1=quantile(rawvalue, probs = 0.25),
    Q2=quantile(rawvalue, probs = 0.5),
    Q3=quantile(rawvalue, probs = 0.75),
    variance=var(rawvalue),
    std_error = sd(rawvalue) / sqrt(n()),
    cv=sd(rawvalue) / mean(rawvalue),
  )

# print(summary_w_raw_data)
# Visualizing with ggplot2

ggplot(summary_w_raw_data, aes(x = asset_id, y = mean)) +
  geom_col(fill = "lightblue") +
  geom_errorbar(aes(ymin = mean - std_error, ymax = mean + std_error), width = 0.2) +
  geom_point(aes(y = median), color = "red", size = 3) + 
  labs(title = "Mean, Median (Red Dots) and Standard Error",
       y = "Value",
       x = "Asset type") +
  theme_minimal()

# example of summary statistics--02
summary_w_hourly_data <- ds_w_hourly_data %>%
  group_by(asset_id) %>%
  summarise(
    range= max(kw_used) - min(kw_used),
    max= max(kw_used),
    min= min(kw_used),
    counts = n(),
    mean = mean(kw_used),
    median = median(kw_used),
    Q1=quantile(kw_used, probs = 0.25),
    Q2=quantile(kw_used, probs = 0.5),
    Q3=quantile(kw_used, probs = 0.75),
    variance=var(kw_used),
    std_error = sd(kw_used) / sqrt(n()),
    cv=sd(kw_used) / mean(kw_used),
  )
# print(summary_w_hourly_data)
# Visualizing with ggplot2
ggplot(ds_w_hourly_data, aes(x = date_hour, y = kw_used)) +
  geom_col(fill = "lightblue") +
  geom_point(aes(y = kw_used), color = "blue", size = 1) + 
  labs(title = "KW used by Hour",
       y = "kw",
       x = "Time") +
  theme_minimal()
# example of summary statistics--03
summary_w_daily_data <- ds_w_daily_data %>%
  group_by(asset_id,weekday) %>%
  summarise(
    range= max(kw_used) - min(kw_used),
    max= max(kw_used),
    min= min(kw_used),
    counts = n(),
    mean = mean(kw_used),
    median = median(kw_used),
    Q1=quantile(kw_used, probs = 0.25),
    Q2=quantile(kw_used, probs = 0.5),
    Q3=quantile(kw_used, probs = 0.75),
    variance=var(kw_used),
    std_error = sd(kw_used) / sqrt(n()),
    cv=sd(kw_used) / mean(kw_used),
    .groups = "drop"  # remove grouping in the result
  )
ggplot(summary_w_daily_data, aes(x = weekday, y = mean,fill=asset_id)) +
  geom_col(position = "dodge") +
  facet_wrap(~ asset_id) +
  scale_x_continuous(
    breaks = seq(0, 6, by = 1),   # per breaks
    limits = c(0, 6)               # range
  ) +
  labs(title = "Mean, Median (Red Dots) and Standard Error",
       y = "kw",
       x = "weekday per week") +
  theme_minimal()
## 2
ggplot(ds_w_daily_data, aes(x = date_dd, y = kw_used)) +
  geom_col(fill = "lightblue") +
  geom_point(aes(y = kw_used), color = "blue", size = 1) + 
  labs(title = "KW used by days",
       y = "kw",
       x = "Time") +
  theme_minimal()


