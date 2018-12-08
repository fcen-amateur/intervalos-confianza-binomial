library(tidyverse)

### FUNCIONES GENERADORAS DE INTERVALOS ###
# Las siguientes funciones toman todas al menos 3 argumentos:
# - X: muestra aleatoria de X_i  VAIID binomiales
# - n: parámetro `n` de las X_i VAIID que componen X
# - alfa: nivel de confianza pretendido para el IC del parámetro `p`
#
# y devuelven un vector de tipo `dbl` de 2 elementos, representando el IC de
# de nivel de confianza 1-alfa obtenido según el método que le da nombre.

intervalo_bootstrap <- function(
  X, n, alfa = 0.05, n_boot = 1000, n_muestra = length(X)) {
  # n_boot: # de MA "sintéticas" a generarmediante MAS c/ reposicion de `X`
  # n_muestra: Longitud de cada una de las `n_boot` MA "sinteticas"
  #
  # Devuelve el IC de niveles c(alfa/2, 1-alfa/2) para la distribución empírica
  # de `phat` ("p sombrero") en las `n_boot` MA "sintéticas".
  boot <- replicate(n_boot, sample(X, n_muestra, replace = T))
  medias <- apply(boot, MARGIN = 2, mean)
  phat <- medias/n

  return(quantile(phat, c(alfa/2, 1-alfa/2)))
}

intervalo_asintotico_slutsky <- function(X, n, alfa = 0.05) {
  # vector de cuantiles c(alfa/2, 1-alfa/2) para una VA Z ~ N(0,1)
  z <- qnorm(c(alfa/2, 1-alfa/2))
  k <- length(X)
    
  return((1/n)*(z*sqrt(mean(X)*(n-mean(X))/n/k) + mean(X)))
}

intervalo_asintotico_cuadratico <- function(X, n, alfa = 0.05) {
  z_sq <- qnorm(alfa/2)^2
  k <- length(X)
  
  c2 <- n*(n*k + z_sq)
  c1 <- -n*(2*k*mean(X) + z_sq)
  c0 <- k*mean(X)^2
  
  return(Re(polyroot(c(c0, c1, c2))))
}

intervalo_clopper <- function (X, n, alfa = 0.05) {
  # Devuelve el IC basado en la distribución F equivalente al expuesto por 
  # Clopper y Pearson en "The Use of Confidence Or Fiducial Limits..."
  
  k <- length(X)
  suma_X <- sum(X)
  suma_n <- n*k
  
  if (suma_X == 0) {
    # cuando suma_X == 0, el limite inferior del intervalo es necesariamente 0
    # pero 2*suma_X == 0, y `qf` requiere que df1 > 0 
    limite_inf <- 0
  } else {
    cuantil_F_inf <-  qf(alfa/2, 2*suma_X, 2*(suma_n - suma_X + 1))
    limite_inf <- (1 + (suma_n - suma_X + 1) / (suma_X * cuantil_F_inf))^(-1)
  }
  
  if (suma_X == suma_n) {
    # cuando suma_X == suma_n, el lim. sup. del intervalo es necesariamente 1
    # pero 2*(suma_n - suma_X) == 0, y `qf` requiere que df2 > 0 
    limite_sup <- 1
  } else {
    cuantil_F_sup <- qf(1-alfa/2, 2*(suma_X+1), 2*(suma_n - suma_X))
    limite_sup <- (1 + (suma_n - suma_X) / ((suma_X + 1) * cuantil_F_sup))^(-1)
  }
  
  return(c(limite_inf, limite_sup))
}

# Por practicidad, las siguientes funciones "envuelven" a las funciones
# generadoras de intervalos y permiten aplicarlas simultáneamente a una misma
# muestra aleatoria.

# Lista de funciones generadoras de IC conocidas
generadores_intervalos <- list(
  "bootstrap" = intervalo_bootstrap,
  "asintotico_slutsky" = intervalo_asintotico_slutsky,
  "asintotico_cuadratico" = intervalo_asintotico_cuadratico,
  "clopper" = intervalo_clopper
)


generar_intervalo <- function(nombre, X, n, alfa) {
  # nombre: nombre del método para generar el intervalo. Debe estar presente en
  #   la lista `generadores_intervalos`.
  # X: muestra aleatoria de X_i  VAIID binomiales
  # n: parámetro `n` de las X_i VAIID que componen X
  # alfa: nivel de confianza pretendido para el IC del parámetro `p`
  #
  # Devuelve el IC de niveles c(alfa/2, 1-alfa/2) obtenido según el método
  # `nombre` para el valor del parámetro `p` de las VAIID que componen `X`.
  generadores_intervalos[[nombre]](X, n, alfa)
}

generar_intervalos <- function(X, n, alfa) {
  # Devuelve todos los IC de niveles c(alfa/2, 1-alfa/2) obtenidos según los
  # métodos de la lista `generadores_intervalos`. para el parámetro `p` de las
  # VAIID que componen `X`. El resultado es un `tibble` (tabla) de 2 variables:
  # - nombre (str)
  # - intervalo (dbl)
  intervalos_conocidos <- names(generadores_intervalos)
  tibble(
    nombre = intervalos_conocidos,
    intervalo = map(intervalos_conocidos, 
                    generar_intervalo,
                    X = X, n = n, alfa = alfa)
  )
}

longitud_intervalo <- function(intervalo) {
  intervalo[2] - intervalo[1]
}

generar_muestra <- function(k, n, p) {
  # "Envoltorio" sintáctico de `rbinom` para la parametrización elegida:
  # - k: tamaño de la muestra aleatoria `X` a generar
  # - n, p: parámetros de c/u de las `k` VAIID X_i que componen X
  rbinom(n = k, size = n, prob = p)
}

generar_muestras <- function(rango_k, rango_n, rango_p, n_sims) {
  # - rango_k, rango_n, rango_p: Vectores con los valores de k, n y p para los
  #     cuales se desean generar MA
  # - n_sims: cantidad de MA a generar para cada combinacion de los valores
  #    deseados de k, n y p.
  #
  # Devuelve un tibble de length(rango_k)*length(rango_n)*length(rango_p)*n_sims
  #   filas, y 4 columnas:
  # - k, n, p: valores usados para generar la MA X
  # - n_sim: entero identificador de la simulación 
  # - X: MA generada 
  cross_df(list(
    k = rango_k,
    n = rango_n,
    p = rango_p,
    n_sim = seq_len(n_sims)
  )) %>%
    mutate(X = pmap(list(k, n ,p), generar_muestra))
}