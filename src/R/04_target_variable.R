library(magrittr)
library(fst)
library(data.table)

data.table::setDTthreads(threads = 0)

# Read data --------------------------------------------------------------------
# weather_data <-
#   read_fst("data/historical_weather_df.fst", 
#            as.data.table = TRUE,
#            columns = c("")
#            )

weather_summarized_data <-
  read_fst("data/weather_summary_data.fst", 
           as.data.table = TRUE,
           columns = c("coordx", "coordy", "fecha_mes", "max_temperature_2m_max")
           )

# Wrangling --------------------------------------------------------------------
weather_summarized_data_current_month <-
  weather_summarized_data %>% 
  .[fecha_mes == "2023-06-01"]

weather_summarized_data_current_month %>% summary()

flag_heat_df <-
  weather_summarized_data_current_month %>% 
  copy %>% 
  .[, flag_heat := max_temperature_2m_max >= 30] %>% 
  .[, -c("max_temperature_2m_max")]

# Save data --------------------------------------------------------------------
flag_heat_df %>% 
  write_fst("data/flag_heat_df.fst")
