# tidytuesday : 2021-01-12

# Set up environment ----
list.of.packages <- c("tidytuesdayR","tidyverse","plyr","maps","leaflet","gifski","geosphere","mapview","htmltools")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# Info on data ----

# README : https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-01-12/readme.md

# The data this week comes from the Tate Art Museum : https://github.com/tategallery/collection
# The dataset in this repository was last updated in October 2014. Tate has no plans to resume updating this repository, but we are keeping it available for the time being in case this snapshot of the Tate collection is a useful tool for researchers and developers.
# Here we present the metadata for around 70,000 artworks that Tate owns or jointly owns with the National Galleries of Scotland as part of ARTIST ROOMS. Metadata for around 3,500 associated artists is also included.
# 
# The metadata here is released under the Creative Commons Public Domain CC0 licence. Images are not included and are not part of the dataset. Use of Tate images is covered on the Copyright and permissions page. You may also license images for commercial use.
# Tate requests that you actively acknowledge and give attribution to Tate wherever possible. Attribution supports future efforts to release other data. It also reduces the amount of 'orphaned data', helping retain links to authoritative sources.
# 
# There are JSON files with additional metadata in the original GitHub : https://github.com/tategallery/collection

# Read in data ----
tuesdata <- tidytuesdayR::tt_load('2021-01-12')

# Grab the first year that each artist was acquired by the museum 
artwork <- tuesdata$artwork %>%
  select(artist, artistId, acquisitionYear) %>% 
  dplyr::group_by(artist, artistId) %>%
  dplyr::summarise(year_first_acquired = min(acquisitionYear, na.rm = TRUE))
artist <- tuesdata$artists

# Create great circles, adapted from/inspired by : 
# 1. https://web.stanford.edu/~cengel/cgi-bin/anthrospace/great-circles-on-a-recentered-worldmap-in-ggplot
# 2. https://www.r-bloggers.com/2012/06/mapping-the-worlds-biggest-airlines/

# Lat/Long lookup ----
# for each of the cities in the artists dataset, connect to lat/long
cities <- artist[c("placeOfBirth")]
cities$city <- str_split_fixed(cities$placeOfBirth,", ",2)[,1]
cities$country <- str_split_fixed(cities$placeOfBirth,", ",2)[,2]
colnames(cities) <- c("place","city","country")

# Where city is not available, replace country with city 
cities$country[(is.na(cities$country) | cities$country == "") & !is.na(cities$city)] <- cities$city[is.na(cities$country) & !is.na(cities$city)]

# Join to latitude and longitude of each city
coords <- as.data.frame(maps::world.cities)
coords$name <- gsub("'","",coords$name)  # get weird of hyphen at start of name

# Clean up cities & countries ----
# Phase 1 : translate country names to English
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
cities$country[cities$country == "Al-'Iraq"] <- "Iraq"
cities$country[cities$country == "Al-'Iraq"] <- "Iraq"
cities$country[cities$country == "Îran"] <- "Iran"
cities$country[cities$country == "Ísland"] <- "Iceland"
cities$country[cities$country == "Danmark"] <- "Denmark"

# Join to dataset of city coordinates (from package maps) to see which ones remain to be cleaned
cities <- left_join(cities, coords[c("name","country.etc","lat","long")], by = c("city" = "name","country" = "country.etc"))

# Phase 2 : Where city not easily available, replace with country capitol
# First, clean up Yugoslavia.  Identify current country based on city name
cities$country[cities$city == "Novi Sad"] <- "Serbia"
cities$country[cities$city == "Sid"] <- "Serbia"
cities$country[cities$city == "Beograd"] <- "Serbia"

