# tidytuesday : 2021-01-19

# Set up environment ----
remotes::install_github("Shelmith-Kariuki/rKenyaCensus")

list.of.packages <- c("tidytuesdayR","tidyverse","remotes","join","raster","rKenyaCensus")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# Info on data ----

# README : 

# The data this week comes from rKenyaCensus courtesy of Shelmith Kariuki. Shelmith wrote about these datasets on her blog.
# 
# rKenyaCensus is an R package that contains the 2019 Kenya Population and Housing Census results. The results were 
# released by the Kenya National Bureau of Statistics in February 2020, and published in four different pdf files (Volume 
# 1 - Volume 4).
# 
# The 2019 Kenya Population and Housing Census was the eighth to be conducted in Kenya since 1948 and was conducted from 
# the night of 24th/25th to 31st August 2019. Kenya leveraged on technology to capture data during cartographic mapping, 
# enumeration and data transmission, making the 2019 Census the first paperless census to be conducted in Kenya


# library
library(tidyverse)
library(geojsonio)
library(RColorBrewer)
library(rgdal)
library(broom)
library(rgeos)
library(hexbin)
library(tidyverse)
library(viridis)
library(hrbrthemes)
library(mapdata)

data_example <- read.table("https://raw.githubusercontent.com/holtzy/data_to_viz/master/Example_dataset/17_ListGPSCoordinates.csv", sep=",", header=T)

# Set up shapefile
spdf <- raster::getData("GADM", country = "KE", level = 1)

# Bit of reformating
spdf@data = spdf@data %>%
  filter(NAME_1 != "KENYA")

# Show it
plot(spdf)

# I need to 'fortify' the data to be able to show it with ggplot2 (we need a data frame format)
spdf_fortified <- tidy(spdf, region = "NAME_1")

# Calculate the centroid of each county, so that we can create hex map
centers <- cbind.data.frame(data.frame(gCentroid(spdf, byid=T), id = spdf@data$NAME_1))

# check that shape file works
ggplot() +
  geom_polygon(data = spdf_fortified, aes( x = long, y = lat, group = group), fill="skyblue", color="white") +
  geom_text(data=centers, aes(x=x, y=y, label=id)) +
  theme_void() +
  coord_map()

# Read in data ----
tuesdata <- tidytuesdayR::tt_load('2021-01-19')

df_gender <- tuesdata$gender
df_crops <- tuesdata$crops
df_households <- tuesdata$households
df_water <- rKenyaCensus::V4_T2.15

# Let's try using % female as our metric
data <- df_gender %>%
  mutate(pct_female = Female / Total)

# Plot distribution of % female
data %>% 
  ggplot(aes(x = pct_female)) + 
  geom_histogram(bins=20, fill = '#69b3a2', color = 'white') + 
  scale_x_continuous(breaks = seq(1,30))

# Merge geospatial and numerical information
spdf_fortified <- spdf_fortified %>%
  left_join(. , data, by=c("id"="County")) 

# Regular chloropleth map
ggplot() +
  geom_polygon(data = spdf_fortified, aes(fill =pct_female, x = long, y = lat, group = group)) +
 # geom_text(inherit.aes = T, aes(label = id)) + 
  scale_fill_gradient(trans = "log") +
  theme_void() +
  coord_map()

# # Hex Map
# hex_data <- left_join(centers, data, by = c("id" = "County"))
# 
# hex_data <- hex_data %>%
#   dplyr::select(id, x, y, pct_female) %>%
#   mutate(pct_female = round(100* pct_female)) 
# 
# df_forGrid <- data.frame()
# for(i in 1:nrow(hex_data)){
#   if(!is.na(hex_data[i, 4])){
#   df_forGrid <- bind_rows(df_forGrid, expand.grid(hex_data[i,1], 1:hex_data[i,4]))
#   }
# }
# 
# df_forGrid <- left_join(df_forGrid, hex_data, by = c("Var1" = "id"))

# Hex data 
# Manually code lat/long to make it look like the map
hex_data <- left_join(centers, data, by = c("id" = "County"))
hex_data$x_org <- hex_data$x
hex_data$y_org <- hex_data$y
hex_data$x <- NA
hex_data$y <- NA

hex_data <- hex_data %>%
  arrange(x_org) %>%
  mutate(x = row_number())

hex_data <- hex_data %>%
  arrange(y_org) %>%
  mutate(y = row_number())

hex_data <- hex_data %>%
   dplyr::select(id, x, y, pct_female) %>%
   mutate(pct_female = round(100* pct_female)) 

df_forGrid <- data.frame()
for(i in 1:nrow(hex_data)){
   if(!is.na(hex_data[i, 4])){
   df_forGrid <- bind_rows(df_forGrid, expand.grid(hex_data[i,1], 1:hex_data[i,4]))
   }
 }
 
df_forGrid <- left_join(df_forGrid, hex_data, by = c("Var1" = "id"))

