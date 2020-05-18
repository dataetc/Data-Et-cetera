options(stringsAsFactors = FALSE)

# Load packages ---- 
list.of.packages <- c("tidyverse")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# Data soruce: https://cmr.earthdata.nasa.gov/search/concepts/C1000000400-SEDAC.html
df <- read.csv("data/lecz-urban-rural-population-land-area-estimates_country-90m.csv", stringsAsFactors = F)

unique(df$ElevationZone)
names(df)

# Create df of Elevations Less than or Equal to 1m
df_less10 <- df %>%
  filter(ElevationZone == "Elevations Less Than or Equal To 10m ") %>%
  group_by(ISO3v10, Country) %>%
  summarise(Population2100_less1 = sum(Population2100),
            LandArea_less1 = sum(LandArea))

# Total
df_total <- df %>%
  filter(ElevationZone == "Total National Population") %>%
  group_by(ISO3v10, Country) %>%
  summarise(Population2100 = sum(Population2100),
            LandArea = sum(LandArea))

# Final df
df_final <- full_join(df_total, df_less10, by = c("ISO3v10","Country"))

df_final$PopulationPct <- df_final$Population2100_less1 / df_final$Population2100
df_final$LandPct <- df_final$LandArea_less1 / df_final$LandArea

# To ensure a complete dataset, merge to full list of ISO
df_iso <- read.csv("data/iso.csv", stringsAsFactors = F)
df_iso$iso <- substr(df_iso$iso, 1, 3)
df_iso$country <- substr(df_iso$country,2,length(df_iso$country))

df_final <- full_join(df_iso, df_final, by = c("iso" = "ISO3v10"))

for(var in c("Population2100_less1","PopulationPct","LandPct")) {
  df_final[[var]][is.na(df_final[[var]])] <- 0
}

df_final <- df_final[c("iso","country","Population2100_less1","PopulationPct","LandPct")]
colnames(df_final) <- c("ISO3v10","Country","Population2100","PercentofCountryPopulation2100","LandPct")

write.csv(df_final, "data/population_output.csv", row.names = F)
