# find documentation here:
# https://www.ncei.noaa.gov/data/global-summary-of-the-year/doc/
# https://www.ncei.noaa.gov/data/global-summary-of-the-month/doc/

#yearly data
muc <- read.csv("attic/datasets/GM000004199.csv")

# DT32 Number of days with minimum temperature <= 32 degrees Fahrenheit/0 degrees Celsius
# DT32 Number of days with maximum temperature <= 32 degrees Fahrenheit/0 degrees Celsius
plot(muc$DATE, muc$DT32, type = "l", ylim = c(0,150))
lines(muc$DATE,muc$DX32, col = "red")

#monthly datas
muc_month <- read.csv("attic/datasets/GM000004199_month.csv")

muc_month$datum <- as.Date(paste0(muc_month$DATE, "-01"), format = "%Y-%m-%d")
plot(muc_month$datum, muc_month$DT32, type = "l")


# metric
muc_metric <- read.csv("attic/datasets/2028671.csv")