# Then fill in capitols
cities$city[is.na(cities$lat) & cities$country == "USA"] <- "Washington"
cities$city[is.na(cities$lat) & cities$country == "UK"] <- "London"
cities$city[is.na(cities$lat) & cities$country == "Israel"] <- "Jerusalem"
cities$city[is.na(cities$lat) & cities$country == "Germany"] <- "Berlin"
cities$city[is.na(cities$lat) & cities$country == "Poland"] <- "Warsaw"
cities$city[is.na(cities$lat) & cities$country == "Italy"] <- "Rome"
cities$city[is.na(cities$lat) & cities$country == "Argentina"] <- "Buenos Aires"
cities$city[is.na(cities$lat) & cities$country == "Switzerland"] <- "Bern"
cities$city[is.na(cities$lat) & cities$country == "Finland"] <- "Helsinki"
cities$city[is.na(cities$lat) & cities$country == "China"] <- "Beijing"
cities$city[is.na(cities$lat) & cities$country == "Turkey"] <- "Ankara"
cities$city[is.na(cities$lat) & cities$country == "Iraq"] <- "Baghdad"
cities$city[is.na(cities$lat) & cities$country == "Belgium"] <- "Brussels"
cities$city[is.na(cities$lat) & cities$country == "Russia"] <- "Moscow"
cities$city[is.na(cities$lat) & cities$country == "France"] <- "Paris"
cities$city[is.na(cities$lat) & cities$country == "Malaysia"] <- "Kuala Lumpur"
cities$city[is.na(cities$lat) & cities$country == "Netherlands"] <- "Amsterdam"
cities$city[is.na(cities$lat) & cities$country == "Portugal"] <- "Lisbon"
cities$city[is.na(cities$lat) & cities$country == "Mexico"] <- "Mexico City"
cities$city[is.na(cities$lat) & cities$country == "Spain"] <- "Madrid"
cities$city[is.na(cities$lat) & cities$country == "Peru"] <- "Lima"
cities$city[is.na(cities$lat) & cities$country == "Brazil"] <- "Brasilia"
cities$city[is.na(cities$lat) & cities$country == "Ukraine"] <- "Kiev"
cities$city[is.na(cities$lat) & cities$country == "Îran"] <- "Tehran"
cities$city[is.na(cities$lat) & cities$country == "Venezuela"] <- "Caracas"
cities$city[is.na(cities$lat) & cities$country == "Pakistan"] <- "Islamabad"
cities$city[is.na(cities$lat) & cities$country == "Japan"] <- "Tokyo"
cities$city[is.na(cities$lat) & cities$country == "Vietnam"] <- "Ha Noi"
cities$city[is.na(cities$lat) & cities$country == "Romania"] <- "Bucharest"
cities$city[is.na(cities$lat) & cities$country == "Australia"] <- "Canberra"
cities$city[is.na(cities$lat) & cities$country == "Algeria"] <- "Algiers"
cities$city[is.na(cities$lat) & cities$country == "Canada"] <- "Ottawa"
cities$city[is.na(cities$lat) & cities$country == "Lebanon"] <- "Bayrut"
cities$city[is.na(cities$lat) & cities$country == "Sweden"] <- "Stockholm"
cities$city[is.na(cities$lat) & cities$country == "Ireland"] <- "Dublin"
cities$city[is.na(cities$lat) & cities$country == "Austria"] <- "Vienna"
cities$city[is.na(cities$lat) & cities$country == "South Africa"] <- "Pretoria"
cities$city[is.na(cities$lat) & cities$country == "Bosnia and Herzegovina"] <- "Sarajevo"
cities$city[is.na(cities$lat) & cities$country == "Uganda"] <- "Kampala"
cities$city[is.na(cities$lat) & cities$country == "Norway"] <- "Oslo"
cities$city[is.na(cities$lat) & cities$country == "India"] <- "Delhi"
cities$city[is.na(cities$lat) & cities$country == "New Zealand"] <- "Wellington"
cities$city[is.na(cities$lat) & cities$country == "Cuba"] <- "Havanna"
cities$city[is.na(cities$lat) & cities$country == "Greece"] <- "Athens"
cities$city[is.na(cities$lat) & cities$country == "Colombia"] <- "Bogota"
cities$city[is.na(cities$lat) & cities$country == "Latvia"] <- "Riga"
cities$city[is.na(cities$lat) & cities$country == "Bulgaria"] <- "Sofia"
cities$city[is.na(cities$lat) & cities$country == "Slovenia"] <- "Ljubljana"
cities$city[is.na(cities$lat) & cities$country == "Chile"] <- "Santiago"
cities$city[is.na(cities$lat) & cities$country == "Czech Republic"] <- "Prague"
cities$city[is.na(cities$lat) & cities$country == "Macedonia"] <- "Skopje"
cities$city[is.na(cities$lat) & cities$country == "Denmark"] <- "Copenhagen"
cities$city[is.na(cities$lat) & cities$country == "Egypt"] <- "Cairo"
cities$city[is.na(cities$lat) & cities$country == "Estonia"] <- "Tallinn"
cities$city[is.na(cities$lat) & cities$country == "Cameroon"] <- "Yaounde"
cities$city[is.na(cities$lat) & cities$country == "Slovakia"] <- "Bratislava"
cities$city[is.na(cities$lat) & cities$country == "Benin"] <- "Porto-Novo"
cities$city[is.na(cities$lat) & cities$country == "Croatia"] <- "Zagreb"
cities$city[is.na(cities$lat) & cities$country == "Bahamas"] <- "Nassau"
cities$city[is.na(cities$lat) & cities$country == "Indonesia"] <- "Jakarta"
cities$city[is.na(cities$lat) & cities$country == "Tanzania"] <- "Dodoma"
cities$city[is.na(cities$lat) & cities$country == "Bangladesh"] <- "Dhaka"
cities$city[is.na(cities$lat) & cities$country == "Tunisia"] <- "Tunis"
cities$city[is.na(cities$lat) & cities$country == "Moldova"] <- "Chisinau"
cities$city[is.na(cities$lat) & cities$country == "Hungary"] <- "Budapest"
cities$city[is.na(cities$lat) & cities$country == "Mauritius"] <- "Port Louis"
cities$city[is.na(cities$lat) & cities$country == "Korea North"] <- "Pyongyang"
cities$city[is.na(cities$lat) & cities$country == "Korea South"] <- "Soul"
cities$city[is.na(cities$lat) & cities$country == "Sri Lanka"] <- "Colombo"
cities$city[is.na(cities$lat) & cities$country == "Luxembourg"] <- "Luxemburg"
cities$city[is.na(cities$lat) & cities$country == "Philippines"] <- "Manila"
cities$city[is.na(cities$lat) & cities$country == "Jamaica"] <- "Kingston"
cities$city[is.na(cities$lat) & cities$country == "Kenya"] <- "Nairobi"
cities$city[is.na(cities$lat) & cities$country == "Laos"] <- "Vientiane"
cities$city[is.na(cities$lat) & cities$country == "Malta"] <- "Valletta"
cities$city[is.na(cities$lat) & cities$country == "Panama"] <- "Panama"
cities$city[is.na(cities$lat) & cities$country == "Albania"] <- "Tirana" 
cities$city[is.na(cities$lat) & cities$country == "Nicaragua"] <- "Managua"
cities$city[is.na(cities$lat) & cities$country == "Syria"] <- "Damascus"
cities$city[is.na(cities$lat) & cities$country == "Thailand"] <- "Bangkok"
cities$city[is.na(cities$lat) & cities$country == "Guyana"] <- "Georgetown"         
cities$city[is.na(cities$lat) & cities$country == "Zambia"] <- "Lusaka"
cities$city[is.na(cities$lat) & cities$country == "Iceland"] <- "Reykjavik"
cities$city[is.na(cities$lat) & cities$country == "Belarus"] <- "Minsk"
cities$city[is.na(cities$lat) & cities$country == "Serbia"] <- "Belgrade"

