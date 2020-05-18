#-----------------------------------------------------------------------------------------#
# Cleans three datasets: Greenland ice mass, Antarctica ice mass, and sea ice extent
#-----------------------------------------------------------------------------------------#

options(stringsAsFactors = FALSE)

# Load packages ---- 
list.of.packages <- c("tidyverse","lubridate","readxl","reshape2")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# Greenland mass ----
# Source: https://podaac-tools.jpl.nasa.gov/drive/files/allData/tellus/L4/ice_mass/RL06/v02/mascon_CRI/greenland_mass_200204_202002.txt
# Citation: Wiese, D. N., D.-N. Yuan, C. Boening, F. W. Landerer, and M. M. Watkins (2019) JPL GRACE and GRACE-FO Mascon Ocean, Ice, and Hydrology Equivalent Water Height RL06M CRI Filtered Version 2.0, Ver. 2.0, PO.DAAC, CA, USA. Dataset accessed 2020-05-01 at http://dx.doi.org/10.5067/TEMSC-3MJ62.
# See also: https://climate.nasa.gov/vital-signs/ice-sheets/
df.greenland <- read.table("data/Greenland Mass.txt")
colnames(df.greenland) <- c("date","Greenland mass (gigatonnes)","Greenland mass 1-sigma uncertainty (Gigatonnes)")

# Convert decimal date to date
df.greenland$date <- format(date_decimal(df.greenland$date), "%d-%m-%Y")

# Store August 2016 value for later, since the data were missing for Sep
greenland.fill <- df.greenland$`Greenland mass (gigatonnes)`[grepl("-08-2016",df.greenland$date)]

# Keep only September
df.greenland <- df.greenland[grepl("-09-",df.greenland$date),]
df.greenland$Year <- substr(df.greenland$date,7,10)

# Antarctica mass ----
# Source: https://podaac-tools.jpl.nasa.gov/drive/files/allData/tellus/L4/ice_mass/RL06/v02/mascon_CRI/antarctica_mass_200204_202002.txt
# Citation: Wiese, D. N., D.-N. Yuan, C. Boening, F. W. Landerer, and M. M. Watkins (2019) JPL GRACE and GRACE-FO Mascon Ocean, Ice, and Hydrology Equivalent Water Height RL06M CRI Filtered Version 2.0, Ver. 2.0, PO.DAAC, CA, USA. Dataset accessed 2020-05-01 at http://dx.doi.org/10.5067/TEMSC-3MJ62.
# See also: https://climate.nasa.gov/vital-signs/ice-sheets/
df.antarctica <- read.table("data/Antarctica Mass.txt")
colnames(df.antarctica) <- c("date","Antarctic mass (Gigatonnes)","Antarctic mass 1-sigma uncertainty (Gigatonnes)")

# Convert decimal date to date
df.antarctica$date <- format(date_decimal(df.antarctica$date), "%d-%m-%Y")

# Store May 2002 value for later, since the data don't go back that long
antarctica.fill <- df.antarctica$`Antarctic mass (Gigatonnes)`[grepl("-05-2002",df.antarctica$date)]

# Keep only March (except keep)
df.antarctica <- df.antarctica[grepl("-03-",df.antarctica$date),]
df.antarctica$Year <- substr(df.antarctica$date,7,10)

# Join the two
df.mass <- full_join(df.greenland, df.antarctica, by = "Year")
df.mass <- df.mass[c("Year","Greenland mass (gigatonnes)","Antarctic mass (Gigatonnes)")]
colnames(df.mass) <- c("Year","Greenland","Antarctic")

# Fill in the missing values
df.mass$Antarctic[is.na(df.mass$Antarctic)] <- antarctica.fill
df.mass$Greenland[is.na(df.mass$Greenland)] <- greenland.fill

write.csv(df.mass,"data/Ice Mass.csv", row.names = F)
