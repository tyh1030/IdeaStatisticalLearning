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
sql_cmd <-"select A.*,B.asset_name from vw_houly_kw_used A join asset B on A.asset_id=B.asset_id"
#sql_cmd <-"select * from vw_houly_kw_used"
source_data <- dbGetQuery(con, sql_cmd)
# Disconnect
dbDisconnect(con)

# Compute statistics
# example of summary statistics
summary_data <- source_data %>%
  group_by(asset_id,asset_name) %>%
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
# Visualizing with ggplot2 of summary_data
ggplot(summary_data, aes(x = asset_id, y = mean)) +
  geom_col(fill = "lightblue") +
  geom_errorbar(aes(ymin = mean - std_error, ymax = mean + std_error), width = 0.2) +
  geom_point(aes(y = median), color = "red", size = 2) + 
  labs(title = "平均數,中位數(紅色)及標準差", y = "KW(度)", x = "機台編號") +
  scale_y_continuous(breaks = seq(0, 3, by = 0.1))+
  theme_minimal()
# Visualizing with ggplot2
ggplot(source_data, aes(x = date_hour, y = kw_used)) +
  #geom_col(fill = "lightblue") +
  geom_line() +
  geom_point(aes(y = kw_used), color = "blue", size = 1) + 
  labs(title = "每小時用電度數",y = "KW(度)", x = "時間") +
  scale_y_continuous(breaks = seq(0, 15, by = 1))+
  scale_x_datetime(date_breaks = "7 day", date_labels = "%y'-%m-%d") +
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


