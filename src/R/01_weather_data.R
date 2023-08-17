library(sf)
library(raster)
library(magrittr)
library(data.table)
library(fst)

data.table::setDTthreads(threads = 0)

source("src/R/00_get_historical_data.R")
source("src/R/00_get_url.R")

# Read data --------------------------------------------------------------------
cdmx_shape <-
  read_sf("raw-data/geoespacial/marco_geoestadistico_2020/09_ciudaddemexico/conjunto_de_datos/09ent.shp") %>% 
  st_transform(crs = 4326) %>% 
  dplyr::mutate(flag_cdmx = TRUE)

# Filter data ------------------------------------------------------------------
st_bbox(cdmx_shape)

template <-
  cdmx_shape %>% 
  raster(resolution = sqrt(1) / 111.7)

cuadrados_cdmx <-
  rasterize(cdmx_shape %>% dplyr::select(geometry, flag_cdmx), 
            template,
            fun = "first"
            )

cuadricula_df_filtrada <-
  cuadrados_cdmx %>% 
  as.data.frame(xy = TRUE, centered = TRUE) %>% 
  as.data.table() %>% 
  .[! is.na(layer_flag_cdmx)] %>% 
  .[, url := get_url(latitude = y, longitude = x)]

historical_weather_df <-
  data.table()

for (i in 1:cuadricula_df_filtrada[, .N]) {
# for (i in 1:10) {
  
  url_interes <- cuadricula_df_filtrada[i, url]
  
  df_interes <- 
    get_historical_data(url_interes) %>% 
    .[, coordx := cuadricula_df_filtrada[i, x]] %>% 
    .[, coordy := cuadricula_df_filtrada[i, y]]
  
  historical_weather_df <-
    historical_weather_df %>% 
    rbind(df_interes)
  
  hora <- format(Sys.time(), "%H:%M:%S")
  
  print(paste(hora, "point", i, "of", cuadricula_df_filtrada[, .N]))
  
}

# Save data --------------------------------------------------------------------
historical_weather_df %>% 
  write_fst("data/historical_weather_df.fst")
