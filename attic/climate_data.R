# find documentation here:
# https://www.ncei.noaa.gov/data/global-summary-of-the-year/doc/
# https://www.ncei.noaa.gov/data/global-summary-of-the-month/doc/
# https://www.ncei.noaa.gov/data/global-summary-of-the-month/doc/GSOMReadme.txt


#monthly datas
#muc <- read.csv("attic/datasets/GM000004199_month.csv")
muc = read.csv("https://www.ncei.noaa.gov/data/global-summary-of-the-month/access/GM000004199.csv")
nyc = read.csv("https://www.ncei.noaa.gov/data/global-summary-of-the-month/access/USW00094728.csv")


#keep information on station , temp and precipitation
muc = muc[, c("STATION", "DATE", "LATITUDE", "LONGITUDE","ELEVATION","NAME", "PRCP", "TAVG", "TMIN", "TMAX")]
nyc = nyc[, c("STATION", "DATE", "LATITUDE", "LONGITUDE","ELEVATION","NAME", "PRCP", "TAVG", "TMIN", "TMAX")]

#add day to date, so it can be converted to date
muc$DATE_DAY <- as.Date(paste0(muc$DATE, "-01"), format = "%Y-%m-%d")





# load via api ------------------------------------------------------------
# Get an API key (aka, token) at http://www.ncdc.noaa.gov/cdo-web/token. You can pass your
# token in as an argument or store it one of two places:
# • your .Rprofile file with an entry like options(noaakey = "your-noaa-token")
# • your .Renviron file with an entry like NOAA_KEY=your-noaa-token




library(rnoaa)
options(noaakey =  "lpaAYwWdeBAapeFUXELdcLSrStdXDfrw")

locations <- ncdc_locs(locationcategoryid = 'CITY', sortfield = 'name', sortorder = 'desc', limit = 500)

loc <- locations$data

ncdc_stations("GHCND:GM000004199")

#date range only 10 years

data <- ncdc(datasetid = "GSOM", stationid = "GHCND:GM000004199",
             startdate = "1990-01-01", enddate = "2000-01-01",
             datatypeid = c("TAVG", "TMAX", "TMIN"), limit = 1000)
data_1 <-data$data

data_wide <- tidyr::spread(data_1[,1:4], datatype, value)

out <- ncdc(datasetid='NORMAL_DLY', stationid='GHCND:USW00014895', datatypeid='dly-tmax-normal', startdate = '2010-05-01', enddate = '2010-05-10')

out$data

stations <- ghcnd_stations()

stat_ger <- stations[grepl("^GM", stations$id),]
stat_ger



### rndaa is inconsistent (station ids are not only id but sometimes there are prefixes like "ghcnd")
#it  allows a max of 10 years of data. -> not to recommend

#use new york as well 	GHCND:USW00094728



# Preferred acces
# https://www.ncei.noaa.gov/access/search/data-search/global-summary-of-the-month
# -> list view
# -> click on name

#
# if station id is know, this is also possible
# go to https://www.ncei.noaa.gov/data/global-summary-of-the-month/access/
# and add <stationid>.csv to url -> direct download
