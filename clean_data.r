library(tidyverse)
library(dplyr)
library(skimr)
library(ggplot2)
library(patchwork)

# Which authors are most successful: who is most prolific, who has the highest average ratings or popularity, and do top authors specialize by cuisine, ingredient, or recipe length?
# Is there a relationship between prep/cook time and average rating?
# Which recipe categories or cuisines tend to have the highest average ratings and review counts?
# Which recipes are the most "actionable" — high rating with low total time?

# Get the Data from TidyTuesday
tuesdata <- tidytuesdayR::tt_load(2025, week = 37)
cuisines <- tuesdata$cuisines

skim(cuisines)

missing_tbl <- tibble(
  column = names(cuisines),
  missing = sapply(cuisines, function(x) sum(is.na(x))),
  pct_missing = sapply(cuisines, function(x) mean(is.na(x)) * 100)
) %>%
  arrange(desc(pct_missing))

# print(missing_tbl)

# remove any rows with missing values in key columns (lose abou 200 rows (10% of data))
clean_cuisines <- cuisines %>%
  drop_na() 

# combine author "Allrecipes" and "Allrecipes Member" into one
clean_cuisines <- clean_cuisines %>%
  mutate(author = ifelse(author == "Allrecipes Member", "Allrecipes", author))  


# create a region variable from country
clean_cuisines <- clean_cuisines |>
  dplyr::mutate(region = dplyr::case_when(
    # East Asian
    country %in% c("Chinese", "Japanese", "Korean") ~ "East Asian",
    # Southeast Asian
    country %in% c("Filipino", "Vietnamese", "Thai",
                   "Malaysian", "Indonesian") ~ "Southeast Asian",
    # South Asian
    country %in% c("Indian", "Bangladeshi", "Pakistani") ~ "South Asian",
    # Middle Eastern / West Asian
    country %in% c("Israeli", "Lebanese", "Persian", "Turkish") ~ "Middle Eastern",
    # Northern European
    country %in% c("Scandinavian", "Swedish", "Norwegian",
                   "Danish", "Finnish") ~ "Northern European",
    # Western European
    country %in% c("French", "German", "Belgian", "Austrian",
                   "Dutch", "Swiss") ~ "Western European",
    # Southern European / Mediterranean
    country %in% c("Greek", "Italian", "Spanish", "Portuguese") ~ "Southern European",
    # Eastern European / Slavic
    country %in% c("Russian", "Polish") ~ "Eastern European",
    # Latin American
    country %in% c("Brazilian", "Chilean", "Argentinian",
                   "Peruvian", "Colombian") ~ "Latin American",
    # Caribbean
    country %in% c("Cuban", "Puerto Rican", "Jamaican") ~ "Caribbean",
    # North American
    country %in% c("Canadian", "Southern Recipes", "Soul Food",
                   "Cajun and Creole", "Tex-Mex",
                   "Amish and Mennonite", "Jewish") ~ "North American",
    # African
    country %in% c("South African") ~ "African",
    # Oceanian
    country %in% c("Australian and New Zealander") ~ "Oceanian",

    # Fallback
    TRUE ~ "Other"
  ))



# save cleaned data for analysis
##############################################################
write_csv(clean_cuisines, "data/clean_cuisines.csv")



# make distribution plot for country color all the country of the same region with the saame region color 
##############################################################
p1 <- ggplot(clean_cuisines, aes(x = country)) +
  geom_bar(aes(fill = region), color = "black", alpha = 0.7) +
  labs(title = "Distribution of Recipes by Country", x = "Country", y = "Count", fill = "Region") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
# arrange x axis by region so that same regions are together
  scale_x_discrete(limits = clean_cuisines %>% arrange(region) %>% pull(country) %>% unique())

ggsave("figures/country_distribution.png", p1, width = 12, height = 8)

# distribution plots of numeric variables
##############################################################
numeric_vars <- clean_cuisines %>%
  select(where(is.double))

plots <- list()
for (col in names(numeric_vars)) {
  p <- ggplot(clean_cuisines, aes_string(x = col)) +
    geom_histogram(binwidth = 1, fill = "blue", color = "black", alpha = 0.7) +
    labs(title = paste("Distribution of", col), x = col, y = "Frequency") +
    theme_classic()
  plots[[col]] <- p
}

# combine with patchwork: grid of 2 columns
combo <- patchwork::wrap_plots(plots, ncol = 2)
ggsave("figures/numeric_distributions_all.png", combo, width = 12, height = 8)


# plots for categorical variables
##############################################################
categorical_vars <- clean_cuisines %>%
  select(where(is.character)) |>
  select(-c(name, url, ingredients))  


plots <- list()
for (col in names(categorical_vars)) {
  p <- ggplot(clean_cuisines, aes_string(x = col)) +
    geom_bar(fill = "orange", color = "black", alpha = 0.7) +
    labs(title = paste("Distribution of", col), x = col, y = "Count") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  plots[[col]] <- p
} 
# combine with patchwork: grid of 2 columns
combo <- patchwork::wrap_plots(plots, ncol = 2)
ggsave("figures/categorical_distributions_all.png", combo, width = 25, height = 8)  

