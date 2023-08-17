library(fst)
library(magrittr)
library(data.table)

data.table::setDTthreads(threads = 0)

# Read data --------------------------------------------------------------------
weather_data <-
  read_fst("data/historical_weather_df.fst", as.data.table = TRUE)

# Wrangling --------------------------------------------------------------------
weather_monthly_data <-
  weather_data %>% 
  copy %>% 
  .[, fecha_mes := format(fecha, "%Y-%m-01") %>% as.Date] %>% 
  melt(id.vars = c("fecha", "fecha_mes", "coordx", "coordy", "elevation")) %>% 
  .[, .(max = max(value),
        min = min(value),
        mean = mean(value), 
        sum = sum(value)
        ),
    .(fecha_mes, coordx, coordy, elevation, variable)
    ] %>% 
  data.table::dcast(fecha_mes + coordx + coordy + elevation ~ variable,
                    value.var = c("max", "min", "mean", "sum"),
                    )

weather_window_monthly_data <-
  weather_monthly_data %>% 
  .[, -c("elevation")] %>% 
  .[order(coordx, coordy, fecha_mes)] %>% 
  melt(id.vars = c("fecha_mes", "coordx", "coordy")) %>% 
  .[, c("mean_48m",
        "mean_12m",
        "mean_6m",
        "mean_3m"
        ) := .(frollmean(x = value, n = 48, algo = "fast", align = "right"),
               frollmean(x = value, n = 12, algo = "fast", align = "right"),
               frollmean(x = value, n = 6, algo = "fast", align = "right"),
               frollmean(x = value, n = 3, algo = "fast", align = "right")
                         )] %>% 
  .[, -c("value")] %>% 
  data.table::dcast(fecha_mes + coordx + coordy ~ variable,
                    value.var = c("mean_48m", "mean_12m", "mean_6m", "mean_3m"),
  )

weather_summary_data <-
  weather_monthly_data %>% 
  merge(weather_window_monthly_data,
        by = c("fecha_mes", "coordx", "coordy")
        )

# Save data --------------------------------------------------------------------
weather_summary_data %>% 
  write_fst("data/weather_summary_data.fst")
