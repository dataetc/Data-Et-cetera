# tidytuesday : 2021-01-19

# Set up environment ---------------------------------------

remotes::install_github("Shelmith-Kariuki/rKenyaCensus")

#list.of.packages <- c("tidytuesdayR","tidyverse","remotes","join","raster","rKenyaCensus")
list.of.packages <- c("tidytuesdayR","tidyverse","broom","hexbin","rgeos")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)


# Info on data ---------------------------------------

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


# Set up shapefile ---------------------------------------

spdf <- raster::getData("GADM", country = "KE", level = 1)

# Drop if region = Kenya
spdf@data = spdf@data %>%
  filter(NAME_1 != "KENYA")

# Check that shapefile works
plot(spdf)

# fortify data
spdf_fortified <- tidy(spdf, region = "NAME_1")


# Calculate county centroid ---------------------------------------

centers <- cbind.data.frame(data.frame(gCentroid(spdf, byid=T), id = spdf@data$NAME_1))

# check that shape file works
ggplot() +
  geom_polygon(data = spdf_fortified, aes( x = long, y = lat, group = group), fill="skyblue", color="white") +
  geom_text(data=centers, aes(x=x, y=y, label=id)) +
  theme_void() +
  coord_map()


# Read in data ---------------------------------------

tuesdata <- tidytuesdayR::tt_load('2021-01-19')

df_gender <- tuesdata$gender
df_crops <- tuesdata$crops
df_households <- tuesdata$households

# Let's try using % female as our metric
data <- df_gender %>%
  mutate(pct_female = Female / Total)


# Plot distribution of % female ---------------------------------------

data %>% 
  ggplot(aes(x = pct_female)) + 
  geom_histogram(bins=20, fill = '#69b3a2', color = 'white') + 
  scale_x_continuous(breaks = seq(1,30))


# Merge geospatial and % female data ---------------------------------------

spdf_fortified <- spdf_fortified %>%
  left_join(. , data, by=c("id"="County")) 


# Regular chloropleth map ---------------------------------------

ggplot() +
  geom_polygon(data = spdf_fortified, aes(fill =pct_female, x = long, y = lat, group = group)) +
  scale_fill_gradient(trans = "log") +
  theme_void() +
  coord_map()


# Prepare data for hex ---------------------------------------

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


# Get data ready for map ---------------------------------------

df_forGrid <- data.frame()
for(i in 1:nrow(hex_data)){
  if(!is.na(hex_data[i, 4])){
    df_forGrid <- bind_rows(df_forGrid, expand.grid(hex_data[i,1], 1:hex_data[i,4]))
  }
}

df_forGrid <- left_join(df_forGrid, hex_data, by = c("Var1" = "id"))


# Plot hex graph ---------------------------------------

df_forGrid %>%
  filter(!is.na(pct_female)) %>%
  ggplot(aes(x = x, y = y)) + 
  geom_hex(inherit.aes  = T, 
           colour = "black", 
           alpha = 0.8, 
           bins = 20) +
  geom_label(inherit.aes = T, 
             aes(label = Var1), 
             size = 4, 
             colour = "grey80", 
             fill = "grey20",
             vjust = "outward",
             hjust = "outward",
             label.padding = unit(0.2, "lines"),
             label.r = unit(0.15, "lines"),
             label.size = 0.01,
             fontface = "italic") +
  annotate("text", x = 1, y = 54, label="What percent of Kenya's population is female?", colour = "grey80", size=7, alpha=1, hjust=0, fontface = "bold") +
  theme_void() +
  xlim(-5, 60) +
  ylim(-10, 55) +
  scale_fill_viridis(
    option="B",
    trans = "log",
    breaks = c(46, 48, 50, 52, 54),
    name="% female",
    guide = guide_legend(keyheight = unit(2.5, units = "mm"),
                         keywidth=unit(10, units = "mm"),
                         label.position = "bottom",
                         title.position = 'top',
                         nrow=1)
  )  +
  ggtitle( "" ) +
  theme(
    legend.position = c(0.3, 0.09),
    legend.title=element_text(color="grey70", size = 13),
    text = element_text(color = "grey70", size = 13),
    plot.background = element_rect(fill = "grey30", color = NA), 
    panel.background = element_rect(fill = "grey30", color = NA), 
    legend.background = element_rect(fill = "grey30", color = NA),
    plot.title = element_text(size= 13, hjust=0.1, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
  ) 


# Save image ---------------------------------------

ggsave("kenya_gender.png",
       device = "png")
