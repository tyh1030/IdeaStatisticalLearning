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

soure_data <- dbGetQuery(con, "select * from iotrawdata where instr_model='W349'")
# Disconnect
dbDisconnect(con)

# Compute statistics
summary_data <- soure_data %>%
  group_by(asset_id) %>%
  summarise(
    range= max(rawvalue) - min(rawvalue),
    max= max(kw_used),
    min= min(kw_used),
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
# 1 Visualizing with ggplot2 of soure_data
ggplot(soure_data, aes(x = createtime, y = rawvalue)) +
  geom_boxplot() +
  labs(title = "Boxplot of Raw Data",
       y = "kw Value",
       x = "time") +
  theme_minimal()
# 2 Visualizing with ggplot2 of summary_data
ggplot(summary_data, aes(x = asset_id, y = mean)) +
  geom_col(fill = "lightblue") +
  geom_errorbar(aes(ymin = mean - 2*std_error, ymax = mean + 2*std_error), width = 0.2) +
  geom_point(aes(y = median), color = "red", size = 2) + 
  labs(title = "Mean, Median (Red Dots) and Standard Error",
       y = "kw value",
       x = "Asset type") +
  theme_minimal()