# Join to dataset of city coordinates (from package maps) to see which ones remain to be cleaned
cities <- left_join(cities[c("place","city","country")], coords[c("name","country.etc","lat","long")], by = c("city" = "name","country" = "country.etc"))

# Phase 3 : Clean up U.S. States.  Replace with state capitol where it doesn't match
cities$city[is.na(cities$lat) & cities$country == "Rhode Island"] <- "Providence"
cities$city[is.na(cities$lat) & cities$country == "Nevada"] <- "Carson city"
cities$city[is.na(cities$lat) & cities$country == "Wisconsin"] <- "Madison"
cities$city[is.na(cities$lat) & cities$country == "Arkansas"] <- "Little Rock"
cities$city[is.na(cities$lat) & cities$country == "Pennsylvania"] <- "Harrisburg"
cities$city[is.na(cities$lat) & cities$country == "Montana"] <- "Helena"
cities$city[is.na(cities$lat) & cities$country == "Iowa"] <- "Des Moines"
cities$city[is.na(cities$lat) & cities$country == "Maine"] <- "Augusta"
cities$city[is.na(cities$lat) & cities$country == "West Virginia"] <- "Charleston"
cities$city[is.na(cities$lat) & cities$country == "California"] <- "Sacramento"
cities$city[is.na(cities$lat) & cities$country == "Ohio"] <- "Columbus"

