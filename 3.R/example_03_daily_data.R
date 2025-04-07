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
source_data<- filter(source_data,kw_used>0)
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
# Visualizing with ggplot2 of summary_data (直方圖)
ggplot(summary_data, aes(x = asset_name, y = mean)) +
  geom_col(fill = "lightblue",width=0.8) +
  geom_errorbar(aes(ymin = mean - std_error, ymax = mean + std_error), width = 0.1,color="blue") +
  geom_errorbar(aes(ymin = Q1, ymax = Q3), width = 0.2) +
  geom_point(aes(y = median), color = "red", size = 2) + 
  labs(title = "平均數,中位數(紅色)及標準差(藍色)", y = "KW(度)", x = "機台編號") +
  scale_y_continuous(breaks = seq(0, 5, by = 0.2))+
  theme_minimal()
# example of summary statistics
source_data<- filter(source_data,kw_used>0,(asset_id=="101-H35") | (asset_id=="103-B76")|(asset_id=="104-F13"))
summary_data <- source_data %>%
  group_by(hh) %>%
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
# Visualizing with ggplot2 of summary_data (圓餅圖)
# 計算百分比
summary_data$percentage <- round(summary_data$mean / sum(summary_data$mean) * 100, 1)
ggplot(summary_data, aes(x = "", y = mean, fill = hh)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(title = "圓餅圖(工作時)") +
  geom_label(aes(label = paste0(hh, " (", percentage, "%)")), position = position_stack(vjust = 0.1),size = 3)+
  #geom_text(aes(label = paste0(hh, " (", percentage, "%)")),position = position_stack(vjust = 0.5))+
  theme_void() 
#(長條圖)
summary_data$mean2 <- round(summary_data$mean,digits = 3)

ggplot(summary_data, aes(x = hh, y = percentage)) +
  geom_bar(stat = "identity", fill = "skyblue", width = 0.8) +
  labs(title = "長條圖(工作時)", x = "工作時", y = "佔比(%)") +
  scale_x_continuous(breaks = seq(7, 20, by = 1))+
  scale_y_continuous(breaks = seq(0, 20, by = 1))+
  geom_text(aes(label = mean2, vjust = -0.3))

# Visualizing with ggplot2 of filtered_data (折線圖)
filtered_data  <- filter(source_data,asset_id== "103-B76")
filtered_data  <- filter(filtered_data,date_hour>="2024-07-01",date_hour<="2024-12-31")
ggplot(filtered_data, aes(x = date_hour, y = kw_used)) +
  #geom_line() +
  geom_point(aes(y = kw_used), color = "red", size = 1) + 
  labs(title = "能耗(度)", x = "時間", y = "KW(度)") +
  scale_y_continuous(breaks = seq(1, 12, by = 1))+
  theme_minimal()

