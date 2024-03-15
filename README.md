# Project FSE_extremos: Uncertainty Quantification in Renewable Energy Extremes

# Problem description

Electricity generation by renewable means is a strategic decision of Uruguay energy matrix.
Among the different threads, climate change may impact on the primary ressource (i.e. sun, wind and water) availability.  
**We want to measure how the change in climatology (and not predictability), changes the generation conditions in a context of climate change**.
For this, we will simulate the average production conditions using the climatology simulated trajectories in the CMIP6 data. 

# (random notes in Spanish)

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
