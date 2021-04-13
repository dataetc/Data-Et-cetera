# tidytuesday : 2021-04-13

# Set up environment ---------------------------------------

list.of.packages <- c("tidytuesdayR","tidyverse", "gganimate")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# Doanload and install Rayshader from Github
#devtools::install_github("tylermorganwall/rayshader")

#devtools::install_github("tylermorganwall/rayrender")
library(rayshader)
# Info on data ---------------------------------------


# Read in data ---------------------------------------

tuesdata <- tidytuesdayR::tt_load('2021-04-13')

# Start this weeks --------------
df_post <- tuesdata$post_offices



# Explore some useful variables
df_post$gnis_feature_class %>% table(useNA = "always")


df_postOffices_forMap <- df_post %>%
 dplyr::filter(gnis_feature_class == "Post Office")

plot(df_postOffices_forMap$longitude, df_postOffices_forMap$latitude)

df_postOffices_forMap %>%
  pull(established) %>% table(useNA = "always")


# Establishing the postal service

map_animation <- df_postOffices_forMap %>%
  filter(established >= 1639) %>%
  ggplot(aes(x = longitude, y = latitude)) +
  geom_point(aes(color = established)) +
  geom_label(aes(x = -69, y = 80, label = round(established))) +
  scale_color_continuous(type = "viridis") +
  theme_void() +
  ggtitle(label = "The U.S. Postal Service",
          subtitle = "Covering America") +
  theme(
    legend.position = "none",
          panel.background = element_rect(fill = "black")
        )+
  transition_time(established)
  animate(map_animation)
  
  # Adding 3d

  map_posts <- df_postOffices_forMap %>%
    filter(established == 1639 ) %>%
    ggplot(aes(x = longitude, y = latitude, color = established)) +
    geom_point() +
   # geom_label(aes(x = -69, y = 80,label = round(established))) +
    scale_color_continuous(type = "viridis", limits = c(0, 2020)) +
    theme_void() 

  system.time({    
    plot_gg(map_posts, width = 3.5, multicore = TRUE, windowsize = c(800, 800),
            zoom = 0.85, phi = 35, theta = 30, sunangle = 225)

    
})
  Sys.sleep(0.2)
  render_snapshot(clear = TRUE)
  animate(map_animation)
  
  mtplot = ggplot(mtcars) +
    geom_point(aes(x = mpg, y = disp, color = cyl)) +
    scale_color_continuous(limits = c(0, 8))
  
  par(mfrow = c(1, 2))
  plot_gg(mtplot, width = 3.5, raytrace = FALSE, preview = TRUE)
  
  plot_gg(mtplot, width = 3.5, multicore = TRUE, windowsize = c(800, 800),
          zoom = 0.85, phi = 35, theta = 30, sunangle = 225, soliddepth = -100)
  Sys.sleep(0.2)
  render_snapshot(clear = TRUE)
