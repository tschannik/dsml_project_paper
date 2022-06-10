# --- preprocess
# 
# <!-- Fragen in Zusammenhang mit Unwetter: -->
#   
#   <!-- - Hat sich die Anzahl Unwetter (definieren was mit Unwetter gemeint ist) über die fünf Jahre erhöht? -->
#   
#   <!-- - Wenn ja, welche Art von Unwetter hat zugenommen? Welche Art von Unwetter hat abgenommen/ist weniger vorgekommen? -->
#   
#   <!-- - Besteht eine Korrelation zwischen der erhöhten Anzahl Unwetter (definieren welches Unwetter) und der erhöhten/tieferen Durchschnittstemperaturen? -->
#   
#   <!-- - Hat die Frequenz der Unwetter zu- oder abgenommen? - Frage kann noch nach Unwetterart und Ort aufgeteilt werden. -->
#   
#   <!-- - Hat die Stärke der Unwetter zu- oder abgenommen? - Frage kann noch nach Unwetterart und Ort aufgeteilt werden. -->
#   
#   <!-- - Hat die Wassermenge an Regentagen allgemein zu- oder abgenommen? -->
#   
#   <!-- - Haben sich die Wetterereignissen örtlich verschoben? (Zuerst Standard aufzeigen, danach mögliche Änderung) -->
#   
#   <!-- - Hat sich die Anzahl Regentagen verändert? -->
#   
#   <!-- - Hat sich die Anzahl Sonnentage verändert? -->
#   
#   <!-- - usw -->
#   
#   <!-- Fragen in Zusammenhang mit Temperaturänderungen: -->
#   
#   <!-- - Wurde eine generelle stetige Temperaturänderung über die fünf Jahre gemessen? -->
#   
#   <!-- - Wenn ja, wurde es allgemein kälter oder wärmer? -->
#   
#   <!-- - Wurde eine allgemeine Temperaturerhöhung über die Jahre 2016-2021 gemessen? -->
#   
#   <!-- - Wenn ja, wie hoch und wie rasch hat sich die Temperatur geändert? (Diagramm) -->
#   
#   <!-- - In welchem Staat, wurde die stärkste Temperaturänderung gemessen? -->
#   
#   <!-- - Wie stark weicht die Temperaturänderung von der natürlichen Erderwärmung ab? -->
#   
#   <!-- Fragen in Zusammenhang mit den Gasen: -->
#   
#   <!-- - Welches Gas hat allgemein am stärksten zugenommen? -->
#   
#   <!-- - Gleiche Frage in Bezug zu den einzelnen Staaten und  Jahren -->
#   
#   <!-- - Kann aufgrund der Erhöhung eines bestimmen Gases eine Erhöhung/Verstärkung einer bestimmen Unwetterart erkennt werden? -->
#   

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