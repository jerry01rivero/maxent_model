library(fst)
library(magrittr)
library(data.table)
library(recipes)

data.table::setDTthreads(threads = 0)

# Read data --------------------------------------------------------------------
weather_summarized_data <-
  read_fst("data/weather_summary_data.fst", as.data.table = TRUE)

# Wrangling --------------------------------------------------------------------
# NA data
weather_summarized_data %>% 
  .[fecha_mes == "2023-05-01"] %>% 
  .[, -c("fecha_mes", "coordx", "coordy", "elevation")] %>% 
  melt() %>% 
  .[, na_column := is.na(value)] %>% 
  .[, .(na_total = sum(na_column)), variable] %>% 
  .[na_total > 0]

weather_prev_month_data <-
  weather_summarized_data %>% 
  .[fecha_mes == "2023-05-01"]

rec_prev_obj <- 
  recipe(formula = fecha_mes + coordx + coordy ~ .,
         data = weather_prev_month_data) %>%
  step_naomit(all_predictors()) %>%
  # step_YeoJohnson(all_predictors()) %>% 
  step_nzv(all_predictors()) %>%
  step_corr(all_predictors(), threshold = 0.9)
rec_prev_prep <- 
  prep(rec_prev_obj, data = weather_prev_month_data, strings_as_factors = FALSE)
rec_prev_dt <- 
  bake(rec_prev_prep, new_data = weather_prev_month_data) %>% 
  as.data.table

final_variables <-
  c(rec_prev_dt %>% names(), "elevation")

weather_prev_month_data_var_selected <-
  weather_prev_month_data[, final_variables, with = FALSE]

rec_obj <- 
  recipe(formula = fecha_mes + coordx + coordy ~ .,
         data = weather_prev_month_data_var_selected) %>%
  step_YeoJohnson(all_predictors())
rec_prep <- 
  prep(rec_obj, data = weather_prev_month_data_var_selected, strings_as_factors = FALSE)
rec_dt <- 
  bake(rec_prep, new_data = weather_prev_month_data) %>% 
  as.data.table

# Save data --------------------------------------------------------------------
rec_dt %>% 
  write_fst("data/weather_prev_month_transformed.fst")
