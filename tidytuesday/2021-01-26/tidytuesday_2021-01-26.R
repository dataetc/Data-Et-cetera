# tidytuesday : 2021-01-26

# Set up environment ---------------------------------------

list.of.packages <- c("tidytuesdayR","tidyverse","networkD3","htmlwidgets")

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


# Clean data a bit -------------------------------------

table(plastics$country)

plastics$country[plastics$country == "Cote D_ivoire"] <- "Cote d'Ivoire"
plastics$country[plastics$country == "EMPTY"] <- ""
plastics$country[plastics$country == "ECUADOR"] <- "Ecuador"
plastics$country[plastics$country == "NIGERIA"] <- "Nigeria"
plastics$country[plastics$country == "United Kingdom of Great Britain & Northern Ireland"] <- "United Kingdom"
plastics$country[plastics$country == "Taiwan_ Republic of China (ROC)"] <- "Taiwan"

table(plastics$country)

plastics <- plastics %>%
  filter(country == "United States of America")

# Create a table of nodes ----------------------------------------------

# Create the df of names (source and target) for labeling
nodes <- data.frame()

countries <- unique(as.data.frame(plastics$country))
colnames(countries) <- "name"

companies <- unique(as.data.frame(plastics$parent_company))
colnames(companies) <- "name"

nodes <- as.data.frame(rbind(nodes, countries, companies))
head(nodes)

# Create zero-indexed ID, pass it to row names
nodes$id <- seq.int(nrow(nodes)) -1
rownames(nodes) <- nodes$id

# Create a table of links ---------------------------------------------------

# Create a 'to' and 'from' linker dataframe (in this case between company and country)

links <- plastics[c("country","parent_company","grand_total")]

links <- left_join(links, nodes, by = c("country" = "name"))
colnames(links) <- c("country","parent_company","value", "target")

links <- left_join(links, nodes, by = c("parent_company" = "name"))
colnames(links) <- c("country","parent_company","value", "target","source")

links <- as.data.frame(links[c("source","target","value")])

# Convert to numeric
links$target <- as.numeric(links$target)
links$source <- as.numeric(links$source)

# Drop missing values
links <- links[!is.na(links$value),]

# Combine the two into one list
links <- links[c(1,100,200,300,400,500,600),]   # FIRST JUST USING A FEW OBS
list_sankey <- list("links" = links, "nodes" = nodes[c("name")])


# Create Sankey -----------------------------------------------------------

p <- sankeyNetwork(Links = list_sankey$links, Nodes = list_sankey$nodes, Source = "target",
                   Target = "source", Value = "value", NodeID = "name",
                   fontSize = 12, nodeWidth = 30)

p

# Save widget ------------------------------------------------------------

saveWidget(p, file=paste0( getwd(), "plastics.html"))


# TEST EXAMPLE FROM INTERNET
# https://www.r-graph-gallery.com/323-sankey-diagram-with-the-networkd3-library.html

# # Load energy projection data
#  URL <- "https://cdn.rawgit.com/christophergandrud/networkD3/master/JSONdata/energy.json"
#  Energy <- jsonlite::fromJSON(URL)
# # 
# # 
# # # Now we have 2 data frames: a 'links' data frame with 3 columns (from, to, value), and a 'nodes' data frame that gives the name of each node.
#  head( Energy$links )
#  head( Energy$nodes )
# # 
# # # Thus we can plot it
#  p <- sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",
#                     Target = "target", Value = "value", NodeID = "name",
#                     units = "TWh", fontSize = 12, nodeWidth = 30)
#  p

# save the widget
# library(htmlwidgets)
 #saveWidget(p, file=paste0( getwd(), "sankeyEnergy.html"))
