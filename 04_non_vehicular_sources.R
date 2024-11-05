# Script 04
# Evaluate non-vehicular PM sources.

# 1. Load packages. ----
library(tidyverse)
library(sf)
library(mgcv)

# 2. Read data. ----

# Set working directory (wd) to location of data.
setwd("local_data_location/")

# Read mobile monitoring increment data.
df_increment <- read_rds(
  "data_mobile_monitoring_increments.rds"
)

# Read construction site road network data.
df_constuction_road_network <- read_rds(
  "data_construction_road_network_10m.rds"
)

# This data contains a 10 m road network within ~500 m of each construction site
# in Central and Outer London (~1000m total centered on the middle of the site).
# The distance_m variable is the distance from the middle of the construction
# site at the respective location. NOTE: The distance data are calculated along
# the road network (not straight line distance).

# 3. Join increment and construction site road network data. ----

# Filter increment data. _______________________________________________________

df_increment_construction <- df_increment |> 
  filter(
    # Select data within 500m of a construction site.
    construction == T,
    # Remove high emitter.
    high_emitter == F
  ) |> 
  select(
    location,
    pmf_ugm,
    pmc_ugm,
    geometry
  )

# Add nearest 10 m point distance value from construction site road network data.

# Find nearest row index in construction site road network data for each row in
# the increment data.
nearest_indices <- st_nearest_feature(
  df_increment_construction,
  df_constuction_road_network
  )

df_increment_construction$distance_m <- df_constuction_road_network$distance_m[nearest_indices]

# Filter to exactly 500 m.
df_increment_construction <- df_increment_construction |> 
  filter(
    distance_m <= 500,
    distance_m >= -500
  )

# We now have all 1 Hz data within 500 m of a construction site, with an 
# associated `distance from construction site' variable.

# Plot all data at each location as sense check. _______________________________

# Central London.

df_increment_construction |> 
  filter(
    location == "central_london",
  ) |> 
  ggplot() +
  # Outer London data.
  geom_sf(
    aes(
      colour = distance_m
    )
  ) +
  # Outer London construction site.
  geom_sf(
    data = df_constuction_road_network |> 
      filter(
        location == "central_london",
        distance_m == 0
      ) |> 
      st_geometry(),
    colour = "#f2ae1b"
  ) +
  scale_colour_gradientn(
    colours = c("white", "#9d053a", "white"),
    values = scales::rescale(c(-500, 0, 500)),
    limits = c(-500, 500)
  ) +
  theme_void()

# Outer London.

df_increment_construction |> 
  filter(
    location == "outer_london",
  ) |> 
  ggplot() +
  # Outer London data.
  geom_sf(
    aes(
      colour = distance_m
    )
  ) +
  # Outer London construction site.
  geom_sf(
    data = df_constuction_road_network |> 
      filter(
        location == "outer_london",
        distance_m == 0
      ) |> 
      st_geometry(),
    colour = "#f2ae1b"
  ) +
  scale_colour_gradientn(
    colours = c("white", "#007e94", "white"),
    values = scales::rescale(c(-500, 0, 500)),
    limits = c(-500, 500)
  ) +
  theme_void()

# 4. Calculate PMfine and PMcoarse concentrations as function of distance. ----

# Central London. ______________________________________________________________
df_results_central_london <- df_increment_construction |> 
  filter(
    location == "central_london",
  )

# PMfine.
df_results_central_london$pmf_ugm_model <- predict(
  gam(
    df_results_central_london$pmf_ugm ~ s(
      df_results_central_london$distance_m,
      bs = "cs")),
  type = "response",
  se.fit = T
)$fit

# PMcoarse.
df_results_central_london$pmc_ugm_model <- predict(
  gam(
    df_results_central_london$pmc_ugm ~ s(
      df_results_central_london$distance_m,
      bs = "cs")),
  type = "response",
  se.fit = T
)$fit

# Outer London. ________________________________________________________________
df_results_outer_london <- df_increment_construction |> 
  filter(
    location == "outer_london",
  )

# PMfine.
df_results_outer_london$pmf_ugm_model <- predict(
  gam(
    df_results_outer_london$pmf_ugm ~ s(
      df_results_outer_london$distance_m,
      bs = "cs")),
  type = "response",
  se.fit = T
)$fit

# PMcoarse.
df_results_outer_london$pmc_ugm_model <- predict(
  gam(
    df_results_outer_london$pmc_ugm ~ s(
      df_results_outer_london$distance_m,
      bs = "cs")),
  type = "response",
  se.fit = T
)$fit

# Combine results.
df_results <- bind_rows(
  df_results_central_london |> distinct(distance_m, .keep_all = T),
  df_results_outer_london |> distinct(distance_m, .keep_all = T)
)

# Check results.
df_results |>
  st_drop_geometry() |> 
  pivot_longer(
    c(
      pmf_ugm_model,
      pmc_ugm_model
      ),
    names_to = "pm_type",
    values_to = "conc"
  ) |> 
  ggplot(
    aes(
      x = distance_m,
      y = conc
    )
  ) +
  geom_line() +
  facet_grid(
    cols = vars(location),
    rows = vars(pm_type),
    scales = "free_y"
  ) +
  theme_minimal()

# By changing the filtering variables prior to running the GAM, different mobile
# monitoring parameters (weather condition, driving direction, etc.) can be
# explored. This data/approach was used to create Figures 4 and S7.
