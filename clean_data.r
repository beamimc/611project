library(tidyverse)
library(dplyr)
library(skimr)

# Get the Data from TidyTuesday

# Read in with tidytuesdayR package 
# Install from CRAN via: install.packages("tidytuesdayR")
# This loads the readme and all the datasets for the week of interest

# Either ISO-8601 date or year/week works!

tuesdata <- tidytuesdayR::tt_load('2022-05-17')
tuesdata <- tidytuesdayR::tt_load(2022, week = 20)

eurovision <- tuesdata$eurovision


# Overview 
# dims, names, structure
dim(eurovision)
colnames(eurovision)
glimpse(eurovision)

# skim for quick summary statistics
skimr::skim(eurovision)

# Drop undesired columns for analysis (urls, emojis, rank_ordinal (== rank)) 
eurovision <- eurovision %>%
  select(-c(event_url, artist_url, image_url, country_emoji, rank_ordinal ))

# check missing values 
eurovision %>% 
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  tidyr::pivot_longer(everything(),
                      names_to = "variable", 
                      values_to = "n_missing")

# check missing values by year
eurovision %>%
  group_by(year) %>%
  summarise(
    n_missing_total = sum(across(everything(), ~sum(is.na(.))))
  ) %>%
  arrange(desc(n_missing_total))

# drop entries from year 2020 because event was cancelled due to COVID-19 pandemic
eurovision <- eurovision %>%
  filter(year != 2020)  


# normalize section var: final == grand final, semi-final == second-semi-final (names changed over years)

eurovision <- eurovision %>%
  mutate(section = case_when(
    section == "final" ~ "grand-final",
    section == "semi-final" ~ "second-semi-final",
    TRUE ~ section
  ))


# save cleaned data  
# create data directory if it doesn't exist
if (!dir.exists("data")) {
  dir.create("data")
}
write_csv(eurovision, "data/eurovision_cleaned.csv")
