# ==============================================================================
# <name>.R - <description>
# ==============================================================================

# ------------------------------------------------------------------------------
# AUTORS
# ------------------------------------------------------------------------------

# Iris Lüthi
# Maja Velkova
# Yannik Zimmermann

# ------------------------------------------------------------------------------
# PACKAGES
# ------------------------------------------------------------------------------

# Package installs
#install.packages('weathermetrics')
#install.packages('dplyr')
#install.packages('lubridate')
#install.packages('ggplot2')
#install.packages('usmap')
#install.packages('forecast')

# Load librarys

library(readr)

# CheatSheet - https://journalismcourses.org/wp-content/uploads/2020/08/data-transformation.pdf
library(dplyr)

# CheatSheet - https://github.com/rstudio/cheatsheets/blob/main/tidyr.pdf
library(tidyr)

# CheatSheet - https://rawgit.com/rstudio/cheatsheets/main/lubridate.pdf
library(lubridate)

# CheatSheet - https://github.com/rstudio/cheatsheets/blob/main/data-visualization-2.1.pdf
library(ggplot2)

# Generate Maps with usmap = https://cran.r-project.org/web/packages/usmap/vignettes/mapping.html
library(usmap)

# library(weathermetrics)

# How to Forecast https://www.simplilearn.com/tutorials/data-science-tutorial/time-series-forecasting-in-r
library(forecast)

# ------------------------------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------

# --- setup environment

# --- read input
# https://www.kaggle.com/datasets/sobhanmoosavi/us-weather-events
raw_weather_events <- read_csv("WeatherEvents_Jan2016-Dec2021.csv")
# https://www.kaggle.com/datasets/sogun3/uspollution
raw_pollution_data <- read_csv("pollution_2000_2021.csv")
# https://www.kaggle.com/datasets/sudalairajkumar/daily-temperature-of-major-cities
raw_city_temps <- read_csv("city_temperature.csv")
# https://www.kaggle.com/datasets/threnjen/40-years-of-air-quality-index-from-the-epa-daily
raw_air_quality_index <- read_csv("aqi_daily_1980_to_2021.csv")

# ------------------
# Analyse Temperature in major Cities
# ------------------

# Get structure of the file
head(raw_city_temps)
dim(raw_city_temps)

# Summarize columns of city_temps
summary(raw_city_temps)

# Get counts of NA Values for Columns
colSums(is.na(raw_city_temps))

# get identical columns in file
sum(duplicated(raw_city_temps))

# Understand temperature values
hist(raw_city_temps$AvgTemperature)
unique(raw_city_temps$Year)

# get number of observations by year
raw_city_temps %>% 
  group_by(Year) %>% count()

# check available regions
raw_city_temps %>% distinct(Region)

# View(city_temps %>% count(Year))

# ------------------
# Preprocess Temperature in major Cities
# ------------------

# Remove State column because it is mostly empty and not used
# city_temps = select(raw_city_temps, -State)

city_temps = raw_city_temps %>% 
  # remove duplicates
  distinct() %>% 
  # remove temp values below -50f
  filter(AvgTemperature > -50) %>% 
  # remove values where year is below 1950 because those are probably typos
  filter(Year > 1950) %>% 
  # remove year 2020 because of n of observations
  filter(Year != 2020)

# Add new column for temp in celcius
city_temps['AvgTemperatureInCelcius'] = fahrenheit.to.celsius(city_temps$AvgTemperature)

hist(city_temps$AvgTemperatureInCelcius)

# ------------------
# Plot Temperature in major Cities
# ------------------

