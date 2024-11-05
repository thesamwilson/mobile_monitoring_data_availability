# Script 01
# Summarise mobile monitoring increment data (shown in paper Table 2).

# 1. Load packages. ----
library(tidyverse)
library(sf)

options(scipen = 999)

# 2. Read data. ----

# Set working directory (wd) to location of data.
setwd("local_data_location/")

# Read mobile monitoring increment data.
df_increment <- read_rds(
  "data_mobile_monitoring_increments.rds"
)

# 3. Summarise data (all). ----

# Calculate site information. __________________________________________________
df_site_information <- df_increment |> 
  # Remove spatial information (not required).
  st_drop_geometry() |> 
  # Group data.
  group_by(
    location
  ) |> 
  # Summarise 
  summarise(
    n = n(),
    n_routes = max(as.numeric(loop_id)),
    mean_van_speed = round(mean(speed_kmh, na.rm = T), digits = 1),
    mean_temperature = round(mean(temperature_c, na.rm = T), digits = 1)
  )

# Calculate site pollutant means and 95% confidence intervals. _________________
df_site_pollutant <- df_increment |> 
  # Remove spatial information (not required).
  st_drop_geometry() |> 
  # Reshape data.
  pivot_longer(
    contains("_ugm"),
    names_to = "pollutant"
  ) |> 
  # Group data.
  group_by(
    location,
    pollutant
  ) |> 
  # Calculate mean.
  summarise(
    # Number of measurements.
    n = n(),
    # Mean values reported in paper Table 2.
    mean = round(mean(value, na.rm = T), digits = 2),
    # 95% confidence intervals.
    ci95 = (sd(value, na.rm = T)/sqrt(n)) * 1.96,
    # Maximum values referenced in the paper.
    max = round(max(value, na.rm = T), digits = 2)
  )

# Calculate percentage differences between site means. _________________________
df_site_pollutant <- df_site_pollutant |>
  # Remove unwanted data.
  select(
    -c(
      n,
      max
    )) |>
  # Reshape data.
  pivot_wider(
    names_from = location,
    values_from = c(mean, ci95)
  ) |> 
  # Calculate variables.
  mutate(
    perc_dif = round(
      ((mean_central_london - mean_outer_london) / mean_outer_london) * 100,
      digits = 1
    ),
    mean_ci95_central_london = paste0(
      round(mean_central_london, digits = 2),
      " ± ",
      round(ci95_central_london, digits = 2)
    ),
    mean_ci95_outer_london = paste0(
      round(mean_outer_london, digits = 2),
      " ± ",
      round(ci95_outer_london, digits = 2)
    )
  ) |> 
  # Reselect variables.
  select(
    pollutant,
    mean_ci95_central_london,
    mean_ci95_outer_london,
    perc_dif
  )

# 3. Summarise data (no high emission vehicle event). ----

# Calculate site information. __________________________________________________
df_site_information_no_he <- df_increment |> 
  # Remove high emission vehicle event.
  filter(high_emitter == F) |> 
  # Remove spatial information (not required).
  st_drop_geometry() |> 
  # Group data.
  group_by(
    location
  ) |> 
  # Summarise 
  summarise(
    n = n(),
    n_routes = max(as.numeric(loop_id)),
    mean_van_speed = round(mean(speed_kmh, na.rm = T), digits = 1),
    mean_temperature = round(mean(temperature_c, na.rm = T), digits = 1)
  )

# Calculate site pollutant means and 95% confidence intervals. _________________
df_site_pollutant_no_he <- df_increment |> 
  # Remove high emission vehicle event.
  filter(high_emitter == F) |> 
  # Remove spatial information (not required).
  st_drop_geometry() |> 
  # Reshape data.
  pivot_longer(
    contains("_ugm"),
    names_to = "pollutant"
  ) |> 
  # Group data.
  group_by(
    location,
    pollutant
  ) |> 
  # Calculate mean.
  summarise(
    # Number of measurements.
    n = n(),
    # Mean values reported in paper Table 2.
    mean = round(mean(value, na.rm = T), digits = 2),
    # 95% confidence intervals.
    ci95 = (sd(value, na.rm = T)/sqrt(n)) * 1.96,
    # Maximum values referenced in the paper.
    max = round(max(value, na.rm = T), digits = 2)
  )

# Calculate percentage differences between site means. _________________________
df_site_pollutant_no_he <- df_site_pollutant_no_he |>
  # Remove unwanted data.
  select(
    -c(
      n,
      max
    )) |>
  # Reshape data.
  pivot_wider(
    names_from = location,
    values_from = c(mean, ci95)
  ) |> 
  # Calculate variables.
  mutate(
    perc_dif = round(
      ((mean_central_london - mean_outer_london) / mean_outer_london) * 100,
      digits = 1
    ),
    mean_ci95_central_london = paste0(
      round(mean_central_london, digits = 2),
      " ± ",
      round(ci95_central_london, digits = 2)
    ),
    mean_ci95_outer_london = paste0(
      round(mean_outer_london, digits = 2),
      " ± ",
      round(ci95_outer_london, digits = 2)
    )
  ) |> 
  # Reselect variables.
  select(
    pollutant,
    mean_ci95_central_london,
    mean_ci95_outer_london,
    perc_dif
  )