# Final join to dataset of city coordinates (from package maps)
cities <- left_join(cities[c("place","city","country")], coords[c("name","country.etc","lat","long")], by = c("city" = "name","country" = "country.etc"))
print(paste0(100 * nrow(cities[is.na(cities$lat) & !is.na(cities$place) & cities$place != "",]) / nrow(cities),"% of cities have no lat/long match"))
print(paste0(100 * nrow(cities[is.na(cities$place) | cities$place =="",]) / nrow(cities),"% of artists have no birthplace in dataset"))

# Now we will loop through each of the timeframes
print(paste0("First acquisition : ",min(artwork$year_first_acquired)))
print(paste0("Latest acquisition : ",max(artwork$year_first_acquired)))

system.time({
for(max in seq(1830, 2020, 10)) {
  print(paste0("Producing image for 1823 - ", max))
  # Create a path dataframe ----
  # Calculate the shape between the place of birth and the geographic location of the Tate museum
  path <- left_join(artist, artwork, by = c("id" = "artistId"))
  path <- path[c("name","placeOfBirth","year_first_acquired")]
  colnames(path) <- c("artist","from", "year_first_acquired")
  
  # Keep only acquisitions during the timeframe
  path <- path[path$year_first_acquired <= max,]
  
  # Aggregate to 
  path <- ddply(path, c("from"), function(x) count(x$from))
  
  # Drop observations where location is missing
  path <- path[!is.na(path$from),]
  
  # Add lat and long from the cities df we made earlier
  from.ll <- merge(path, cities, all.x = T, by.x = "from", by.y = "place")
  
  # Drop where we didn't have a match to lat/long
  from.ll <- from.ll[!is.na(from.ll$lat),]
  
  # calculate routes -- Dateline Break FALSE, otherwise we get a bump in the shifted ggplots
  location.ll <- c(-2.7814688, 51.8078055)
  
  rts <- gcIntermediate(location.ll, from.ll[,c('long', 'lat')], 100, breakAtDateLine=FALSE, addStartEnd=TRUE, sp=TRUE)
  rts <- as(rts, "SpatialLinesDataFrame")
  rts.ff <- fortify(rts)
  
  # Create text label
  tag.map.title <- tags$style(HTML("
  .leaflet-control.map-title { 
    transform: translate(-50%,20%);
    position: fixed !important;
    left: 50%;
    text-align: center;
    padding-left: 10px; 
    padding-right: 10px; 
    background: rgba(255,255,255,0.75);
    font-weight: bold;
    font-size: 28px;
  }
"))
  
  title <- tags$div(
    tag.map.title, HTML(max)
  )  
  
  # Create visuals ----
  rts %>%
    leaflet(width = 1150,
            height = 750,
            ## the options below define the initial coordinates (center)
            ##, the initial zoom (x2) and the bounds of the map
            options = leafletOptions(center = c(30, 30),
                                     zoom = 2,
                                     maxBounds = list(c(-90, -120),
                                                      c(90,120)))
    )  %>% 
   addProviderTiles(providers$NASAGIBS.ViirsEarthAtNight2012) %>%
    addPolylines(color = "white", opacity = 0.3, weight =  0.9) %>%
    addControl(title, position = "topleft", className="map-title") %>%
    addCircles(lat = from.ll$lat, lng = from.ll$long, radius = 1, opacity = 0.5, color = "yellow", stroke = "white") %>%
    mapshot(file = paste0("./tate_test",max,".png"))
}
})

# Combine PNG into GIF ----
png_files <- list.files("./", pattern = ".*png$", full.names = TRUE)
gifski(png_files, gif_file = "animation.gif", width = 1150, height = 750, delay = 0.3)
