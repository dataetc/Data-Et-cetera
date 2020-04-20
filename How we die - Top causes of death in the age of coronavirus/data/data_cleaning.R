options(stringsAsFactors = FALSE)

# Load packages ---- 
list.of.packages <- c("tidyverse","utils","anytime")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# Cleaning CDC Wonder data
# link: https://wonder.cdc.gov/
# Query criteria:
    # Year/Month:	2018
    # Group By:	ICD-10 113 Cause List
    # Show Totals:	Disabled
    # Show Zero Values:	False
    # Show Suppressed:	False
    # Calculate Rates Per:	100,000
    # Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)

# Read in the CDC Wonder data ----
df_deaths <- read.table("./data/Underlying Cause of Death, 1999-2018, monthly.txt", 
                        header = TRUE, 
                        sep = "\t",
                        nrows = 1561,
                        comment.char = "") %>%
                        select(-Notes)

names(df_deaths) <- c("Month","Month_code", "Cause", "Cause113Code", "Deaths", "Population", "Crude rate per 100,000")

# Convert the numeric values (currently as strings) to numeric
df_deaths <- df_deaths %>%
  mutate(`Crude rate per 100,000` = as.numeric(`Crude rate per 100,000`))

# Categorize causes as major or minor groups ----
df_deaths$level <- 1   # default all to major categories
df_deaths$parent_category <- ""  

