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
sql_cmd <-"select * from vw_monthly_kw_used where kw_used>1"
source_data <- dbGetQuery(con, sql_cmd)
# Disconnect
dbDisconnect(con)

# Compute statistics
# example of summary statistics
source_data$data_month<- substring(source_data$date_mm, 1, 7)
# by 月
summary_data_1 <- source_data %>%
  group_by(data_month) %>%
  summarise(
    range= max(kw_used) - min(kw_used),
    max= max(kw_used),
    min= min(kw_used),
    counts = n(),
    sum_data = round(sum(kw_used),0),
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
# Visualizing with ggplot2 of summary_data (直方圖)
ggplot(summary_data_1, aes(x = data_month, y = sum_data)) +
  geom_col(position = "dodge",width=0.6) +
  geom_vline(aes(xintercept = mean), color = "red", linetype = "dashed") +
  labs(title = "每月用電量", y = "KW(度)", x = "年月") +
  scale_y_continuous(breaks = seq(0, 2400, by = 200))+
  geom_text(aes(label = sum_data, vjust = 1.5),color="white")+
  theme_minimal()
# by 機台
summary_data_2 <- source_data %>%
  group_by(data_month, asset_id) %>%
  summarise(
    range= max(kw_used) - min(kw_used),
    max= max(kw_used),
    min= min(kw_used),
    counts = n(),
    sum_data = sum(kw_used),
    mean = mean(kw_used),
    median = median(kw_used),
    Q1=quantile(kw_used, probs = 0.25),
    Q2=quantile(kw_used, probs = 0.5),
    Q3=quantile(kw_used, probs = 0.75),
    variance=var(kw_used),
    std_error = sd(kw_used) / sqrt(n()),
    cv=sd(kw_used) / mean(kw_used),
    .groups = "drop"
  )
# print(summary_w_hourly_data)
# Visualizing with ggplot2 of summary_data (直方圖)
ggplot(summary_data_2, aes(x = data_month, y = sum_data,fill = asset_id)) +
  geom_col(position = "dodge",width=0.8) +
  labs(title = "各機台每月用電量", y = "KW(度)", x = "年月") +
  scale_y_continuous(breaks = seq(0, 1500, by = 200))+
  theme_minimal()



