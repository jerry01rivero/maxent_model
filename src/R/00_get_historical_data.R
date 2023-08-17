# source("src/R/00_get_url.R")
library(rjson)

# url <- get_url(latitude = 19.39, longitude = -99.07)

get_historical_data <- 
  function(url){
    
    historical_data <-
      fromJSON(file = url,
               simplify = FALSE
      )
    
    # str(historical_data)
    
    # latitude             : num 19.4
    # longitude            : num -99.1
    # generationtime_ms    : num 1.04
    # utc_offset_seconds   : num -18000
    # timezone             : chr "America/Chicago"
    # timezone_abbreviation: chr "CDT"
    # elevation            : num 2230
    # time                      : chr "iso8601"
    # temperature_2m_max        : chr "°C"
    # temperature_2m_min        : chr "°C"
    # apparent_temperature_max  : chr "°C"
    # apparent_temperature_min  : chr "°C"
    # precipitation_sum         : chr "mm"
    # rain_sum                  : chr "mm"
    # snowfall_sum              : chr "cm"
    # precipitation_hours       : chr "h"
    # windspeed_10m_max         : chr "km/h"
    # windgusts_10m_max         : chr "km/h"
    # winddirection_10m_dominant: chr "°"
    # shortwave_radiation_sum   : chr "MJ/m²"
    # et0_fao_evapotranspiration: chr "mm"
    
    historical_data_list <-
      list(
        fecha = historical_data$daily$time %>% unlist %>% as.Date,
        # temperature_2m_mean = historical_data$daily$temperature_2m_mean %>% unlist,
        temperature_2m_max = historical_data$daily$temperature_2m_max %>% unlist,
        temperature_2m_min = historical_data$daily$temperature_2m_min %>% unlist,
        apparent_temperature_max = historical_data$daily$apparent_temperature_max %>% unlist,
        apparent_temperature_min = historical_data$daily$apparent_temperature_min %>% unlist,
        precipitation_sum = historical_data$daily$precipitation_sum %>% unlist,
        rain_sum = historical_data$daily$rain_sum %>% unlist,
        snowfall_sum = historical_data$daily$snowfall_sum %>% unlist,
        precipitation_hours = historical_data$daily$precipitation_hours %>% unlist,
        windspeed_10m_max = historical_data$daily$windspeed_10m_max %>% unlist,
        windgusts_10m_max = historical_data$daily$windgusts_10m_max %>% unlist,
        # winddirection_10m_dominant = historical_data$daily$winddirection_10m_dominant %>% unlist,
        shortwave_radiation_sum = historical_data$daily$shortwave_radiation_sum %>% unlist,
        et0_fao_evapotranspiration = historical_data$daily$et0_fao_evapotranspiration %>% unlist
      )
    
    historical_data_df <-
      as.data.table(
        lapply(historical_data_list, `length<-`, max(lengths(historical_data_list)))
      ) %>% 
      .[, coordx := historical_data$longitude] %>% 
      .[, coordy := historical_data$latitude] %>% 
      .[, elevation := historical_data$elevation]
    
    return(historical_data_df)
    
  }