# Plot hex graph
df_forGrid %>%
  filter(!is.na(pct_female)) %>%
  ggplot(aes(x = x, y = y)) + 
  geom_hex(inherit.aes  = T, colour = "black", size = 0.1) +
  geom_text(inherit.aes = T, aes(label = Var1), nudge_x = 1, nudge_y = -0.6) +
  annotate("text", x = 1, y = 53, label="Percent of population that is female", colour = "black", size=5, alpha=1, hjust=0) +
  theme_void() +
  xlim(1, 60) +
  ylim(-10, 55) +
  scale_fill_viridis(
    option="B",
    trans = "log",
    breaks = c(45, 46, 47, 48, 49, 50, 51),
    name="% female",
    guide = guide_legend(keyheight = unit(2.5, units = "mm"),
                         keywidth=unit(10, units = "mm"),
                         label.position = "bottom",
                         title.position = 'top',
                         nrow=1)
  )  +
  ggtitle( "" ) +
  theme(
    legend.position = c(0.8, 0.09),
    legend.title=element_text(color="black", size = 13),
    text = element_text(color = "#22211d", size = 13),
    plot.background = element_rect(fill = "#f5f5f2", color = NA), 
    panel.background = element_rect(fill = "#f5f5f2", color = NA), 
    legend.background = element_rect(fill = "#f5f5f2", color = NA),
    plot.title = element_text(size= 13, hjust=0.1, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
  ) 






# Radial Bar Chart (by Region)-------
# Make the plot
df_crops %>%
  gather(Crop, Value, -SubCounty) %>%
  filter(SubCounty != "KENYA") %>%
  group_by(SubCounty) %>%
  filter(Crop != "Farming") %>%
  mutate( Value = Value / sum(Value, na.rm = TRUE)) %>%
  ggplot( aes(x=Crop, y=Value, fill = Crop)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
  # This add the bars with a blue color
  geom_bar(stat="identity", fill=alpha("blue", 0.3)) +
  facet_wrap(~SubCounty) +
  # Limits of the plot = very important. The negative value controls the size of the inner circle, the positive one is useful to add size over each bar
  #ylim(100,1200) +
  # Custom the theme: no axis title and no cartesian grid
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
    # plot.margin = unit(rep(-2,4), "cm")     # This remove unnecessary margin around plot
  ) +
  # This makes the coordinate polar instead of cartesian.
  coord_polar(start = 0)


# Radial Bar Chart (by Crop) -----
df_crops %>%
  gather(Crop, Value, -SubCounty) %>%
  filter(SubCounty != "KENYA") %>%
  #filter(Crop != "Farming") %>%
  group_by(Crop) %>%
  mutate( Percent = Value / sum(Value, na.rm = TRUE)) %>%
  filter(Crop %in% c("Tea", "Coffee", "Citrus")) %>%
  filter(!is.na(Percent)) %>%
  ggplot( aes(x= SubCounty, y=Percent)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
  # This add the bars with a blue color
  geom_bar(stat="identity", fill=alpha("blue", 0.3)) +
  facet_wrap(~Crop) +
  # Limits of the plot = very important. The negative value controls the size of the inner circle, the positive one is useful to add size over each bar
  ylim(0,0.4) +
  # Custom the theme: no axis title and no cartesian grid
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
    # plot.margin = unit(rep(-2,4), "cm")     # This remove unnecessary margin around plot
  ) +
  # This makes the coordinate polar instead of cartesian.
  coord_polar(start = 0)


# Make a Kenya map--------

# Set up shapefile
shapefile_kenya <- raster::getData("GADM", country="KE", level=1)
regions <- tolower(shapefile_kenya@data$NAME_1)
count<-sample(1:1000,47)     #or any other data you can associate with admin level here
count_df<-data.frame(NAME_1, count)

df_crops_forMap <- df_crops %>%
  filter(SubCounty != "KENYA") %>%
  mutate(region = tolower(SubCounty),
         region = gsub("/", "-", region),
         region = ifelse(region == "taita-taveta", "taita taveta", region))

# Combine the dataset with the shapefile
  index_ofMatch <- match(regions, df_crops_forMap$region)

  # Check the matching between datasets:
  cbind(shapefile_kenya@data, df_crops_forMap[index_ofMatch,]) %>%
    dplyr::select(NAME_1, region)
 

shapefile_kenya@data <- cbind(shapefile_kenya@data, df_crops_forMap[index_ofMatch,])
Kenya_df <- fortify(shapefile_kenya)
Kenya_df <-plyr::join(Kenya_df, shapefile_kenya@data %>% mutate(id = as.character(row_number())) %>% filter(id == "1"), by = c("id"))

#Kenya1_df <- join(Kenya1_df,Kenya1_UTM@data, by="id")

theme_opts<-list(theme(panel.grid.minor = element_blank(),
                       panel.grid.major = element_blank(),
                       panel.background = element_blank(),
                       plot.background = element_blank(),
                       axis.line = element_blank(),
                       axis.text.x = element_blank(),
                       axis.text.y = element_blank(),
                       axis.ticks = element_blank(),
                       axis.title.x = element_blank(),
                       axis.title.y = element_blank(),
                       plot.title = element_blank()))

  plot(shapefile_kenya)
ggplot() +
  geom_polygon(data = Kenya_df, aes(x = long, y = lat, group = group, fill =
                                       Avocado), color = "black", size = 0.25) +
  theme(aspect.ratio=1)+
  scale_fill_distiller(name="Count", palette = "YlGn")+
  labs(title="Nice Map") +
  theme_opts
