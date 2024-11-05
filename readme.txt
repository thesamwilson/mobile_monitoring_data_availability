README

This repository contains supporting data and example scripts for the paper, "Mobile Monitoring Reveals the Importance of Non-Vehicular Particulate Matter Sources in London."

The files provided demonstrate the analytical methods used in the study, enabling others to replicate, reproduce, and adapt the analyses as needed.

Description of data:

data_mobile_monitoring_increments.rds

Raw mobile monitoring increments (background subtracted concentration values) and additional relevant information.

date_time:       Date and time of measurement.
location:        Measurement location.
loop_id:         Driving route/circuit unique identifier.
loop_direction:  Driving direction (AC = anticlockwise, C = clockwise)
speed_kmh:       Driving speed (kilometres per hour)
accel_kmhs:      Driving acceleration (kilometres per hour per second)
pmf_ugm:         PMfine (PM2.5) increment (micrograms per meter cubed)
pmc_ugm:         PMcoarse (PM10 - PM2.5) increment (micrograms per meter cubed)
nox_ugm:         Nitrogen oxide (NO + NO2) increment (micrograms per meter cubed)
co2_ugm:         Carbon dioxide (CO2) increment (micrograms per meter cubed)
so2_ugm:         Sulfur dioxide (SO2) increment (micrograms per meter cubed)
temperature_c:   Ambient temperature (degrees celcius)
rel_humidity:    Relative Humidity (%)
geometry:        R sf spatial data.
ulez:            Ultra Low Emission Zone (T = inside ULEZ, F = outside ULEZ)
high_emitter:    Measurement part of high emitter event
construction:    Measurement within 500 m of major construction site


data_london_road_network.rds

Network of 10 m spaced points covering the driving routes in both locations. Required by the `mobilemeasr' package to calculate distance-weighted increments.

location:        Measurement location.
road_name:       Road name.
point_id:        10 m point unique identifier.
geometry:        R sf spatial data.
long:            Longitude.
lat:             Latitude.

data_london_roads.rds

R sf object containing all roads surrounding the measurement locations in London. Required by the `mobilemeasr' package. Also useful for plotting spatial data - can be used as background layer.

id:              Road unique identifier.      
name:            Road name.
highway:         Road type.
maxspeed:        Road speed limit (miles per hour).
location:        Measurement location.
geometry:        R sf spatial data.


data_distance_weighted_increments.rds

Distance-weighted mean increments calculate using script 03_calculate_distance_weighted_oncrements.R.

point_id:        10 m point unique identifier.
location:        Measurement location.
variable:        PM type.
sigma:           Sigma value set in `mobilemeasr' function.
value:           Distance-weighted mean increment (micrograms per meter cubed)
geometry:        R sf spatial data.
id:              Road unique identifier.      
road_name:       Road name.
highway:         Road type.
maxspeed:        Road speed limit (miles per hour).

data_construction_road_network_10m.rds

Network of 10 m spaced points within 500 m of a major construction site, used in script 04_non_vehicular_sources.R. Also contains distance from the construction  site calculated along the road network. This file is essential for the analysis - if repeating this approach with a different location/source, an equivalent file will need to be constructed. 

location:        Measurement location.
construction_id: 10 m point unique identifier
geometry:        R sf spatial data.
lat:             Latitude.
lon:             Longitude.
distance_m:      Distance from the respective construction site (meters).