# Associate sub-categories with their parent cause
for(cause in c("Respiratory tuberculosis (A16)", 
               "Other tuberculosis (A17-A19)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Tuberculosis (A16-A19)"
}

for(cause in c("Malignant neoplasms of lip, oral cavity and pharynx (C00-C14)",
               "Malignant neoplasm of esophagus (C15)",
               "Malignant neoplasm of stomach (C16)",
               "Malignant neoplasms of colon, rectum and anus (C18-C21)",
               "Malignant neoplasms of liver and intrahepatic bile ducts (C22)",
               "Malignant neoplasm of pancreas (C25)",
               "Malignant neoplasm of larynx (C32)",
               "Malignant neoplasms of trachea, bronchus and lung (C33-C34)",
               "Malignant melanoma of skin (C43)",
               "Malignant neoplasm of breast (C50)",
               "Malignant neoplasm of cervix uteri (C53)",
               "Malignant neoplasms of corpus uteri and uterus, part unspecified (C54-C55)",
               "Malignant neoplasm of ovary (C56)",
               "Malignant neoplasm of prostate (C61)",
               "Malignant neoplasms of kidney and renal pelvis (C64-C65)",
               "Malignant neoplasm of bladder (C67)",
               "Malignant neoplasms of meninges, brain and other parts of central nervous system (C70-C72)",
               "Malignant neoplasms of lymphoid, hematopoietic and related tissue (C81-C96)",
               "All other and unspecified malignant neoplasms (C17,C23-C24,C26-C31,C37-C41,C44-C49,C51-C52,C57-C60,C62-C63,C66,C68-C69,C73-C80,C97)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Malignant neoplasms (C00-C97)"
}

for(cause in c("Hodgkin disease (C81)", 
               "Non-Hodgkin lymphoma (C82-C85)",
               "Leukemia (C91-C95)",
               "Multiple myeloma and immunoproliferative neoplasms (C88,C90)",
               "Other and unspecified malignant neoplasms of lymphoid, hematopoietic and related tissue (C96)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 3
  df_deaths$parent_category[df_deaths$Cause == cause] <- "Malignant neoplasms of lymphoid, hematopoietic and related tissue (C81-C96)"
}

for(cause in c("Malnutrition (E40-E46)", 
               "Other nutritional deficiencies (E50-E64)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Nutritional deficiencies (E40-E64)"
}

for(cause in c("#Diseases of heart (I00-I09,I11,I13,I20-I51)", 
               "#Essential hypertension and hypertensive renal disease (I10,I12,I15)",
               "#Cerebrovascular diseases (I60-I69)",
               "#Atherosclerosis (I70)",
               "Other diseases of circulatory system (I71-I78)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "Major cardiovascular diseases (I00-I78)"
}

for(cause in c("Acute rheumatic fever and chronic rheumatic heart diseases (I00-I09)", 
               "Hypertensive heart disease (I11)",
               "Hypertensive heart and renal disease (I13)",
               "Ischemic heart diseases (I20-I25)",
               "Other heart diseases (I26-I51)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 3
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Diseases of heart (I00-I09,I11,I13,I20-I51)"
}

for(cause in c("Acute myocardial infarction (I21-I22)", 
               "Other acute ischemic heart diseases (I24)",
               "Other forms of chronic ischemic heart disease (I20,I25)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 4
  df_deaths$parent_category[df_deaths$Cause == cause] <- "Ischemic heart diseases (I20-I25)"
}

for(cause in c("Atherosclerotic cardiovascular disease, so described (I25.0)", 
               "All other forms of chronic ischemic heart disease (I20,I25.1-I25.9)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 5
  df_deaths$parent_category[df_deaths$Cause == cause] <- "Other forms of chronic ischemic heart disease (I20,I25)"
}

for(cause in c("Acute and subacute endocarditis (I33)", 
               "Diseases of pericardium and acute myocarditis (I30-I31,I40)",
               "Heart failure (I50)",
               "All other forms of heart disease (I26-I28,I34-I38,I42-I49,I51)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 4
  df_deaths$parent_category[df_deaths$Cause == cause] <- "Other heart diseases (I26-I51)"
}


for(cause in c("#Aortic aneurysm and dissection (I71)", 
               "Other diseases of arteries, arterioles and capillaries (I72-I78)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 3
  df_deaths$parent_category[df_deaths$Cause == cause] <- "Other diseases of circulatory system (I71-I78)"
}

for(cause in c("Influenza (J09-J11)", 
               "Pneumonia (J12-J18)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Influenza and pneumonia (J09-J18)"
}

for(cause in c("#Acute bronchitis and bronchiolitis (J20-J21)", 
               "Other and unspecified acute lower respiratory infections (J22,U04)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "Other acute lower respiratory infections (J20-J22,U04)"
}

for(cause in c("Bronchitis, chronic and unspecified (J40-J42)", 
               "Emphysema (J43)",
               "Asthma (J45-J46)",
               "Other chronic lower respiratory diseases (J44,J47)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Chronic lower respiratory diseases (J40-J47)"
}

for(cause in c("Alcoholic liver disease (K70)", 
               "Other chronic liver disease and cirrhosis (K73-K74)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Chronic liver disease and cirrhosis (K70,K73-K74)"
}

for(cause in c("Acute and rapidly progressive nephritic and nephrotic syndrome (N00-N01,N04)", 
               "Chronic glomerulonephritis, nephritis and nephropathy not specified as acute or chronic, and renal sclerosis unspecified (N02-N03,N05-N07,N26)",
               "Renal failure (N17-N19)",
               "Other disorders of kidney (N25,N27)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Nephritis, nephrotic syndrome and nephrosis (N00-N07,N17-N19,N25-N27)"
}

for(cause in c("Pregnancy with abortive outcome (O00-O07)", 
               "Other complications of pregnancy, childbirth and the puerperium (O10-O99)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Pregnancy, childbirth and the puerperium (O00-O99)"
}

for(cause in c("Transport accidents (V01-V99,Y85)", 
               "Nontransport accidents (W00-X59,Y86)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Accidents (unintentional injuries) (V01-X59,Y85-Y86)"
}

for(cause in c("Motor vehicle accidents (V02-V04,V09.0,V09.2,V12-V14,V19.0-V19.2,V19.4-V19.6,V20-V79,V80.3-V80.5,V81.0-V81.1,V82.0-V82.1,V83-V86,V87.0-V87.8,V88.0-V88.8,V89.0,V89.2)", 
               "Other land transport accidents (V01,V05-V06,V09.1,V09.3-V09.9,V10-V11,V15-V18,V19.3,V19.8-V19.9,V80.0-V80.2,V80.6-V80.9,V81.2-V81.9,V82.2-V82.9,V87.9,V88.9,V89.1,V89.3,V89.9)",
               "Water, air and space, and other and unspecified transport accidents and their sequelae (V90-V99,Y85)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 3
  df_deaths$parent_category[df_deaths$Cause == cause] <- "Transport accidents (V01-V99,Y85)"
}

for(cause in c("Falls (W00-W19)", 
               "Accidental discharge of firearms (W32-W34)",
               "Accidental drowning and submersion (W65-W74)",
               "Accidental exposure to smoke, fire and flames (X00-X09)",
               "Accidental poisoning and exposure to noxious substances (X40-X49)",
               "Other and unspecified nontransport accidents and their sequelae (W20-W31,W35-W64,W75-W99,X10-X39,X50-X59,Y86)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 3
  df_deaths$parent_category[df_deaths$Cause == cause] <- "Nontransport accidents (W00-X59,Y86)"
}

for(cause in c("Intentional self-harm (suicide) by discharge of firearms (X72-X74)", 
               "Intentional self-harm (suicide) by other and unspecified means and their sequelae (*U03,X60-X71,X75-X84,Y87.0)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Intentional self-harm (suicide) (*U03,X60-X84,Y87.0)"
}

for(cause in c("Assault (homicide) by discharge of firearms (*U01.4,X93-X95)", 
               "Assault (homicide) by other and unspecified means and their sequelae (*U01.0-*U01.3,*U01.5-*U01.9,*U02,X85-X92,X96-Y09,Y87.1)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "#Assault (homicide) (*U01-*U02,X85-Y09,Y87.1)"
}

for(cause in c("Discharge of firearms, undetermined intent (Y22-Y24)", 
               "Other and unspecified events of undetermined intent and their sequelae (Y10-Y21,Y25-Y34,Y87.2,Y89.9)")) {
  df_deaths$level[df_deaths$Cause == cause] <- 2
  df_deaths$parent_category[df_deaths$Cause == cause] <- "Events of undetermined intent (Y10-Y34,Y87.2,Y89.9)"
}

# Clean up the text ----
df_deaths$Cause <- gsub("#","",df_deaths$Cause)
for(i in 1:nrow(df_deaths)) {
  df_deaths$icd[i] <- strsplit(df_deaths$Cause[i]," \\(")[[1]][length(strsplit(df_deaths$Cause[i]," \\(")[[1]])]
  df_deaths$icd[i] <- gsub("\\)","",df_deaths$icd[i])
  df_deaths$icd[i] <- gsub("Residual","",df_deaths$icd[i])
  df_deaths$Cause[i] <- gsub(df_deaths$icd[i],"",df_deaths$Cause[i])
}

df_deaths$Cause <- substr(df_deaths$Cause, 1, nchar(df_deaths$Cause)-3) 

# Manually clean these ones with special characters
df_deaths$Cause[df_deaths$Cause113Code == "GR113-127"] <- "Assault (homicide)"
df_deaths$Cause[df_deaths$Cause113Code == "GR113-129"] <- "Assault (homicide) by other and unspecified means and their sequelae"
df_deaths$Cause[df_deaths$Cause == "Allotherdiseases(Residu"] <- "All other diseases (Residual)"

df_deaths$Cause <- str_trim(df_deaths$Cause)

# For the ouptut, we are splitting apart the accidents into the subcomponent
# To do this, we flip the levels
df_output <- df_deaths
df_output$level[df_output$Cause == "Accidents (unintentional injuries)"] <- 0
df_output$level[df_output$Cause == "Nontransport accidents"] <- 0
df_output$level[df_output$Cause == "Transport accidents"] <- 1
df_output$level[df_output$parent_category == "Nontransport accidents (W00-X59,Y86)"] <- 1

df_output <- df_output[df_output$level == 1,]
df_output$Month <- as.numeric(gsub("2018/","",df_output$Month_code))

# Calculate daily deaths ----
# For each month, dividing by number of days per month, only keeping January to present
df_output <- df_output[df_output$Month >= 1 & df_output$Month <= 4,]

# January
df <- df_output[df_output$Month == 1,]
df_jan <- df
df_jan$Day <- 1
for(i in 2:31) {
  df$Day <- i
  df_jan <- rbind(df_jan, df)
}
df_jan$Deaths <- df_jan$Deaths / 31

# February
df <- df_output[df_output$Month == 2,]
df_feb <- df
df_feb$Day <- 1
for(i in 2:29) {
  df$Day <- i
  df_feb <- rbind(df_feb, df)
}
df_feb$Deaths <- df_feb$Deaths / 29

# March
df <- df_output[df_output$Month == 3,]
df_mar <- df
df_mar$Day <- 1
for(i in 2:31) {
  df$Day <- i
  df_mar <- rbind(df_mar, df)
}
df_mar$Deaths <- df_mar$Deaths / 31

# April
df <- df_output[df_output$Month == 4,]
df_apr <- df
df_apr$Day <- 1
for(i in 2:30) {
  df$Day <- i
  df_apr <- rbind(df_apr, df)
}
df_apr$Deaths <- df_apr$Deaths / 30

df_output <- rbind(df_jan, df_feb, df_mar, df_apr)
df_output <- as.data.frame(df_output[c("Month","Day","Cause","Deaths")])

# Get COVID data ----
df_covid <- read.csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv", na.strings = "", fileEncoding = "UTF-8-BOM")
df_covid <- df_covid[df_covid$countriesAndTerritories == "United_States_of_America",]
df_covid <- df_covid %>%
  group_by(year, month, day) %>%
  summarise(deaths = sum(deaths))

# Drop December 2019 data
df_covid <- df_covid[df_covid$month != 12,]

df_covid$Cause <- "COVID-19"
df_covid <- df_covid[c("month","day","Cause","deaths")]
names(df_covid) <- c("Month","Day","Cause","Deaths")

max.covid <- max(as.Date(paste0("2020/",df_covid$Month,"/",df_covid$Day)))

# Merge the two datasets ----
df_covid <- rbind(df_output, df_covid)

df_covid$Date <- as.Date(paste0("2020/",df_covid$Month, "/", df_covid$Day))

df_covid <- df_covid[df_covid$Date <= max.covid,]

# Remove all 'other' causes ----
df_covid <- df_covid[df_covid$Cause != "All other diseases (Residual)" & df_covid$Cause != "Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified",]

# Shorten the text for causes so it's more legible
df_covid$Cause[df_covid$Cause == "Major cardiovascular diseases"] <- "Heart Disease"
df_covid$Cause[df_covid$Cause == "Malignant neoplasms"] <- "Cancer"
df_covid$Cause[df_covid$Cause == "Alzheimer disease"] <- "Alzheimer's Disease"
df_covid$Cause[df_covid$Cause == "Diabetes mellitus"] <- "Diabetes"
df_covid$Cause[df_covid$Cause == "Accidental poisoning and exposure to noxious substances"] <- "Drug Overdose & Poisoning"
df_covid$Cause[df_covid$Cause == "Nephritis, nephrotic syndrome and nephrosis"] <- "Kidney Disease"
df_covid$Cause[df_covid$Cause == "Intentional self-harm (suicide)"] <- "Suicide"
df_covid$Cause[df_covid$Cause == "Chronic liver disease and cirrhosis"] <- "Liver Disease"
df_covid$Cause[df_covid$Cause == "Assault (homicide)"] <- "Homicide"
df_covid$Cause[df_covid$Cause == "Other and unspecified nontransport accidents and their sequelae"] <- "Other Non-Transport Accidents"
df_covid$Cause[df_covid$Cause == "In situ neoplasms, benign neoplasms and neoplasms of uncertain or unknown behavior"] <- "Other Cancers"
df_covid$Cause[df_covid$Cause == "Certain conditions originating in the perinatal period"] <- "Infant Death"
df_covid$Cause[df_covid$Cause == "Congenital malformations, deformations and chromosomal abnormalities"] <- "Congenital Abnormalities"
df_covid$Cause[df_covid$Cause == "Certain other intestinal infections"] <- "Certain Intestinal Infections (other)"
df_covid$Cause[df_covid$Cause == "Human immunodeficiency virus (HIV) disease"] <- "HIV/AIDS"
df_covid$Cause[df_covid$Cause == "Other and unspecified infectious and parasitic diseases and their sequelae"] <- "Infectious & Parasitic Diseases (other)"
df_covid$Cause[df_covid$Cause == "Other disorders of circulatory system"] <- "Circulatory Diseases (other)"
df_covid$Cause[df_covid$Cause == "Other acute lower respiratory infections"] <- "Acute Lower Respiratory Infection (other)"
df_covid$Cause[df_covid$Cause == "Cholelithiasis and other disorders of gallbladder"] <- "Gallbladder Disease"
df_covid$Cause[df_covid$Cause == "Inflammatory diseases of female pelvic organs"] <- "Inflammatory Pelvic Disease"
df_covid$Cause[df_covid$Cause == "Accidental discharge of firearms"] <- "Firearm (Accidental)"
df_covid$Cause[df_covid$Cause == "Accidental exposure to smoke, fire and flames"] <- "Smoke and Fire"
df_covid$Cause[df_covid$Cause == "Complications of medical and surgical care"] <- "Medical/Surgical Complications"
df_covid$Cause[df_covid$Cause == "Accidental drowning and submersion"] <- "Drowning"
df_covid$Cause[df_covid$Cause == "Hyperplasia of prostate"] <- "Prostate Disease"
df_covid$Cause[df_covid$Cause == "Operations of war and their sequelae"] <- "War"
df_covid$Cause[df_covid$Cause == "Enterocolitis due to Clostridium difficile"] <- "Enterocolitis (C-diff)"
df_covid$Cause[df_covid$Cause == "Pregnancy, childbirth and the puerperium"] <- "Pregnancy & Childbirth"
df_covid$Cause[df_covid$Cause == "Other diseases of respiratory system"] <- "Respiratory Disease (other)"
df_covid$Cause[df_covid$Cause == "Chronic lower respiratory diseases"] <- "Chronic Lower Respiratory Disease"

# Limit dates for the visualization ----
# note: only keep a few entries for Februrary to highlight some specific causes--one highlight per row
#         followed up daily data through present date
df_covid <- df_covid %>%
  # Remove January
  filter(Month != 1) %>%
  # Remove the Febuary rows that are unneeded for the visualization
  filter(!(Month == 2 & Day >= 7)) %>%
  # Remove extra days from March
  filter(!(Month == 3 & Day %in% c(3:18, 20, 22:24, 27:28, 30:31))) %>%
  # Remove extra days from April
  filter(!(Month == 4 & Day %in% c(2:7, 9:14))) %>%
  # Color certain causes of death to align with the visualization callouts
  mutate(highlightColor = case_when(
            Month == 2 & Day == 2 & Cause == "Heart Disease"~ 3,
            Month == 2 & Day == 3 & Cause == "Cancer" ~ 3,
            Month == 2 & Day == 4 & Cause %in% c("Chronic Lower Respiratory Disease",
                                                 "Influenza and pneumonia",
                                                 "Respiratory Disease (other)",
                                                 "Acute Lower Respiratory Infection (other)",
                                                 "Malaria",
                                                 "Whooping cough"
                                                 ) ~ 3,
            Month == 2 & Day == 5 & Cause == "Influenza and pneumonia" ~ 3,
            Month == 2 & Day == 6 & Cause == "Drug Overdose & Poisoning" ~ 3,
            Month == 2 & (Day < 29 & Day > 1) ~ 1,
            Cause == "COVID-19" ~ 2,
            TRUE ~ 3)
    )

# Create a time-step variable to use in d3
df <- as.data.frame(unique(df_covid$Date))
df$time_step <- row_number(df)
names(df) <- c("Date","time_step")

df_covid <- left_join(df_covid, df, by = "Date")

# Write final output file ----
write.csv(df_covid, "data/wonder_data.csv", row.names = FALSE)
