# tidytuesday : 2021-01-26

# Set up environment ---------------------------------------

list.of.packages <- c("tidytuesdayR","tidyverse")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)


# Info on data ---------------------------------------

# README : https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-01-26/readme.md

# The data this week comes from Break Free from Plastic courtesy of Sarah Sauve.
# 
# Sarah put together a nice Blogpost on her approach to this data, which includes 
# cleaning the data and a Shiny app!
#   
#   Per Sarah:
#   
#   I found out about Break Free From Plastic's Brand Audits through my involvement 
# with the local Social Justice Cooperative of Newfoundland and Labrador's Zero Waste 
# Action Team.
# 
# One of my colleagues and friends proposed an audit in St. John's, partially to 
# contribute to the global audit and as part of a bigger project to understand the 
# sources of plastic in our city. We completed our audit in October 2020 and are the 
# first submission to BFFP from Newfoundland! You can find our data presented in this
# Shiny dashboard.
# 
# It's an interesting dataset, with lots of room to play around and so many options 
# for visualization, plus plastic pollution is an important topic to talk about and 
# raise awareness of! You can read BFFP's Brand Audit Reports for 2018, 2019 and 
# 2020 to get an idea of what they've done with the data.

# Read in data ---------------------------------------

tuesdata <- tidytuesdayR::tt_load('2021-01-26')

plastics <- tuesdata$plastic
