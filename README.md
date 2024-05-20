# Project FSE_extremos: Uncertainty Quantification in Renewable Energy Extremes

# Problem description

Electricity generation by renewable means is a strategic decision of Uruguay energy matrix.
Among the different threads, climate change may impact on the primary ressource (i.e. sun, wind and water) availability.  
**We want to measure how the change in climatology (and not predictability), changes the generation conditions in a context of climate change**.
For this, we will simulate the average production conditions using the climatology simulated trajectories in the CMIP6 data. 

### Data

## Wishlist of data we might need:
- [X] historical => these are useful for recreating production conditions
  - [X] primary resource (temperature, wind intensity and direction, precipitation, water contributions to reservoirs)
  - ~~generation (total and by source: wind+hydro+solar)~~
  - ~~maintenance plans~~
  - [X] calendar (holidays, bridge days, time of the year)
- [X] projected 
  - [X] primary resource (same as historical or as close as possible)

## Questions
- ~~how to project production => do I produce as much as possible?~~
  - ~~advantages: we can do it in the past too, it's independent of maintenance plans or breakdowns and of demand~~
  - ~~disadvantage: we move away from real conditions~~

## Links
- ~~Package to download from CMIP6 using R:
https://github.com/ideas-lab-nus/epwshiftr~~
=> we use `cpiapi`, the `Python` implementation of the Climate Data Store API
