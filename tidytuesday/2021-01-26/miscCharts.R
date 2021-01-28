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

# Polar bar chart -----
plastics %>%
  filter(parent_company == "Grand Total") %>%
  filter(year == 2019) %>%
  ggplot(aes(x = as.factor(country), y = grand_total, )) +
  geom_bar(stat = "identity") +
  theme_minimal() + 
  coord_polar(start = 0)
  

df_byCompany <- plastics %>%
  filter(year == 2019) %>%
  group_by(parent_company) %>%
  summarise(total = sum(grand_total)) %>%
  arrange(desc(total)) %>%
  filter(!parent_company %in% c("Grand Total", "Unbranded", "Assorted")) %>%
  slice(1:5) %>%
  arrange(total)  %>%
mutate(parent_company = factor(parent_company, levels = parent_company))

label_data <- df_byCompany %>%
  mutate(id = row_number())
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
label_data$hjust <- ifelse( angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)

df_byCompany %>%
  ggplot(aes(x = parent_company, y = total, fill = total)) +
  geom_bar(stat = "identity") +
  theme_minimal() + 
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-1,4), "cm") 
  ) +
  coord_polar(start = 0) +
  geom_text(data=label_data, 
            aes(x=id, y=total+10, label=parent_company, hjust=hjust), 
            color="black", fontface="bold",alpha=0.6, size=2.5, 
            angle= label_data$angle, inherit.aes = FALSE ) 

heatmap(plastics$country,)
plastics

# Global Reach of top producers

top_companies <- df_byCompany$parent_company
plastics %>%
  filter(parent_company %in% top_companies) %>%
  ggplot(aes(x = country, y = grand_total, color = country)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  facet_wrap(~parent_company)

df_heatMap <- plastics %>%
  filter(year == 2019) %>%
  filter(parent_company %in% top_companies) %>%
  select(country, parent_company, grand_total) %>%
  spread(parent_company, grand_total) 

matrix_heatMap <- df_heatMap %>% select(-country) %>% as.matrix()
matrix_heatMap[is.na(matrix_heatMap)] <- 0
heatmap(matrix_heatMap)  
Aaqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq