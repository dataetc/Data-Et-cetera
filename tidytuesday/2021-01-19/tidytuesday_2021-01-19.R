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

# Read in data ----
tuesdata <- tidytuesdayR::tt_load('2021-01-19')

df_gender <- tuesdata$gender
df_crops <- tuesdata$crops
df_households <- tuesdata$households

df_water <- rKenyaCensus::V4_T2.15

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
