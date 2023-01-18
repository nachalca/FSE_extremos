# FSE_extremos
Proyecto: cuantificación incertidumbre en extremos de energía renovable


# Notas (jc: escribo aca para no olvidar)

- el problema que atacamos es la simulacion de las condicion media de produccion, 
asi como lo que se busca estudiar con los datos CMIP6 es el cambio en la climatologia 
(y no la predictibilidad), nosotros buscamos anticipar las condiciones de generacion en un contexto de cambio climatico

## wishlist de datos que podemos necesitar:
- historicos => estos son utiles para recrear las condiciones de produccion
  - recurso primario (temp, intensidad y direccion del viento, precipitaciones, aportes hidricos a los embalses)
  - de generacion (total y por fuente: eol+hidro+solar)
  - planes de mantenimiento  
  - calendario (dias feriados, puente, momento del anho, 
- proyectados 
  - recurso primario (idem para historico o lo mas proximo)

## Preguntas
- como proyectar la produccion => produzco todo lo posible ? 
  - ventajas: podemos hacerlo en el pasado tb, es indep de planes de mantenimiento o roturas y de la demanda
  - inconveniente: nos alejamos de las condiciones reales
  
## Links 
- Paquete para bajar desde CMIP6 mediante R :
https://github.com/ideas-lab-nus/epwshiftr 
