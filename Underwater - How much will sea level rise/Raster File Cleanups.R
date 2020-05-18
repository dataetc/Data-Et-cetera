#-----------------------------------------------------------------------------------------#
# Visualizes elevation data for major cities/geographies of interest
#-----------------------------------------------------------------------------------------#

options(stringsAsFactors = FALSE)

# Load packages ---- 
list.of.packages <- c("raster","rgdal","tidyverse","mapview","tmap")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# Set elevation threshold & parameters
cutoff <- 1
alpha <- 0.5

# Download all files
# Data source: http://viewfinderpanoramas.org/dem3.html#images

# Function that takes a city name, the download file name, and the relevant squares
extractRaster <- function(city, raster, url, squares){
  dir <- paste0(getwd(),"/data/raster/",city)
  dir.create(file.path(dir), showWarnings = FALSE)
  download.file(paste0("http://viewfinderpanoramas.org/dem3/", url, ".zip"), destfile = paste0(dir,"/zip.zip"))
  unzip(paste0(dir,"/zip.zip"), exdir = dir)
  file.remove(paste0(dir,"/zip.zip"))

  file.path <- paste0(dir,"/",raster,"/")
  file.names <- list.files(file.path) %>% print()
  
  list_squares <- list()
  for(i in 1:length(squares)) {
    list_squares[[i]] <- raster(paste0(dir,"/",raster,"/", squares[i],".hgt"), values = T)
  }
  
  if(length(list_squares) > 1) {
    df <- do.call(merge, list_squares)
  } else {
    df <- list_squares[[1]]
  }
  city_map <- df
  assign(city, df)
 
  df[df > cutoff] <- NA

    city_map_low <- df
  assign(paste0(city,".low"), df)
  return(list(city_map, city_map_low))
  rm(df, list_squares)
  
}
# Shanghai, China
this.city <- "shanghai"
this.rastar <- "H51"
this.url <- "H51"
these.squares <- c("N30E121","N31E121")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(shanghai.low, alpha.regions = alpha)

writeRaster(shanghai, filename = "data/raster/FINAL/shanghai_elevations.tif", format= "GTiff", overwrite = T)

# Hanoi, Viet Nam
this.city <- "hanoi"
this.rastar <- "F48"
this.url <- "F48"
these.squares <- c("N20E105","N21E105","N20E106","N21E106")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(hanoi.low, alpha.regions = alpha)

writeRaster(hanoi, filename = "data/raster/FINAL/hanoi_elevations.tif", format= "GTiff", overwrite = T)

# Mumbai, India
this.city <- "mumbai"
this.rastar <- "E43"
this.url <- "E43"
these.squares <- c("N19E072","N18E072")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(mumbai.low, alpha.regions = alpha)

writeRaster(mumbai, filename = "data/raster/FINAL/mumbai_elevations.tif", format= "GTiff", overwrite = T)

# Khulna, Bangladesh
this.city <- "khulna"
this.rastar <- "F45"
this.url <- "F45"
these.squares <- c("N22E089")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(khulna.low, alpha.regions = alpha)

writeRaster(khulna, filename = "data/raster/FINAL/khulna_elevations.tif", format= "GTiff", overwrite = T)

# Osaka, Japan
this.city <- "osaka"
this.rastar <- "I53"
this.url <- "I53"
these.squares <- c("N34E135")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(osaka.low, alpha.regions = alpha)

writeRaster(osaka, filename = "data/raster/FINAL/osaka_elevations.tif", format= "GTiff", overwrite = T)

# New York, United States
this.city <- "nyc"
this.url <- "K18"
this.rastar <- "K18"
these.squares <- c("N40W074","N40W075")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(nyc.low, alpha.regions = alpha)

writeRaster(nyc, filename = "data/raster/FINAL/nyc_elevations.tif", format= "GTiff", overwrite = T)

# Jakarta, Indonesia
this.city <- "jakarta"
this.url <- "SB48"
this.rastar <- "B48"
these.squares <- c("S07E106","S06E106","S07E107","S06E107")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(jakarta.low, alpha.regions = alpha)

writeRaster(jakarta, filename = "data/raster/FINAL/jakarta_elevations.tif", format= "GTiff", overwrite = T)

# Rio de Janeiro, Brazil
this.city <- "rio"
this.url <- "SF23"
this.rastar <- "F23"
these.squares <- c("S23W043","S24W043","S23W044","S24W044")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(rio.low, alpha.regions = alpha)

writeRaster(rio, filename = "data/raster/FINAL/rio_elevations.tif", format= "GTiff", overwrite = T)

# Venice, Italy
this.city <- "venice"
this.url <- "L33"
this.rastar <- "L33"
these.squares <- c("N45E012")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(venice.low, alpha.regions = alpha)

writeRaster(venice, filename = "data/raster/FINAL/venice_elevations.tif", format= "GTiff", overwrite = T)

# Amsterdam, Netherlands
this.city <- "amsta"
this.rastar <- "N31"
this.url <- "N31"
these.squares <- c("N52E004","N52E005")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(amsta.low, alpha.regions = alpha)

writeRaster(amsta, filename = "data/raster/FINAL/amsta_elevations.tif", format= "GTiff", overwrite = T)

# Miami, United States
this.city <- "miami"
this.rastar <- "G17"
this.url <- "G17"
these.squares <- c("N25W081", "N25W082", "N24W081", "N24W082","N26W081","N26W082")

city_maps <- extractRaster(this.city, this.rastar, this.url, these.squares)
assign(this.city, city_maps[[1]])
assign(paste(this.city, "low", sep = "."), city_maps[[2]])
rm(city_maps)

mapview(miami.low, alpha.regions = alpha)

writeRaster(miami, filename = "data/raster/FINAL/miami_elevations.tif", format= "GTiff", overwrite = T)
