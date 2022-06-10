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

# Setup colors for graphs
color_palette <- c("#000000", "#E69F00", "#56B4E9", "#009E73",
                   "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
primary_color = "#009E73"
secondary_color = "#D55E00"

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











