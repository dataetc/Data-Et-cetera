# tidytuesday : 2021-04-13

# Set up environment ---------------------------------------

list.of.packages <- c("tidytuesdayR","tidyverse")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)


# Info on data ---------------------------------------

# README: https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-07-06/readme.md
# 
# The data this week comes from Wikipedia and thank you to Isabella Velasquez for prepping this week's dataset.
# 
#     An independence day is an annual event commemorating the anniversary of a nation's independence or statehood, usually 
#     after ceasing to be a group or part of another nation or state, or more rarely after the end of a military occupation.
#     Many countries commemorate their independence from a colonial empire. American political commentator Walter Russell 
#     Mead notes that, "World-wide, British Leaving Day is never out of season.

# Read in data ---------------------------------------
tuesdata <- tidytuesdayR::tt_load('2021-07-06')
df_holidays <- tuesdata$holidays

str(df_holidays)
head(df_holidays)


# Exploratory data analysis ----
df_holidays %>%
  group_by(independence_from) %>%
  summarise("countries" = n()) %>%
  arrange(desc(countries))


# For countries gaining independence from multiple countries, we will assign them to each country  ----
# (i.e. duplicate records)
# Temporary df of observations with multiple countries:
to_clean <- df_holidays %>%
   filter(grepl(" and ",independence_from) & independence_from != "United Kingdom of Portugal, Brazil and the Algarves") %>%
   mutate(independence_from = strsplit(as.character(independence_from), " and ")) %>%
   unnest(cols = c(independence_from)) %>%
   filter(independence_from != "") %>%
   mutate(independence_from = strsplit(as.character(independence_from), ", ")) %>%
   unnest(cols = c(independence_from)) %>%
   filter(independence_from != "")
   
# Create duplicate rows for each of the countries in the list, then join back to original df
df_holidays <- rbind(df_holidays %>%
                       filter(!grepl(" and ", independence_from) | independence_from == "United Kingdom of Portugal, Brazil and the Algarves"),
                     to_clean)

# Clean country names
unique(df_holidays$independence_from)

df_holidays <- df_holidays %>%
  mutate(
    independence_from = case_when(independence_from == "Spanish Empire" ~ "Spain",
                                  independence_from == "Spanish Empire[72]" ~ "Spain",
                                  independence_from == "Soviet Union" ~ "Russia",
                                  independence_from == "Soviet Union[55]" ~ "Russia",
                                  independence_from == "Soviet Union[80]" ~ "Russia",
                                  independence_from == "Empire of Japan" ~ "Japan",
                                  independence_from == "Russian Soviet Federative Socialist Republic" ~ "Russia",
                                  independence_from == "Kingdom of Great Britain" ~ "United Kingdom",
                                  independence_from == "Qing China[65][66]" ~ "China",
                                  independence_from == "United Netherlands" ~ "Netherlands",
                                  independence_from == "Nazi Germany" ~ "Germany",
                                  independence_from == "Australia of the former Territory of Papua and New Guinea" ~ "Australia",
                                  independence_from == "United Kingdom of Great Britain and Ireland" ~ "United Kingdom",
                                  independence_from == "American Colonization Society" ~ "United States",
                                  independence_from == "Australia of the former Territory of Papua" ~ "Australia",
                                  independence_from == "United Kingdom of Great Britain" ~ "United Kingdom",
                                  independence_from == "German Empire" ~ "Germany",
                                  independence_from == "the United Kingdom" ~ "United Kingdom",
                                  independence_from == "SFR Yugoslavia" ~ "Yugoslavia",
                                  independence_from == "Socialist Federal Republic of Yugoslavia" ~ "Yugoslavia",
                                  independence_from == "Soviet Union)" ~ "Soviet Union",
                                  independence_from == "Allied occupying powers (France" ~ "France",
                                  independence_from == "United Provinces of the Rio de la Plata" ~ "Argentina",
                                  independence_from == "United Kingdom of Portugal, Brazil and the Algarves" ~ "Portugal",
                                  independence_from == "the British Mandate for Palestine" ~ "United Kingdom",
                                  TRUE ~ independence_from)
  )

df_holidays %>%
  group_by(independence_from) %>%
  summarise("countries" = n()) %>%
  arrange(desc(countries))


# Visuals ----










