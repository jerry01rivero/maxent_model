library(magrittr)
library(data.table)
library(fst)

data.table::setDTthreads(threads = 0)

# Read data --------------------------------------------------------------------
weather_prev_month <-
  read_fst("data/weather_prev_month_transformed.fst",
           as.data.table = TRUE
           ) %>% 
  .[, -c("fecha_mes")]

flag_heat_df <-
  read_fst("data/flag_heat_df.fst", as.data.table = TRUE) %>% 
  .[, -c("fecha_mes")]

# Wrangling --------------------------------------------------------------------
all_data_df <-
  weather_prev_month %>% 
  merge(flag_heat_df,
        by = c("coordx", "coordy"))

# Save data --------------------------------------------------------------------
all_data_df %>% 
  write_fst("data/summarized_data_to_model.fst")
