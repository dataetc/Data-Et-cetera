# tidytuesday : 2021-01-05

# Set up environment
list.of.packages <- c("tidytuesdayR","tidyverse","scales", "ggpubr")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# Info on data
# The data this week comes from Transit Costs Project : https://transitcosts.com/

#   Why do transit-infrastructure projects in New York cost 20 times more on a per kilometer basis than in
#   Seoul? We investigate this question across hundreds of transit projects from around the world. We have 
#   created a database that spans more than 50 countries and totals more than 11,000 km of urban rail built 
#   since the late 1990s. We will also examine this question in greater detail by carrying out six in-depth 
#   case studies that take a closer look at unique considerations and variables that aren't easily quantified,
#   like project management, governance, and site conditions.

#   The goal of this work is to figure out how to deliver more high-capacity transit projects for a fraction 
#   of the cost in countries like the United States. Additionally, we hope that our site will be a useful 
#   resource for elected officials, planners, researchers, journalists, advocates, and others interested in 
#   contextualizing transit-infrastructure costs and fighting for better projects.

#   The first completed Case Study can be found on Boston's Green Line, although there is data from around the world!
#   https://transitcosts.com/city/boston-case-the-story-of-the-green-line-extension/

# Read in data
tuesdata <- tidytuesdayR::tt_load('2021-01-05')
tuesdata <- tidytuesdayR::tt_load(2021, week = 2)

transit_cost <- tuesdata$transit_cost %>%
  # Reformat / create variables where needed
  mutate(tunnel_ratio = as.numeric(gsub("%", "", tunnel_per))/100,
         completed = case_when(end_year <= 2020 ~ "Completed",
                               end_year > 2020 ~ "Planned",
                               start_year > 2020 ~ "Planned",
                               is.na(start_year) ~ "Planned",
                               is.na(end_year) & !is.na(start_year) ~ "Unknown",
                               grepl("not start",start_year) ~ "Planned",
                               TRUE ~ "Unknown"),
         city_year = case_when(is.na(end_year) ~ paste0(line, " (", city,") - (unknown)"),
                               !is.na(end_year) ~ paste0(line, " (", city, ") - (", end_year, ")")))

# Convert some character vars to string
for(var in "real_cost") {
  transit_cost[[var]] <- gsub("N","",gsub("QUARTILE 3","",gsub("QUARTILE 1","",gsub("MIN","",gsub("STD","",gsub("MEDIAN","",gsub("AVG","",transit_cost[[var]])))))))
  transit_cost[[var]] <- as.numeric(transit_cost[[var]])
}

