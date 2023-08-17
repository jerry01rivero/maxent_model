library(sf)
library(raster)
library(magrittr)
library(data.table)
library(fst)
library(ggplot2)

data.table::setDTthreads(threads = 0)

# Read data --------------------------------------------------------------------
cdmx_shape <-
  read_sf("raw-data/geoespacial/marco_geoestadistico_2020/09_ciudaddemexico/conjunto_de_datos/09ent.shp") %>% 
  st_transform(crs = 4326) %>% 
  dplyr::mutate(flag_cdmx = TRUE)

modelo <- readRDS("models/modelo_maxent.RDS")

df_to_model <- 
  read_fst("data/summarized_data_to_model.fst", as.data.table = TRUE)

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

cuadrados_cdmx_shp <-
  stars::st_as_stars(cuadrados_cdmx) %>% 
  st_as_sf()


ggplot() +
  geom_sf(data = cdmx_shape, fill = NA,
          colour = "#0f6a00", size = 0.2) +
  
  geom_sf(data = cuadrados_cdmx_shp, fill = NA) +
  theme_minimal()

cuadrados_cdmx_df <-
  cuadrados_cdmx %>% 
  as.data.frame(xy = TRUE) %>% 
  as.data.table()

# Data to export ---------------------------------------------------------------
prob_heat <-
  predict(modelo, df_to_model[, -c("coordx", "coordy", "flag_heat")])

df_modeled <-
  df_to_model %>% 
  copy %>% 
  .[, prob_heat := prob_heat] %>% 
  .[, .(coordx, coordy, flag_heat, prob_heat)]

df_modeled %>% names

sf_modeled <-
  st_as_sf(x = df_modeled,                         
           coords = c("coordx", "coordy"),
           crs = "WGS84")

cdmx_modeled <-
  cuadrados_cdmx_shp %>% 
  sf::st_join(sf_modeled)

cdmx_modeled %>%
  sf::write_sf("out/prediction.shp")
