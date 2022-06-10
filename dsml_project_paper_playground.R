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

# ------------------
# Package installs
# ------------------

#install.packages('readr')
#install.packages('dplyr')
#install.packages('tidyr')
#install.packages('lubridate')
#install.packages('ggplot2')
#install.packages('usmap')
#install.packages('forecast')
#install.packages('caret')

# ------------------
# Load librarys
# ------------------

library(readr)
# CheatSheet - https://journalismcourses.org/wp-content/uploads/2020/08/data-transformation.pdf
library(dplyr)
# CheatSheet - https://github.com/rstudio/cheatsheets/blob/main/tidyr.pdf
library(tidyr)
# CheatSheet - https://rawgit.com/rstudio/cheatsheets/main/lubridate.pdf
library(lubridate)
library(broom)
# CheatSheet - https://github.com/rstudio/cheatsheets/blob/main/data-visualization-2.1.pdf
library(ggplot2)
# Generate Maps with usmap = https://cran.r-project.org/web/packages/usmap/vignettes/mapping.html
library(usmap)
# How to Forecast https://www.simplilearn.com/tutorials/data-science-tutorial/time-series-forecasting-in-r
library(forecast)
library(caret)
# Used for easy fahrenheit to celsius conversion
library(weathermetrics)

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------

# ------------------
# Setup Environment
# ------------------

