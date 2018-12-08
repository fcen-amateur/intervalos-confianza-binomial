library(tidyverse)
source("R/intervalos_confianza_binomial.R")

# Pruebo las funciones con una sola muestra
k <- 10
n <- 33
p <- 0.07
alfa <- 0.5
X <- generar_muestra(k, n, p)

generar_intervalo("asintotico_slutsky", X, n, alfa)
generar_intervalo("asintotico_cuadratico", X, n, alfa)
generar_intervalo("bootstrap", X, n, alfa)
generar_intervalo("clopper", X, n, alfa)
generar_intervalos(X, n, alfa)
