# --- preprocess

#pollution_data_2017 <- pollution_data %>% filter(Year == 2017)
#weather_events_2017 <- weather_events %>% filter(year(ymd_hms(`StartTime(UTC)`)) == 2017)
#city_temps_2017 <- city_temps %>% filter(Year == 2017) %>% filter(Country == "US")
#pollution_data_2017 %>% distinct(State)
#weather_states = weather_events_2017 %>% distinct(State)
# 
# weather_events = weather_events %>% 
#   rename(start_time = `StartTime(UTC)`, end_time = `EndTime(UTC)`, Precipitation_inches = `Precipitation(in)`)
# 
# ## select data from state of texas
# weather_events_texas <- weather_events %>% filter(State == "TX")
# pullution_data_texas <- pollution_data %>% filter(State == "Texas")
# city_temps_texas <- city_temps %>% filter(State == "Texas")
# air_quality_index_texas <- air_quality_index %>% filter(`State Name` == "Texas")
# 
# 
# # --- analyse
# weather_events_types = weather_events %>% distinct(Type)
# weather_events_typecounts = weather_events %>% count(Type)
# 
# aqi_mean = air_quality_index %>% 
#   group_by(month_year = my(paste(month(Date),year(Date),sep = "-"))) %>%
#   summarise(aqi_mean = mean(AQI))
# 
# weather_events_texas_by_month = weather_events_texas %>% 
#   group_by(month_year = my(paste(month(ymd_hms(start_time)), year(ymd_hms(start_time)), sep="-"))) %>% 
#   summarise(sum = sum(`Precipitation(in)`), n = n())
# 
# weather_events_texas_by_month = weather_events_texas %>% 
#   group_by(month_year = my(paste(month(ymd_hms(start_time)), year(ymd_hms(start_time)), sep="-"))) %>% 
#   summarise(sum = sum(`Precipitation(in)`), n = n())
# 
# weather_events_texas_by_month_and_type = weather_events_texas %>% 
#   group_by(month_year = my(paste(month(ymd_hms(start_time)), year(ymd_hms(start_time)), sep="-")), Type) %>% 
#   summarise(sum = sum(`Precipitation(in)`), n = n())
# 
# weather_events_texas_by_year = weather_events_texas %>% 
#   group_by(year = year(ymd_hms(start_time))) %>% 
#   summarise(sum = sum(Precipitation_inches), n = n())
# 
# city_temps_texas_average_by_month <- city_temps_texas %>% 
#   group_by(month_year = my(paste(Month, Year, sep="-"))) %>%
#   summarise(mean = mean(AvgTemperature))
# 
# city_temps_texas_average_by_year <- city_temps_texas %>% 
#   group_by(Year) %>%
#   summarise(mean = mean(AvgTemperature))
# 
# air_quality_index_texas_by_month <- air_quality_index_texas %>% 
#   group_by(month_year = my(paste(month(Date),year(Date),sep = "-"))) %>%
#   summarise(mean = mean(AQI))
# 
# plot(air_quality_index_texas_by_month$month_year, air_quality_index_texas_by_month$mean)
# lines(air_quality_index_texas_by_month$month_year, air_quality_index_texas_by_month$mean)
# 
# # --- visualise
# 
# plot(weather_events_texas_by_month$month_year, weather_events_texas_by_month$sum)
# lines(weather_events_texas_by_month$month_year, weather_events_texas_by_month$sum)
# 
# weather_events_texas_by_month_and_type %>% ggplot(aes(month_year, sum, colour = Type)) + 
#   geom_smooth(method = lm)
# 
# plot(weather_events_texas_by_year$year, weather_events_texas_by_year$sum)
# lines(weather_events_texas_by_year$year, weather_events_texas_by_year$sum)
# 
# plot(city_temps_texas_average_by_month$month_year, city_temps_texas_average_by_month$mean)
# lines(city_temps_texas_average_by_month$month_year, city_temps_texas_average_by_month$mean)
# 
# plot(city_temps_texas_average_by_year$Year, city_temps_texas_average_by_year$mean)
# lines(city_temps_texas_average_by_year$Year, city_temps_texas_average_by_year$mean)
# 
# aqi_mean %>% ggplot(aes(month_year, aqi_mean)) +
#   geom_point() +
#   geom_smooth()
# 
# city_temps_texas_average_by_month %>% ggplot(aes(month_year, mean)) +
#   geom_point() +
#   geom_smooth()

# --- save output