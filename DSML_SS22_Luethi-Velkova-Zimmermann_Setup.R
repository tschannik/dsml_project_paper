# ==============================================================================
# DSML_SS22_Luethi-Velkova-Zimmermann_Setup.R - Used to load datasets and some
# nessessary variables into DSML_SS22_Luethi-Velkova-Zimmermann.Rmd file.
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

# Used for wordcount
library(stringr)
library(tidyverse)

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------

# Setup colors for graphs
color_palette <- c("#000000", "#E69F00", "#56B4E9", "#009E73",
                   "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
primary_color = "#009E73"
secondary_color = "#CC79A7"

# Load Data
raw_pollution_data <- read_csv("pollution_2000_2021.csv")
raw_city_temps <- read_csv("city_temperature.csv")
raw_air_quality_index <- read_csv("aqi_daily_1980_to_2021.csv")

# Setup city_temps
city_temps = raw_city_temps %>% 
  distinct() %>% 
  filter(AvgTemperature > -50) %>% 
  filter(Year > 1950) %>% 
  filter(Year != 2020)

city_temps['AvgTemperatureInCelsius'] = fahrenheit.to.celsius(city_temps$AvgTemperature)

# Setup air_quality_index
air_quality_index = raw_air_quality_index %>% 
  filter(year(Date) != 2021)

# Setup pullution_data
pollution_data = raw_pollution_data %>% 
  distinct() %>%
  filter(year(Date) != 2021)

# Prepare data for map graph
map_data_aqi_mean = air_quality_index %>%
  group_by(state=`State Name`) %>%
  summarize_at(vars(AQI, Latitude, Longitude), list(m=mean))

city_temps_model_data = city_temps %>% 
  filter(Country == 'US') %>% 
  filter(Year != 2020) %>% 
  group_by(Year, Month) %>%
  summarize_at(vars(AvgTemperatureInCelsius), list(mean=mean))

tsdata_city_temps <- ts(city_temps_model_data$mean, frequency = 12) 
ddata_city_temps <- decompose(tsdata_city_temps, "multiplicative")

model_from_timeseries_city_temps <- auto.arima(tsdata_city_temps)
city_temps_forecast <- forecast(model_from_timeseries_city_temps, level=c(95), h=12*10)

city_temps_year_ts_raw = city_temps %>% 
  filter(Year != 2020) %>% 
  group_by(Year) %>%
  summarize_at(vars(AvgTemperatureInCelsius), list(mean=mean))

tsdata_city_temps_year <- ts(city_temps_year_ts_raw$mean, frequency = 2) 
ddata_city_temps_year <- decompose(tsdata_city_temps_year, "multiplicative")

model_from_timeseries_city_temps_year <- auto.arima(tsdata_city_temps_year)
city_temps_forecast_year <- forecast(model_from_timeseries_city_temps_year, level=c(95), h=10)

air_quality_ts_raw = air_quality_index %>%
  group_by(Year = year(Date), Month = month(Date)) %>%
  summarize_at(vars(AQI), list(Mean=mean))

tsdata_aqi = ts(air_quality_ts_raw$Mean, frequency = 12)

ddata_aqi = decompose(tsdata_aqi, "multiplicative")

model_from_timeseries_aqi = auto.arima(tsdata_aqi)
aqi_forecast = forecast(model_from_timeseries_aqi, level = c(95), h=12*10)

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

temperature_and_pollution_model=lm(Temp_Mean~., data = new_model_data)

# https://stackoverflow.com/questions/46317934/exclude-sections-from-word-count-in-r-markdown
RmdWords <- function(file) {
  
  # Creates a string of text
  file_string <- file %>%
    readLines() %>%
    paste0(collapse = " ") %>%
    # Remove YAML header
    str_replace_all("^<--- .*?--- ", "") %>%    
    str_replace_all("^--- .*?--- ", "") %>%
    # Remove code
    str_replace_all("```.*?```", "") %>%
    str_replace_all("`.*?`", "") %>%
    # Remove LaTeX
    str_replace_all("[^\\\\]\\$\\$.*?[^\\\\]\\$\\$", "") %>%
    str_replace_all("[^\\\\]\\$.*?[^\\\\]\\$", "") %>%
    # Deletes text between tags
    str_replace_all("TC:ignore.*?TC:endignore", "") %>%
    str_replace_all("[[:punct:]]", " ") %>%
    str_replace_all("  ", "") %>%
    str_replace_all("<", "") %>%
    str_replace_all(">", "")
  
  # Save several different results
  word_count <- str_count(file_string, "\\S+")
  char_count <- str_replace_all(string = file_string, " ", "") %>% str_count()
  
  return(list(num_words = word_count, num_char = char_count, word_list = file_string))
}

words <- RmdWords("DSML_SS22_Luethi-Velkova-Zimmermann.Rmd")








