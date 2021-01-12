# tidytuesday : 2021-01-12

# Set up environment ----
list.of.packages <- c("tidytuesdayR","tidyverse","ggplot2","maps","geosphere","plyr","sp")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# Extra packages
library(leaflet)
library(geosphere)
library(stars)
library(bomrang) # Australian Bureau of Meterorlogy (BOM) images
# Info on data ----

# README : https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-01-12/readme.md

# The data this week comes from the Tate Art Museum : https://github.com/tategallery/collection

# The dataset in this repository was last updated in October 2014. Tate has no plans to resume updating this repository, but we are keeping it available for the time being in case this snapshot of the Tate collection is a useful tool for researchers and developers.
# 
# Here we present the metadata for around 70,000 artworks that Tate owns or jointly owns with the National Galleries of Scotland as part of ARTIST ROOMS. Metadata for around 3,500 associated artists is also included.
# 
# The metadata here is released under the Creative Commons Public Domain CC0 licence. Images are not included and are not part of the dataset. Use of Tate images is covered on the Copyright and permissions page. You may also license images for commercial use.
# 
# Tate requests that you actively acknowledge and give attribution to Tate wherever possible. Attribution supports future efforts to release other data. It also reduces the amount of 'orphaned data', helping retain links to authoritative sources.
# 
# Here are some examples of Tate data usage in the wild. Please submit a pull request with your creation added to this list.
# 
# Data visualisations by Florian Kräutli
# machine imagined art by Shardcore
# The Dimensions of Art by Jim Davenport
# Art as Data as Art and Part II by Oliver Keyes
# Tate Acquisition Data by Zenlan
# Tate Collection Geolocalized by Corentin Cournac, Mathieu Dauré, William Duclot and Pierre Présent
# Aspect Ratio of Tate Artworks through Time by Joseph Lewis
# 
# There are JSON files with additional metadata in the original GitHub : https://github.com/tategallery/collection

# Read in data ----
tuesdata <- tidytuesdayR::tt_load('2021-01-12')

artwork <- tuesdata$artwork
artist <- tuesdata$artists

# Create great circles, taken from : https://web.stanford.edu/~cengel/cgi-bin/anthrospace/great-circles-on-a-recentered-worldmap-in-ggplot
# Taken from : https://www.r-bloggers.com/2012/06/mapping-the-worlds-biggest-airlines/

# Lat/Long lookup ----
# for each of the cities in the artists dataset, connect to lat/long
birth <- artist[c("placeOfBirth")]
birth$city <- str_split_fixed(birth$placeOfBirth,", ",2)[,1]
birth$country <- str_split_fixed(birth$placeOfBirth,", ",2)[,2]
colnames(birth) <- c("place","city","country")

death <- artist[c("placeOfDeath")]
death$city <- str_split_fixed(death$placeOfDeath,", ",2)[,1]
death$country <- str_split_fixed(death$placeOfDeath,", ",2)[,2]
colnames(death) <- c("place","city","country")

cities <- unique(rbind(birth,death))

# Join to latitude and longitude of each city
coords <- as.data.frame(maps::world.cities)
coords$name <- gsub("'","",coords$name)  # get weird of hyphen at start of name

