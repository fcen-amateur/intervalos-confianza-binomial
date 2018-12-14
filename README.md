# intervalos-confianza-binomial

Este repositorio contiene el código, bibliografía y documentación referida al ejercicio "para hacer con la computadora" de la Práctica 6 de Estadística Teórica C2-2018. **El informe relevante se puede encontrar en [este link](https://docs.google.com/document/d/1tLJIbpKfefpAp7ktfaRc9lBpFb0ghXxMJMkYcUqvOjM/edit?usp=sharing)**.

## Introducción
Se implementaron y evaluaron 4 métodos para generar el intervalo de confianza del
parámetro _p_ de una muestra aleatoria _X_ compuesta de _k_ observaciones de
VAIID con distribución _Binomial(n, p)_:
- Asintótico "cuadrático": IC de nivel asintótico "puro".
- Asintótico "Slutsky": IC de nivel asintótico, que aprovecha la convergencia
    en probabilidad a un valor constante de la varianza de cada X_i
- Clopper: IC "exacto", basado en dos test de hipótesis sobre _p_, reformulado
    para definir según los cuantiles de la distribución F. Léase el 
    [artículo en Wikipedia](https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Clopper%E2%80%93Pearson_interval) para mayor información.
- Bootstrap: IC generado a partir de la función de densidad empíricar del EMV
    de _p_, hallada por el método "bootstrap".

## Setup
El presente TP hace uso extensivo del paquete `tidyverse`, y en especial de las
librerías `magrittr` (por el operador de composición `%>%`), `dplyr` (para
manipulación de datos en tablas) y `purrr` (por su conjunto de consistentes
funciones de mapeo `map_*`).

Para generar los resultados desde la consola, se debe editar `R/parametros.R`
según se desee, y _desde la raíz del repositorio_, ejecutar el script
`R/principal.R`. En sistemas UNIX, `make datos/` o simplemente `make` logra
el mismo efecto.

## Organización
- `Makefile`: Contiene la receta para generar los datos y resultados de TP.
- `R/:` código en R del trabajo
  - `intervalos_confianza_binomial.R`: "librería" principal del trabajo
  - `demo_generar_intervalos.R`: Demostración del uso de la librería principal
  - `parametros.R`: parametrización de la rutina principal
  - `principal.R`: Usando `intervalos_confianza_binomial.R` y `parametros.R`,
      genera las MA e IC requeridos y sintetiza los resultados.
- `bibliografia/`: documentación de las librerías utilizadas y _papers_ relevantes
  - `referencia-dplyr.pdf`: Hoja de referencia de la librería `dplyr` para
      manipulación de datos.
  - `referencia-purrr.pdf`: Hoja de referencia de la librería `purrr` de
      programación funcional.
  - `CLOPPER, C. J.; PEARSON, E. S. -- THE USE OF CONFIDENCE...`: _Paper_ original
      de Clopper y Pearson sobre el IC "exacto" para la distribución binomial.
- `datos/`: resultados y síntesis de los mismos.
  - `sintesis_por_metodo.csv`: síntesis general de los 4 métodos considerados
  - `sintesis_por_parametro_y_metodo.csv`: síntesis detallada, para cada
     combinación de parámetros y método consideradas.
  - `resultados.rds`: Por su peso no se incluye en el repositorio