cbp1 <- c("#000000", "#E69F00", "#56B4E9", "#009E73",
          "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

city_temps %>%
  group_by(Year) %>%
  summarize_at(vars(AvgTemperatureInCelcius), list(AvgTemp=mean)) %>%
  ggplot(aes(Year,AvgTemp)) + 
  geom_smooth() + 
  geom_line()

city_temps %>% 
  group_by(Year, Region) %>%
  summarise_at(vars(AvgTemperatureInCelcius), list(AvgTemp=mean)) %>%
  ggplot(aes(Year, AvgTemp, group=Region, color=Region)) + 
  geom_line() + 
  geom_smooth(method=lm) +
  scale_colour_manual(values=cbp1)

city_temps %>%
  filter(Region == 'North America') %>%
  group_by(Year) %>%
  summarise_at(vars(AvgTemperatureInCelcius), list(AvgTemp=mean)) %>%
  ggplot(aes(Year,AvgTemp)) + 
  # geom_line() + 
  geom_smooth() +
  ylim(10, 17)

# ------------------
# Analyse AQI across the world
# ------------------

# Get structure of the file
head(raw_air_quality_index)
dim(raw_air_quality_index)

summary(raw_air_quality_index)

# Get counts of NA Values for Columns
colSums(is.na(raw_air_quality_index))

sum(duplicated(raw_air_quality_index))

hist(raw_air_quality_index$AQI)

unique(raw_air_quality_index$`Defining Parameter`)
unique(raw_air_quality_index$Category)
unique(year(raw_air_quality_index$Date))

raw_air_quality_index %>%
  group_by(Year = year(Date)) %>%
  count() %>%
  ggplot(aes(Year, n)) + 
  geom_col()

# ------------------
# Preprocess AQI
# ------------------

air_quality_index = raw_air_quality_index %>% 
  # distinct() %>% 
  filter(year(Date) != 2021)

air_quality_index %>%
  group_by(Category) %>%
  summarise_at(vars(AQI), list(r = range))

# ------------------
# Plot AQI
# ------------------

air_quality_index %>%
  group_by(Category, Year = year(Date)) %>%
  count() %>%
  ggplot(aes(Year, n, group=Category, color=Category)) + 
  geom_line()

air_quality_index %>%
  group_by(Year = year(Date)) %>%
  summarize_at(vars(AQI), list(m=mean)) %>%
  ggplot(aes(Year, m)) +
  geom_line() + 
  geom_smooth()

map_data_aqi_mean = air_quality_index %>%
  group_by(state=`State Name`) %>%
  summarize_at(vars(AQI, Latitude, Longitude), list(m=mean))

plot_usmap(data=map_data_aqi_mean, values="AQI_m") +
  scale_fill_continuous(name= "AQI", low="#FF160C", high="#8B0000") +
  # labs(title = "Western US States") +
  theme(legend.position = "right")

# ------------------
# Preprocess Pollution Data
# ------------------

head(raw_pollution_data)
dim(raw_pollution_data)

# Summarize columns of city_temps
summary(raw_pollution_data)

# Get counts of NA Values for Columns
colSums(is.na(raw_pollution_data))

# get identical columns in file
sum(duplicated(raw_pollution_data))

# Understand temperature values
hist(raw_pollution_data$`O3 Mean`)
hist(raw_pollution_data$`CO Mean`)
hist(raw_pollution_data$`SO2 Mean`)
hist(raw_pollution_data$`NO2 Mean`)
unique(raw_pollution_data$Year)

length(unique(raw_pollution_data$State))

# get number of observations by year
raw_pollution_data %>% 
  distinct() %>%
  group_by(Year) %>% count() %>%
  ggplot() +
  geom_col(aes(Year, n))

raw_pollution_data %>% 
  filter(State == "California") %>% 
  #filter(State == "New Jersey") %>% 
  group_by(Year) %>%
  summarize_at(vars(`O3 Mean`, `CO Mean`, `SO2 Mean`, `NO2 Mean`), list(m=mean)) %>%
  ggplot() +
  geom_smooth(aes(Year,`O3 Mean_m`, color="O3 Mean")) +
  geom_smooth(aes(Year,`CO Mean_m`, color="CO Mean")) +
  geom_smooth(aes(Year,`SO2 Mean_m`, color="SO2 Mean")) +
  geom_smooth(aes(Year,`NO2 Mean_m`, color="NO2 Mean")) +
  labs(x="Year", y="Mean", color="Gas") 


raw_pollution_data %>% 
  filter(State == "Maine") %>% 
  #filter(State == "North Dakota") %>%
  group_by(Year) %>%
  summarize_at(vars(`O3 Mean`, `CO Mean`, `SO2 Mean`, `NO2 Mean`), list(m=mean)) %>%
  ggplot() +
  geom_smooth(aes(Year,`O3 Mean_m`, color="O3 Mean")) +
  geom_smooth(aes(Year,`CO Mean_m`, color="CO Mean")) +
  geom_smooth(aes(Year,`SO2 Mean_m`, color="SO2 Mean")) +
  geom_smooth(aes(Year,`NO2 Mean_m`, color="NO2 Mean")) +
  labs(x="Year", y="Mean", color="Gas") 


# ------------------
# Application of ML and Forecasting
# ------------------

temp_data = city_temps %>% 
  filter(Country == 'US') %>% 
  filter(Year != 2020) %>% 
  group_by(Year, Month) %>%
  summarize_at(vars(AvgTemperatureInCelcius), list(mean=mean))

temp_data = city_temps %>% 
  filter(Country == 'US') %>% 
  filter(Year != 2020) %>% 
  group_by(Year) %>%
  summarize_at(vars(AvgTemperatureInCelcius), list(mean=mean))

plot(temp_data)

tsdata <- ts(temp_data$mean, frequency = 12) 
ddata <- decompose(tsdata, "multiplicative")

plot(ddata)
plot(ddata$trend)
plot(ddata$seasonal)
plot(ddata$random)

data_to_timeseries = ts(temp_data$mean, frequency = 1, start = c(1995,1))

model_from_timeseries <- auto.arima(data_to_timeseries)

myforecast <- forecast(model_from_timeseries, level=c(40), h=12*10)
plot(myforecast)

autoplot(myforecast)
autoplot(myforecast) + geom_forecast(h=50)
autoplot(ddata)
ggseasonplot(tsdata)





air_quality_ts_raw = air_quality_index %>%
  group_by(Year = year(Date), Month = month(Date)) %>%
  summarize_at(vars(AQI), list(Mean=mean))

tsdata_aqi = ts(air_quality_ts_raw$Mean, frequency = 12)
ddata_aqi = decompose(tsdata_aqi, "multiplicative")
autoplot(ddata_aqi)

model_from_timeseries_aqi = auto.arima(tsdata_aqi)
aqi_forecast = forecast(model_from_timeseries_aqi, level = c(95), h=12*10)
autoplot(aqi_forecast)


# --- preprocess

# --- analyse

# --- visualise

# --- save output

# ==============================================================================
# END <name>.R
# ==============================================================================

