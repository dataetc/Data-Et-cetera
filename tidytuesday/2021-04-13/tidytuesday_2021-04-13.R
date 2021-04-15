# tidytuesday : 2021-04-13

# Set up environment ---------------------------------------

list.of.packages <- c("tidytuesdayR","tidyverse", "gganimate", "mapproj", "usmap")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)


# Info on data ---------------------------------------

# README: https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-04-13/readme.md

# The data this week comes from Cameron Blevins and Richard W. Helbock. Their website has more details:
#   
#   US Post Offices
# 
# Please Cite them when using this data:
#   
#   "Blevins, Cameron; Helbock, Richard W., 2021, "US Post Offices", https://doi.org/10.7910/DVN/NUKCNA, 
#   Harvard Dataverse, V1, UNF:6:8ROmiI5/4qA8jHrt62PpyA== [fileUNF]"
# 
# US Post Offices is a spatial-historical dataset containing records for 166,140 post offices that operated 
# in the United States between 1639 and 2000. The dataset provides a year-by-year snapshot of the national 
# postal system over multiple centuries, making it one of the most fine-grained and expansive datasets currently 
# available for studying the historical geography of the United States


# Read in data ---------------------------------------
tuesdata <- tidytuesdayR::tt_load('2021-04-13')
df_post <- tuesdata$post_offices

# Explore some useful variables
df_post$gnis_feature_class %>% table(useNA = "always")

df_postOffices_forMap <- df_post %>%
 dplyr::filter(gnis_feature_class == "Post Office")

plot(df_postOffices_forMap$longitude, df_postOffices_forMap$latitude)

df_postOffices_forMap %>%
  pull(established) %>% table(useNA = "always")

# Establishing the postal service
US <- map_data("world") %>% 
  filter(region=="USA") %>%
  filter(!(long > 0 & subregion %in% c("Alaska")))

States <- map_data("state")
        
# Create visual
map_animation <- df_postOffices_forMap %>%
  filter(established >= 1639) %>%
#  filter(between(established, 1940, 1941)) %>%
  ggplot(aes(x = longitude, y = latitude)) +
  # Plot U.S. outlines
  geom_polygon(data = US, aes(x=long, y = lat, group = group), fill="black", color = rgb(0/255,34/255,51/255), alpha = 1) +
  # Plot State outlines
  geom_polygon(data = States, aes(x = long, y = lat, group = group), fill = "black", color = rgb(0/255,34/255,51/255), alpha = 1) +
  # Plot Post office locations
  geom_point(aes(color = established), size = 2) +
  # Text Label
  geom_label(aes(x = -80, y = 80, label = paste0("Established in ", round(established, 0))), 
             fill = "black", 
             color = "white",
             label.padding = unit(1, "line"),
             label.size = NA, 
             size = 6, 
             fontface = "italic") +
  geom_label(aes(x = -180, y = 10, label = "Source: Blevins, Cameron; Helbock, Richard W., 2021, 'US Post Offices', https://doi.org/10.7910/DVN/NUKCNA,"), 
             fill = "black", 
             color = "white",
             label.padding = unit(0, "line"),
             label.size = NA, 
             size = 3, 
             fontface = "italic",
             hjust = 0) +
  geom_label(aes(x = -180, y = 8, label = "                Harvard Dataverse, V1, UNF:6:8ROmiI5/4qA8jHrt62PpyA== [fileUNF]"), 
             fill = "black", 
             color = "white",
             label.padding = unit(0, "line"),
             label.size = NA, 
             size = 3, 
             fontface = "italic",
             hjust = 0) +
  geom_label(aes(x = -180, y = 6, label = "@data_etc"), 
             fill = "black", 
             color = "white",
             label.padding = unit(0, "line"),
             label.size = NA, 
             size = 3, 
             fontface = "italic",
             hjust = 0) +
  scale_color_continuous(type = "viridis") +
  coord_map("bonne", lat0 = 10) +
  theme_void() +
  ggtitle(label = "The U.S. Postal Service: 1639 to 2000") + 
  theme(
    legend.position = "none",
    panel.background = element_rect(fill = "black"),
    plot.background = element_rect(fill = "black"),
    plot.title=element_text(family='', hjust = 0.5, face='bold', colour='white', size=20),
    plot.subtitle=element_text(size=12, hjust = 0.5, face="italic", color="white")
  ) +
  transition_time(established)

animate(map_animation, fps = 7, height = 600, width = 800, end_pause = 2) %>%
  gganimate::anim_save(filename = "./output.gif", .)

