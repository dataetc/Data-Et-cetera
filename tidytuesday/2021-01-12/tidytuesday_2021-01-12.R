# tidytuesday : 2021-01-12

# Set up environment ----
list.of.packages <- c("tidytuesdayR","tidyverse")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

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