# Clean up names to do not match
# TO DO : deal with Yugoslavia (figure out which city it is, and assign it to the right country)
cities$country[cities$country == "Polska"] <- "Poland"
cities$country[cities$country == "Zhonghua"] <- "China"
cities$country[cities$country == "Nederland"] <- "Netherlands"
cities$country[cities$country == "Brasil"] <- "Brazil"
cities$country[cities$country == "Viet Nam"] <- "Vietnam"
cities$country[cities$country == "Sverige"] <- "Sweden"
cities$country[cities$country == "Norge"] <- "Norway"
cities$country[cities$country == "Slovenija"] <- "Slovenia"
cities$country[cities$country == "Eesti"] <- "Estonia"
cities$country[cities$country == "Hrvatska"] <- "Croatia"
cities$country[cities$country == "Magyarország"] <- "Hungary"
cities$country[cities$country == "Panamá"] <- "Panama"
cities$country[cities$country == "Prathet Thai"] <- "Thailand"
cities$country[cities$country == "United States"] <- "USA"
cities$country[cities$country == "Italia"] <- "Italy"
cities$country[cities$country == "Türkiye"] <- "Turkey"
cities$country[cities$country == "Ukrayina"] <- "Ukraine"
cities$country[cities$country == "România"] <- "Romania"
cities$country[cities$country == "Éire"] <- "Ireland"
cities$country[cities$country == "Bharat"] <- "India"
cities$country[cities$country == "Département de la, France"] <- "France"
cities$country[cities$country == "Ceská Republika"] <- "Czech Republic"
cities$country[cities$country == "Cameroun"] <- "Cameroon"
cities$country[cities$country == "Pilipinas"] <- "Philippines"
cities$country[cities$country == "Shqipëria"] <- "Albania"
cities$country[cities$country == "le, France"] <- "France"
cities$country[cities$country == "United Kingdom"] <- "UK"
cities$country[cities$country == "Al-'Iraq"] <- "Iraq"
cities$country[cities$country == "México"] <- "Mexico"
cities$country[cities$country == "Al-Jaza'ir"] <- "Algeria"
cities$country[cities$country == "Österreich"] <- "Austria"
cities$country[cities$country == "Latvija"] <- "Latvia"
cities$country[cities$country == "Makedonija"] <- "Macedonia"
cities$country[cities$country == "Slovenská Republika"] <- "Slovakia"
cities$country[cities$country == "Choson Minjujuui In'min Konghwaguk"] <- "Korea North"
cities$country[cities$country == "Suriyah"] <- "Syria"
cities$country[cities$country == "Le, France"] <- "France"
cities$country[cities$country == "Yisra'el"] <- "Israel"
cities$country[cities$country == "Schweiz"] <- "Switzerland"
cities$country[cities$country == "België"] <- "Belgium"
cities$country[cities$country == "España"] <- "Spain"
cities$country[cities$country == "Jugoslavija"] <- ""
cities$country[cities$country == "Bénin"] <- "Benin"
cities$country[cities$country == "Tunis"] <- "Tunisia"
cities$country[cities$country == "Taehan Min'guk"] <- "Korea South"
cities$country[cities$country == "Lao"] <- "Laos"
cities$country[cities$country == "Isola di, Italia"] <- "Italy"
cities$country[cities$country == "Deutschland"] <- "Germany"
cities$country[cities$country == "Suomi"] <- "Finland"
cities$country[cities$country == "Rossiya"] <- "Russia"
cities$country[cities$country == "Perú"] <- "Peru"
cities$country[cities$country == "Nihon"] <- "Japan"
cities$country[cities$country == "Al-Lubnan"] <- "Lebanon"
cities$country[cities$country == "Bosna i Hercegovina"] <- "Bosnia and Herzegovina"
cities$country[cities$country == "Ellás"] <- "Greece"
cities$country[cities$country == "D.C., Colombia"] <- "USA"
cities$country[cities$country == "Misr"] <- "Egypt"
cities$country[cities$country == "Mehoz, Yisra'el"] <- "Israel"
cities$country[cities$country == "Otok, Hrvatska"] <- "Croatia"
cities$country[cities$country == "la, France"] <- "France"

# Join to dataset of city coordinates (from package maps)
cities <- left_join(cities, coords[c("name","country.etc","lat","long")], by = c("city" = "name","country" = "country.etc"))

# Path dataframe ----
# Shows the 'from' (birthplace) and 'to' (place of death)

path <- left_join(artist, artwork, by = c("id" = "artistId"))
path <- artist[c("name","placeOfBirth","placeOfDeath")]
colnames(path) <- c("artist","from","to")

# TO DO : think about this -- could manually look up a few, or presume NA means birth = death?
# Drop observations where either to or from is missing
path <- path[!is.na(path$from) & !is.na(path$to),]

# Find number of paintings, per artist
path.ag <- ddply(path, c("from","to"), function(x) count(x$to))

# Add lat and long from the cities df we made earlier
to.ll <- merge(path.ag, cities, all.x = T, by.x = "to", by.y = "place")
from.ll <- merge(path.ag, cities, all.x = T, by.x = "from", by.y = "place")

# TO DO : clean up
# Drop where we didn't have a match to lat/long
to.ll <- to.ll[!is.na(to.ll$lat),] %>%
  dplyr::rename(latitude = lat, longitude = long)
