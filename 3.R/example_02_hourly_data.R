## Load useful libraries
library("dplyr")
library("ggplot2")
library("DBI")
library("RPostgres")
library("yaml")
# 1. Load data
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
sql_cmd <-"select * from vw_houly_kw_used"
source_data <- dbGetQuery(con, sql_cmd)
# Disconnect
dbDisconnect(con)

# Compute statistics
# example of summary statistics
summary_data <- source_data %>%
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