# Create a regional variable 
# Regions are from World Bank: 
# https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups
# ISO 2 codes from https://www.iban.com/country-codes
transit_cost <- transit_cost %>%
  mutate(region = case_when(country == "AE" ~ "Middle East and North Africa",
                            country == "AR" ~ "Latin America and the Caribbean",
                            country == "AT" ~ "Europe and Central Asia",
                            country == "AU" ~ "East Asia and Pacific",
                            country == "BD" ~ "South Asia",
                            country == "BE" ~ "Europe and Central Asia",
                            country == "BG" ~ "Europe and Central Asia",
                            country == "BH" ~ "Middle East and North Africa",
                            country == "BR" ~ "Latin America and the Caribbean",
                            country == "CA" ~ "North America",
                            country == "CH" ~ "Europe and Central Asia",
                            country == "CL" ~ "Latin America and the Caribbean",
                            country == "CN" ~ "East Asia and Pacific",
                            country == "CZ" ~ "Europe and Central Asia",
                            country == "DE" ~ "Europe and Central Asia",
                            country == "DK" ~ "Europe and Central Asia",
                            country == "EC" ~ "Latin America and the Caribbean",
                            country == "EG" ~ "Middle East and North Africa",
                            country == "ES" ~ "Europe and Central Asia",
                            country == "FI" ~ "Europe and Central Asia",
                            country == "FR" ~ "Europe and Central Asia",
                            country == "GR" ~ "Europe and Central Asia",
                            country == "HU" ~ "Europe and Central Asia",
                            country == "ID" ~ "East Asia and Pacific",
                            country == "IL" ~ "Middle East and North Africa",
                            country == "IN" ~ "South Asia",
                            country == "IR" ~ "Middle East and North Africa",
                            country == "IT" ~ "Europe and Central Asia",
                            country == "JP" ~ "East Asia and Pacific",
                            country == "KR" ~ "East Asia and Pacific",
                            country == "KW" ~ "Middle East and North Africa",
                            country == "MX" ~ "Latin America and the Caribbean",
                            country == "MY" ~ "East Asia and Pacific",
                            country == "NL" ~ "Europe and Central Asia",
                            country == "NO" ~ "Europe and Central Asia",
                            country == "NZ" ~ "East Asia and Pacific",
                            country == "PA" ~ "Latin America and the Caribbean",
                            country == "PE" ~ "Latin America and the Caribbean",
                            country == "PH" ~ "East Asia and Pacific",
                            country == "PK" ~ "South Asia",
                            country == "PL" ~ "Europe and Central Asia",
                            country == "PT" ~ "Europe and Central Asia",
                            country == "QA" ~ "Middle East and North Africa",
                            country == "RO" ~ "Europe and Central Asia",
                            country == "RU" ~ "Europe and Central Asia",
                            country == "SA" ~ "Middle East and North Africa",
                            country == "SE" ~ "Europe and Central Asia",
                            country == "SG" ~ "East Asia and Pacific",
                            country == "TH" ~ "East Asia and Pacific",
                            country == "TR" ~ "Europe and Central Asia",
                            country == "TW" ~ "East Asia and Pacific",
                            country == "UA" ~ "Europe and Central Asia",
                            country == "UK" ~ "Europe and Central Asia",
                            country == "US" ~ "North America",
                            country == "UZ" ~ "Europe and Central Asia",
                            country == "VN" ~ "East Asia and Pacific" 
  ))

# What are the most expensive projects in the dataset? ----
makeTransitBarChart_byRegion <- function(regionName){
  transit_cost %>%
    arrange(desc(real_cost)) %>%
    mutate(completed = factor(completed, levels = c("Completed", "Planned", "Unknown"))) %>%
    filter(region %in% regionName) %>%
    slice(1:10) %>%
    ggplot(aes(x = real_cost, y = reorder(city_year, real_cost), fill = completed, color = completed)) +
    geom_bar(stat = "identity", linetype = "longdash", width = 0.7) + 
    scale_fill_manual("", values = c("skyblue","white","grey"), drop = FALSE) + 
    scale_color_manual("", values = c(alpha("red", 0.0),"black",alpha("grey", 0)), drop = FALSE) + 
    geom_text(aes(label = scales::comma(round(real_cost), accuracy=1)), hjust = -0.2, vjust = 0.4, color = "black", size = 3.2) +
    labs(title = regionName,
         subtitle = "",
         caption = "" , 
         x = "Cost of project, millions (USD eq.)", 
         y = "", 
         fill = "Status of project") + 
    expand_limits(x = 105000) +
    scale_x_continuous(labels = comma) +#, limits = c(0, max(transit_cost$real_cost, na.rm = TRUE))) + 
    theme(axis.text.y = element_text(vjust = 0), 
          axis.ticks.y = element_blank(),
          axis.line = element_line(colour = "black"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_rect(fill = "grey93"),
          legend.position = "right",
          text=element_text(size= 12, family = "ArialMT")) %>%
    return()
}

region_names <- transit_cost$region %>% unique()
ggarrange(
  makeTransitBarChart_byRegion(region_names[1]),
  makeTransitBarChart_byRegion(region_names[2]),
  makeTransitBarChart_byRegion(region_names[3]),
  makeTransitBarChart_byRegion(region_names[4]),
  makeTransitBarChart_byRegion(region_names[5]),
  makeTransitBarChart_byRegion(region_names[6]),
  nrow = 3,
  ncol = 2,
  common.legend = TRUE,
  legend = "top"
) %>%
  annotate_figure(
      top = text_grob("Most expensive transit-infrastructure projects, by region (1982 - present)", face = "bold", size = "14"), 
      bottom = "Data available at https://transitcosts.com/"
  ) 