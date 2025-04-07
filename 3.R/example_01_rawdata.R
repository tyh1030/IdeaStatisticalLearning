## Load useful libraries
library("dplyr")
library("ggplot2")
library("DBI")
library("RPostgres")
# 1.Load data
# Connect to the database
con <- dbConnect(RPostgres::Postgres(),
                 dbname = "db_iot",
                 host = "127.0.0.1",
                 port = 5432,
                 user = "iscom",
                 password = "7o598966")
sql_cmd <-"select * from iotrawdata where instr_model='W349'"
source_data <- dbGetQuery(con, sql_cmd)
# Disconnect
dbDisconnect(con)

# Compute statistics
summary_data <- source_data %>%
  group_by(asset_id) %>%
  summarise(
    range= max(rawvalue) - min(rawvalue),
    max= max(rawvalue),
    min= min(rawvalue),
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
# Visualizing with ggplot2 of summary_data
ggplot(summary_data, aes(x = asset_id, y = mean)) +
  geom_col(fill = "lightblue") +
  geom_errorbar(aes(ymin = min - std_error, ymax = max + std_error), width = 0.2) +
  geom_point(aes(y = median), color = "red", size = 2) + 
  labs(title = "平均數,中位數(紅色)及標準差",
       y = "KW(度)",
       x = "機台編號") +
  theme_minimal()
# example of filter data
filtered_data  <- filter(source_data,asset_id== "103-B76")
filtered_data  <- filter(filtered_data,createtime>="2024-10-1",createtime<="2024-10-31")
# Visualizing with ggplot2 of filtered_data
ggplot(filtered_data, aes(x = createtime, y = rawvalue)) +
  geom_line() +
  labs(title = "用電累計圖(度)", x = "時間", y = "KW(度)") +
  scale_y_continuous(breaks = seq(4000, 5000, by = 100))+
  scale_x_datetime(date_breaks = "2 day", date_labels = "%y'-%m-%d") +
  theme_minimal()
  