color_palette <- c("#000000", "#E69F00", "#56B4E9", "#009E73",
                   "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
primary_color = "#009E73"
secondary_color = "#D55E00"

# ------------------
# Read input
# ------------------

# https://www.kaggle.com/datasets/sobhanmoosavi/us-weather-events
# raw_weather_events <- read_csv("WeatherEvents_Jan2016-Dec2021.csv")
# https://www.kaggle.com/datasets/sogun3/uspollution
raw_pollution_data <- read_csv("pollution_2000_2021.csv")
# https://www.kaggle.com/datasets/sudalairajkumar/daily-temperature-of-major-cities
raw_city_temps <- read_csv("city_temperature.csv")
# https://www.kaggle.com/datasets/threnjen/40-years-of-air-quality-index-from-the-epa-daily
raw_air_quality_index <- read_csv("aqi_daily_1980_to_2021.csv")

# ------------------
# Preprocess raw_city_temps
# ------------------

# Get information about the structure of the file
head(raw_city_temps)
dim(raw_city_temps)

# Summarize columns of city_temps
summary(raw_city_temps)

# Get counts of NA Values for columns
colSums(is.na(raw_city_temps))

# get count of identical columns in file (quite heavy calculation)
# sum(duplicated(raw_city_temps))

# Understand temperature values
hist(raw_city_temps$AvgTemperature)

# See all years where data was gathered
unique(raw_city_temps$Year)

# Get number of observations by year
raw_city_temps %>% 
  group_by(Year) %>% count()

# Check available regions
raw_city_temps %>% distinct(Region)


# Data preprocessing for further analysis
city_temps = raw_city_temps %>% 
  # remove duplicates
  distinct() %>% 
  # remove temp values below -50f because they seem like default/null values
  filter(AvgTemperature > -50) %>% 
  # remove values where year is below 1950 because those are probably typos (200, etc)
  filter(Year > 1950) %>% 
  # remove year 2020 because of really low number of observations
  filter(Year != 2020)

# Compute additional celsius average temperature column for easy understanding
city_temps['AvgTemperatureInCelsius'] = fahrenheit.to.celsius(city_temps$AvgTemperature)

hist(city_temps$AvgTemperatureInCelsius)

# ------------------
# Preprocess raw_air_quality_index
# ------------------

# Get structure of the file
head(raw_air_quality_index)
dim(raw_air_quality_index)

# Summarize columns of raw_air_quality_index
summary(raw_air_quality_index)

# Get counts of NA Values for Columns
colSums(is.na(raw_air_quality_index))

# Get number of duplicated rows (quite heavy calculation)
# sum(duplicated(raw_air_quality_index))

# Get an understanding of logged AQI measures
hist(raw_air_quality_index$AQI)

# Check for available values of different columns
unique(raw_air_quality_index$`Defining Parameter`)
unique(raw_air_quality_index$Category)
unique(year(raw_air_quality_index$Date))

# Understand logged observations of AQI measurements
raw_air_quality_index %>%
  group_by(Year = year(Date)) %>%
  count() %>%
  ggplot(aes(Year, n)) + 
  geom_col()

# Remove Year 2021 because of low count of observations
air_quality_index = raw_air_quality_index %>% 
  filter(year(Date) != 2021)

# Understand range of AQI measurements and the corresponding category
air_quality_index %>%
  group_by(Category) %>%
  summarise_at(vars(AQI), list(r = range))

# ------------------
# Preprocess Pollution Data
# ------------------

# Get structure of the file
head(raw_pollution_data)
dim(raw_pollution_data)

# Summarize columns of raw_pollution_data
summary(raw_pollution_data)

# Get counts of NA Values for Columns
colSums(is.na(raw_pollution_data))

# Get identical columns in file (quite heavy calculation)
# sum(duplicated(raw_pollution_data))

# Understand gathered values for different pollution gases
hist(raw_pollution_data$`O3 Mean`)
hist(raw_pollution_data$`CO Mean`)
hist(raw_pollution_data$`SO2 Mean`)
hist(raw_pollution_data$`NO2 Mean`)
unique(raw_pollution_data$Year)

# Understand logged observations of Pollution measurements
raw_pollution_data %>%
  group_by(Year = year(Date)) %>%
  count() %>%
  ggplot(aes(Year, n)) + 
  geom_col()

pollution_data = raw_pollution_data %>% 
  # remove duplicates
  distinct() %>%
  # remove measurements from 2021
  filter(year(Date) != 2021)

# ------------------
# Analyse and visualize Temperature in major Cities
# ------------------

city_temps %>%
  group_by(Year) %>%
  summarize_at(vars(AvgTemperatureInCelsius), list(AvgTemp=mean)) %>%
  ggplot(aes(Year,AvgTemp)) + 
  geom_smooth(method = 'loess', formula = 'y ~ x') + 
  geom_line() +
  labs(x="Jahr", y="Durchschnittstemperatur in Celsius", title = "Gemessene Durchschnittstemperatur in Grossstädten rund um die Erde") 

city_temps %>% 
  group_by(Year, Region) %>%
  summarise_at(vars(AvgTemperatureInCelsius), list(AvgTemp=mean)) %>%
  ggplot(aes(Year, AvgTemp, group=Region, color=Region)) + 
  geom_line() + 
  geom_smooth(method='loess', formula = 'y ~ x') +
  scale_colour_manual(values=color_palette) +
  labs(x="Jahr", y="Durchschnittstemperatur in Celsius", title = "Gemessene Durchschnittstemperatur in Grossstädten gruppiert nach Kontinenten") 

city_temps %>%
  filter(Region == 'North America') %>%
  group_by(Year) %>%
  summarise_at(vars(AvgTemperatureInCelsius), list(AvgTemp=mean)) %>%
  ggplot(aes(Year,AvgTemp)) + 
  geom_line() + 
  geom_smooth(method = 'loess', formula = 'y ~ x') +
  ylim(10, 17) +
  labs(x="Jahr", y="Durchschnittstemperatur in Celsius", title = "Verlauf der gemessenen Durchschnittstemperatur in Nord Amerika") 

# ------------------
# Analyse and visualize AQI
# ------------------

air_quality_index %>%
  group_by(Category, Year = year(Date)) %>%
  count() %>%
  ggplot(aes(Year, n, group=Category, color=Category)) + 
  geom_line() +
  labs(x="Jahr", y="Anzahl Messungen", title = "Anzahl Messungen des AQI gruppiert nach Kategorie") 

air_quality_index %>%
  group_by(Year = year(Date)) %>%
  summarize_at(vars(AQI), list(m=mean)) %>%
  ggplot(aes(Year, m)) +
  geom_line() + 
  geom_smooth(method = 'loess', formula = 'y ~ x') +
  labs(x="Jahr", y="Durchnittlicher AQI", title = "Verlauf des Durchschnitt-AQI's") 

# Prepare data for map graph
map_data_aqi_mean = air_quality_index %>%
  group_by(state=`State Name`) %>%
  summarize_at(vars(AQI, Latitude, Longitude), list(m=mean))

plot_usmap(data=map_data_aqi_mean, values="AQI_m") +
  scale_fill_continuous(name= "AQI", low=primary_color, high=secondary_color) +
  theme(legend.position = "right") + 
  labs(title = "AQI Durchschnittswerte aufgeteilt in amerikanische Staaten") 

# ------------------
# Analyse and visualize Pollution
# ------------------

# Filter could be adjusted to show a different state with high population density
pollution_data %>% 
  filter(State == "California") %>% 
  #filter(State == "New Jersey") %>% 
  group_by(Year) %>%
  summarize_at(vars(`O3 Mean`, `CO Mean`, `SO2 Mean`, `NO2 Mean`), list(m=mean)) %>%
  ggplot() +
  geom_smooth(aes(Year,`O3 Mean_m`, color="O3 Durchschnitt"), method = 'loess', formula = 'y ~ x') +
  geom_smooth(aes(Year,`CO Mean_m`, color="CO Durchschnitt"), method = 'loess', formula = 'y ~ x') +
  geom_smooth(aes(Year,`SO2 Mean_m`, color="SO2 Durchschnitt"), method = 'loess', formula = 'y ~ x') +
  geom_smooth(aes(Year,`NO2 Mean_m`, color="NO2 Durchschnitt"), method = 'loess', formula = 'y ~ x') +
  labs(
    x="Jahr", 
    y="Gasanteile in der Luft", 
    color="Gas", 
    title = "Durchschnittliche Verteilung der Gase in der Luft - Kalifornien (Dichtbesiedelt)"
  ) 

# Filter could be adjusted to show a different state with low population density
pollution_data %>% 
  filter(State == "Maine") %>% 
  #filter(State == "North Dakota") %>%
  group_by(Year) %>%
  summarize_at(vars(`O3 Mean`, `CO Mean`, `SO2 Mean`, `NO2 Mean`), list(m=mean)) %>%
  ggplot() +
  geom_smooth(aes(Year,`O3 Mean_m`, color="O3 Durchschnitt"), method = 'loess', formula = 'y ~ x') +
  geom_smooth(aes(Year,`CO Mean_m`, color="CO Durchschnitt"), method = 'loess', formula = 'y ~ x') +
  geom_smooth(aes(Year,`SO2 Mean_m`, color="SO2 Durchschnitt"), method = 'loess', formula = 'y ~ x') +
  geom_smooth(aes(Year,`NO2 Mean_m`, color="NO2 Durchschnitt"), method = 'loess', formula = 'y ~ x') +
  labs(
    x="Jahr", 
    y="Gasanteile in der Luft", 
    color="Gas", 
    title = "Durchschnittliche Verteilung der Gase in der Luft - Maine (Wenigbesiedelt)"
  ) 

# ------------------
# Application of ML and Forecasting
# ------------------

# ------------------
# Forecast of temperature for the US
# ------------------
city_temps_model_data = city_temps %>% 
  filter(Country == 'US') %>% 
  filter(Year != 2020) %>% 
  group_by(Year, Month) %>%
  summarize_at(vars(AvgTemperatureInCelsius), list(mean=mean))

tsdata_city_temps <- ts(city_temps_model_data$mean, frequency = 12) 
ddata_city_temps <- decompose(tsdata_city_temps, "multiplicative")
autoplot(ddata_city_temps) + 
  labs(
    x="Jahr (Beginn der Messung in 1995)", 
    title = "Zerlegung des Temperaturverlaufs der USA in Trend, Saisonalität und übrige"
  ) 

model_from_timeseries_city_temps <- auto.arima(tsdata_city_temps)
city_temps_forecast <- forecast(model_from_timeseries_city_temps, level=c(95), h=12*10)

autoplot(city_temps_forecast) + 
  labs(
    x="Jahr (Beginn der Messung in 1995)", 
    y="Durchschnittstemperatur in Celsius", 
    title = "Prognostizierter Temperaturverlauf der USA für die nächsten 10 Jahre"
  ) 

ggseasonplot(tsdata_city_temps) + 
  labs(
    x="Monat", 
    y="Gemessene Durchschnittstemperatur", 
    color="Jahr",
    title = "Saisonaler verlauf der Durchschnittstemperatur (USA)"
  )

# ------------------
# Forecast of temperature worldwide
# ------------------

# City Temps; Worldwide; by Year
city_temps_year_ts_raw = city_temps %>% 
  filter(Year != 2020) %>% 
  group_by(Year) %>%
  summarize_at(vars(AvgTemperatureInCelsius), list(mean=mean))

tsdata_city_temps_year <- ts(city_temps_year_ts_raw$mean, frequency = 2) 
ddata_city_temps_year <- decompose(tsdata_city_temps_year, "multiplicative")

autoplot(ddata_city_temps_year) + 
  labs(
    x="Zeit (in Jahren)",
    title = "Zersetzung der Temperaturdaten in verschiedene Kategorien"
  )

model_from_timeseries_city_temps_year <- auto.arima(tsdata_city_temps_year)
city_temps_forecast_year <- forecast(model_from_timeseries_city_temps_year, level=c(95), h=10)

autoplot(city_temps_forecast_year) + 
  labs(
    x="Jahr (Beginn der Messung in 1995)", 
    y="Durchschnittstemperatur in Celsius", 
    title = "Prognostizierter Temperaturverlauf Weltweit für die nächsten 10 Jahre"
  ) 

# ------------------
# Forecast of AQI over the next years
# ------------------

# AQI; US; by Month and Year
air_quality_ts_raw = air_quality_index %>%
  group_by(Year = year(Date), Month = month(Date)) %>%
  summarize_at(vars(AQI), list(Mean=mean))

tsdata_aqi = ts(air_quality_ts_raw$Mean, frequency = 12)

ddata_aqi = decompose(tsdata_aqi, "multiplicative")
autoplot(ddata_aqi) +
  labs(
    x="Zeit (in Jahren)",
    title = "Zerlegung der Luftqualität der USA in Trend, Saisonalität und übrige"
  )

model_from_timeseries_aqi = auto.arima(tsdata_aqi)
aqi_forecast = forecast(model_from_timeseries_aqi, level = c(95), h=12*10)
autoplot(aqi_forecast)

ggseasonplot(tsdata_aqi) + 
  labs(
    x="Monat", 
    y="Gemessener AQI", 
    color="Jahr",
    title = "Saisonaler verlauf der Luftqualität (USA)"
  )

# ------------------
# Model for connection between gas composition and temperature
# ------------------
filtered_temps = city_temps %>% 
  filter(State=="California") %>% 
  group_by(Year,Month,Day) %>% 
  summarize_at(vars(AvgTemperatureInCelsius), list(Temp_Mean=mean)) 

new_model_data = pollution_data %>% 
  filter(State=="California") %>% 
  group_by(Year,Month,Day) %>% 
  summarize_at(vars(`O3 Mean`, `CO Mean`,`NO2 Mean`,`SO2 Mean`), list(Mean=mean)) %>% 
  inner_join(filtered_temps, by=c("Year", "Month", "Day")) %>%
  transmute(
    o3_mean = `O3 Mean_Mean`,
    co_mean = `CO Mean_Mean`,
    so2_mean = `SO2 Mean_Mean`,
    no2_mean = `NO2 Mean_Mean`,
    Temp_Mean
  )

new_model_data$Year = NULL
new_model_data$Month = NULL

pairs(new_model_data)

featurePlot(
  x = new_model_data[ , c("o3_mean", "co_mean", "so2_mean", "no2_mean")], 
  y = new_model_data$Temp_Mean
)

# ------------------
# Linear Model for temperature prediction
# ------------------

temperature_prediction_model=lm(mean~Year, data = city_temps_year_ts_raw)

plot_data <- data.frame(Predicted_value = predict(temperature_prediction_model),  
                        Observed_value = city_temps_year_ts_raw$Year)

ggplot(city_temps_year_ts_raw, aes(x=predict(temperature_prediction_model), y=mean)) + 
  geom_point() +
  geom_abline(intercept=0, slope=1) +
  labs(
    x='Vorhergesagte Werte (Durchschnittstemperatur)', 
    y='Gemessene Werte (Durchschnittstemperatur)', 
    title='Vorhergesagte vs. gemessene Werte der Temperatur-Vorhersage'
  )

# ------------------
# Save Output
# ------------------

#ggsave(file="test.svg", plot=image, width=10, height=8)
#save(plotname)

# ------------------
# Appendix
# ------------------

# More information https://daviddalpiaz.github.io/r4sl/modeling-basics-in-r.html#the-lm-function
# Regression Model
testModel=lm(Temp_Mean~., data = new_model_data)
summary(testModel)
tidy(testModel)
confint(testModel, level = 0.95)
glance(testModel)

coef(testModel)
#plot(testModel)

# ==============================================================================
# END <name>.R
# ==============================================================================
