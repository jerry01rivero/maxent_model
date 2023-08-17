get_url <-
  function(latitude, longitude){
    parte_1 <-
      sprintf(# "https://archive-api.open-meteo.com/v1/archive?latitude=%.5f",
        # "https://archive-api.open-meteo.com/v1/forecast?latitude=%.5f",
        "https://archive-api.open-meteo.com/v1/archive?latitude=%.5f",
        latitude)
    
    parte_2 <-
      sprintf("&longitude=%.5f",
              longitude)
    
    parte_3 <-
      "&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,precipitation_sum,rain_sum,snowfall_sum,precipitation_hours,windspeed_10m_max,windgusts_10m_max,shortwave_radiation_sum,et0_fao_evapotranspiration"
    
    parte_4 <-
      "&timezone=America%2FChicago"
    
    parte_5 <-
      "&start_date=2018-01-01&end_date=2023-07-02"
    
    url_total <-
      paste0(parte_1, 
             parte_2,
             parte_3,
             parte_4,
             parte_5
      )
    
    return(url_total)
  }

