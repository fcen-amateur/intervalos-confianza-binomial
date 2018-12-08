library(tidyverse)
source("R/intervalos_confianza_binomial.R")
source("R/parametros.R")

muestras <- generar_muestras(rango_k, rango_n, rango_p, n_sims)

resultados <- muestras %>%
  mutate(
    intervalos = pmap(list(X, n), generar_intervalos, alfa = alfa)) %>%
  unnest(intervalos) %>%
  mutate(
    lim_inf = map_dbl(intervalo, 1),
    lim_sup = map_dbl(intervalo, 2),
    longitud = map_dbl(intervalo, longitud_intervalo),
    contiene_p = (lim_inf < p) & (p < lim_sup))

sintesis_por_parametro_y_metodo <- resultados %>%
  group_by(k, n, p, nombre) %>%
  summarise(
    longitud_esperada = mean(longitud),
    prob_cobertura = mean(contiene_p))

sintesis_por_metodo <- resultados %>%
  group_by(nombre) %>%
  summarise(
    longitud_esperada = mean(longitud),
    prob_cobertura = mean(contiene_p))

write_rds(resultados, "datos/resultados.rds")
write_csv(sintesis_por_metodo, "datos/sintesis_por_metodo.csv")
write_csv(sintesis_por_parametro_y_metodo, "datos/sintesis_por_parametro_y_metodo.csv")