from.ll <- from.ll[!is.na(from.ll$lat),]
from.ll %>% 
  dplyr::rename(latitude = lat, 
         longitude = long)

# calculate routes -- Dateline Break FALSE, otherwise we get a bump in the shifted ggplots
location.ll <- c(-2.7814688, 51.8078055)

rts <- gcIntermediate(location.ll, from.ll[,c('long', 'lat')], 100, breakAtDateLine=FALSE, addStartEnd=TRUE, sp=TRUE)
rts <- as(rts, "SpatialLinesDataFrame")
rts.ff <- fortify(rts)

to.ll$id <-as.character(c(1:nrow(to.ll))) # that rts.ff$id is a char
gcircles <- merge(rts.ff, to.ll, all.x=T, by="id") # join attributes, we keep them all, just in case

### Recenter ####
center <- -2 # positive values only - US centered view is 260

# shift coordinates to recenter great circles
gcircles$long.recenter <-  ifelse(gcircles$long  < center - 180 , gcircles$long + 360, gcircles$long) 

# shift coordinates to recenter worldmap
worldmap <- map_data ("world")
worldmap$long.recenter <-  ifelse(worldmap$long  < center - 180 , worldmap$long + 360, worldmap$long)

### Function to regroup split lines and polygons
# takes dataframe, column with long and unique group variable, returns df with added column named group.regroup
RegroupElements <- function(df, longcol, idcol){  
  g <- rep(1, length(df[,longcol]))
  if (diff(range(df[,longcol])) > 300) {          # check if longitude within group differs more than 300 deg, ie if element was split
    d <- df[,longcol] > mean(range(df[,longcol])) # we use the mean to help us separate the extreme values
    g[!d] <- 1     # some marker for parts that stay in place (we cheat here a little, as we do not take into account concave polygons)
    g[d] <- 2      # parts that are moved
  }
  g <-  paste(df[, idcol], g, sep=".") # attach to id to create unique group variable for the dataset
  df$group.regroup <- g
  df
}

### Function to close regrouped polygons
# takes dataframe, checks if 1st and last longitude value are the same, if not, inserts first as last and reassigns order variable
ClosePolygons <- function(df, longcol, ordercol){
  if (df[1,longcol] != df[nrow(df),longcol]) {
    tmp <- df[1,]
    df <- rbind(df,tmp)
  }
  o <- c(1: nrow(df))  # rassign the order variable
  df[,ordercol] <- o
  df
}

# now regroup
gcircles.rg <- ddply(gcircles, .(id), RegroupElements, "long.recenter", "id")
worldmap.rg <- ddply(worldmap, .(group), RegroupElements, "long.recenter", "group")

# close polys
worldmap.cp <- ddply(worldmap.rg, .(group.regroup), ClosePolygons, "long.recenter", "order")  # use the new grouping var

# plot 1
ggplot() +
  geom_polygon(aes(long.recenter, lat, group=group.regroup), size = 0.2, fill="#110f52", data=worldmap.cp) +
  geom_line(aes(long.recenter,lat,group=group.regroup, color = "#f0e891", alpha = 1), size = 0.4, data= gcircles.rg) +
  geom_point(aes(x = from.ll$long, y = from.ll$lat), colour = "#f0e891", size = 1, alpha = 0.5) +
  theme_void() +
  theme(panel.background = element_rect(fill = "#080727"), 
        panel.grid.minor = element_blank(), 
        panel.grid.major = element_blank(),  
        axis.ticks = element_blank(), 
        axis.title.x = element_blank(),
        legend.position = "none") +
  ylim(-60, 90) +
  coord_equal() +
  geom_stars(data= sat_vis)

# --------------------------
rts %>%
  leaflet(width = 1040, ## default setting for nice visuals
          height = 800,
          ## the options below define the initial coordinates (center)
          ##, the initial zoom (x2) and the bounds of the map
          options = leafletOptions(center = c(-2,0),
                                   zoom = 3,
                                   maxBounds = list(c(-90, -180),
                                                    c(90,180)))
  )  %>% 
#  addProviderTiles(providers$NASAGIBS.ViirsEarthAtNight2012) %>%
  addProviderTiles(providers$NASAGIBS.ViirsEarthAtNight2012) %>%
   addPolylines(color = "white", opacity = 0.5, weight =  0.9)
