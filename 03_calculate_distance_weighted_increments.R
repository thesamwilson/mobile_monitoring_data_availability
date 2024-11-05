# Script 03
# Calculate distance-weighted mean concentration values.

# 1. Load packages. ----
library(tidyverse)
library(sf)
library(mobilemeasr)

# 2. Read data. ----

# Set working directory (wd) to location of data.
setwd("local_data_location/")

# Read mobile monitoring increment data.
df_increment <- read_rds(
  "data_mobile_monitoring_increments.rds"
)

# Read road network data (10m points).
df_road_network_10m <- read_rds(
  "data_london_road_network_10m.rds"
)

# Read london roads data.
df_london_roads <- read_rds(
  "data_london_roads.rds"
)

# 3. Calculate distance-weighted mean concentrations. ----

# Nest increment data by loop.
df_increment_nest_loop <- df_increment|> 
  select(-c(
    nox_ugm,
    co2_ugm,
    so2_ugm
  )) |> 
  # Only perform analysis on variables of interest.
  pivot_longer(
    c(
      pmf_ugm,
      pmc_ugm
    ),
    names_to = "variable"
  ) |> 
  nest_by(
    location,
    loop_id,
    variable
  )

# Nest road network data by location.
df_road_network_nest_location <- df_road_network_10m |> 
  nest_by(
    location
    )

# Join increment and road network data.
df_increment_nest_roads <- df_increment_nest_loop |> 
  left_join(
    df_road_network_nest_location,
    by = "location",
    suffix = c(
      "",
      "_roads"
      )
  )

# Calculate first (drive pass, distance-weighted) mean for each nested loop.
df_mean_1_nest <- df_increment_nest_roads |> 
  mutate(
    results = list(
      # mobilemeasr function.
      st_weighted_mean(
        data,
        data_roads,
        variable = "value",
        sigma = 100
      )
    )
  )

# Unnest first mean results.
df_mean_1 <- df_mean_1_nest |> 
  select(
    -c(
      data,
      data_roads
      )
    ) |> 
  unnest(
    results
    )

# Convert dataframe to spatial object.
df_mean_1 <- df_mean_1 |> 
   rename(point_id = id) |> 
  st_from_df() |> 
  st_join(
    st_london_roads |> 
      select(
        -location
        ),
    st_nearest_feature
  )

# Calculate second (arithmetic) mean at each 10 m point across all loops.
df_mean_2 <- df_mean_1 |>  
  group_by(
    id,
    location,
    variable,
    lat,
    long,
    sigma
  ) |> 
  summarise(
    across(
      value,
      ~mean(., na.rm = T))
  )

# Convert data frame to spatial object.
df_mean_2 <- df_mean_2 |> 
  rename(
    point_id = id
    ) |>  
  st_from_df() |> 
  st_join(
    st_london_roads |> 
      select(
        -location
        ),
    st_nearest_feature
  )

# This is the data used to create Figure 2
# (contained in data_distance_weighted_increments.rds).
