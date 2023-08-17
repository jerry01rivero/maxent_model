library(magrittr)
library(fst)
library(data.table)
library(dismo)
library(pROC)
library(caret)

to_exclude <-
  c(
    "mean_48m_max_rain_sum",
    # "mean_48m_max_windspeed_10m_max",
    # "mean_48m_max_windgusts_10m_max",
    # "mean_48m_mean_windgusts_10m_max",
    # "mean_48m_sum_shortwave_radiation_sum",
    # "mean_12m_max_windgusts_10m_max",
    "mean_12m_min_rain_sum",
    # "mean_12m_min_shortwave_radiation_sum",
    # "mean_6m_max_windgusts_10m_max",
    "mean_6m_max_shortwave_radiation_sum",
    # "mean_6m_min_windspeed_10m_max",
    "mean_3m_max_windgusts_10m_max"
    # "mean_3m_max_shortwave_radiation_sum",
    # "mean_3m_min_windgusts_10m_max",
    # "mean_3m_min_shortwave_radiation_sum"
    )

# Read data --------------------------------------------------------------------
df_to_model <- 
  read_fst("data/summarized_data_to_model.fst", as.data.table = TRUE)
  # .[, -to_exclude, with = FALSE]

df_to_model %>% names()
# Wrangling --------------------------------------------------------------------
set.seed(100)

train_df <-
  df_to_model %>% 
  .[sample(.N * 0.6)]

test_df <-
  df_to_model[!train_df[, .(coordx, coordy)], on = c("coordx", "coordy")]

df_to_model[, .N] == train_df[, .N] + test_df[, .N]

# Model ------------------------------------------------------------------------
modelo_maxent <-
  maxent(x = train_df[, -c("coordx", "coordy", "flag_heat")],
         p = train_df[, flag_heat]
         )

# Save model -------------------------------------------------------------------
saveRDS(modelo_maxent, "models/modelo_maxent.RDS")

predict_test_vector <-
  predict(modelo_maxent, test_df[, -c("coordx", "coordy", "flag_heat")])

predict_test_df <-
  test_df %>% 
  copy %>% 
  .[, prob_heat := predict_test_vector]

# roc <- roc(predict_test_df[, flag_heat], predict_test_df[, prob_heat])
# 
# plot(roc,col="red",lwd=2,main="ROC test")
# legend("bottomright",legend=paste("AUC=",round(auc(roc),4)))

matriz <-
  confusionMatrix(predict_test_df[, flag_heat %>% as.factor()], 
                  predict_test_df[, (prob_heat > 0.2) %>% as.factor()]
                  )

matriz

modelo_maxent
plot(modelo_maxent)
response(modelo_maxent, var = "max_windgusts_10m_max")
response(modelo_maxent, var = "mean_6m_min_windspeed_10m_max")
response(modelo_maxent, var = "mean_48m_max_windgusts_10m_max")
response(modelo_maxent, var = "elevation")
