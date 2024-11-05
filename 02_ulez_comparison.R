# Script 02
# Compare inside/outside ULEZ in Outer London.

# 1. Load packages. ----
library(tidyverse)
library(sf)

# 2. Read data. ----

# Set working directory (wd) to location of data.
setwd("local_data_location/")

# Read mobile monitoring increment data.
df_increment <- read_rds(
  "data_mobile_monitoring_increments.rds"
)

# 3. Calculate Outer London average concentrations inside/outside ULEZ. ----

# Determine sample sizes.
df_increment |> count(location, ulez)

# Calculate averages with high emitter event included. _________________________
df_ulez_high_emitter <- df_increment |> 
  st_drop_geometry() |> 
  # Filter to Outer London.
  filter(
    location == "outer_london"
  ) |> 
  pivot_longer(
    contains("_ugm"),
    names_to = "pollutant"
  ) |> 
  group_by(
    ulez,
    pollutant
  ) |> 
  summarise(
    mean = round(mean(value, na.rm = T), digits = 2)
  )

# Calculate averages with high emitter event removed _________________________
df_ulez_no_high_emitter <- df_increment |> 
  st_drop_geometry() |> 
  # Filter to Outer London.
  filter(
    location == "outer_london",
    high_emitter == F # Remove high emitter event.
  ) |> 
  pivot_longer(
    contains("_ugm"),
    names_to = "pollutant"
  ) |> 
  group_by(
    ulez,
    pollutant
  ) |> 
  summarise(
    mean = round(mean(value, na.rm = T), digits = 2)
  )
