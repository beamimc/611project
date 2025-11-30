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

print(missing_tbl)

# remove any rows with missing values in key columns (lose abou 200 rows (10% of data))
clean_cuisines <- cuisines %>%
  drop_na() 

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
ggsave("figures/categorical_distributions_all.png", combo, width = 12, height = 8)  



# save cleaned data for analysis
##############################################################
write_csv(clean_cuisines, "data/clean_cuisines.csv")
