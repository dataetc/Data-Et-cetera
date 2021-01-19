# tidytuesday : 2021-01-19

# Set up environment ----
list.of.packages <- c("tidytuesdayR","tidyverse","remotes")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

remotes::install_github("Shelmith-Kariuki/rKenyaCensus")

# Info on data ----

# README : https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-01-19/readme.md

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

gender <- tuesdata$gender
crops <- tuesdata$crops
households <- tuesdata$households