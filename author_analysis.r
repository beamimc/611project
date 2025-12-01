library(dplyr)
library(ggplot2)
library(ggrepel)
library(patchwork)
library(plotly) 

# load data
df <- readr::read_csv("data/clean_cuisines.csv")


# Which authors are most successful: who is most prolific, who has the highest average ratings or popularity,
# and do top authors specialize by cuisine, ingredient, or recipe length?

# check out the top 20 contributing authors by number of recipes
top_authors <- df %>%
  group_by(author) %>%  
  summarise(num_recipes = n(),
            avg_rating = mean(avg_rating, na.rm = TRUE),
            num_ratings = mean(total_ratings, na.rm = TRUE)) %>%
  arrange(desc(num_recipes)) 

# include top contributing if more in the top 50 by num_recipes 
# also include top rated if more in the top 50 by avg_rating
top_authors <- top_authors %>%
    arrange(desc(num_recipes)) %>%
    mutate( 
        #most_contrib = TRUE if more than 10 recipes
        most_contrib = ifelse(num_recipes > 10, TRUE, FALSE),
    )

top_authors <- top_authors %>%
    arrange(desc(avg_rating)) %>%
    mutate(
        #top_rated = TRUE if in the top 50 by avg_rating
        top_rated = ifelse(avg_rating >= 4.4, TRUE, FALSE)
    )


top_authors <- top_authors %>%
    filter(most_contrib == TRUE | top_rated == TRUE)


# filter to only those authors who are  most_contrib and top_rated
super_top_authors <- top_authors %>%
    filter(most_contrib == TRUE & top_rated == TRUE)


plots <- list()
# plot top authors x number of recipes and y average rating
p <- ggplot(top_authors, aes(x = num_recipes, y = avg_rating, label = author)) +
  geom_point(aes(color = most_contrib & top_rated), size = 3, alpha = 0.7) +
  geom_text_repel(data = super_top_authors, size = 5) +
  labs(title = "Author Success: Number of Recipes vs Average Rating",
       x = "Number of Recipes",
       y = "Average Rating",
       color = "Top Contributor & Top Rated") +
  theme_classic() +
  #increase all text size
    theme(text = element_text(size = 20))
plots[["author_success"]] <- p

# remove john mitzewich bc outlier
top_authors_no_john <- top_authors %>%
    filter(author != "John Mitzewich")

# plot top authors x number of recipes and y average rating
p <- ggplot(top_authors_no_john, aes(x = num_recipes, y = avg_rating, label = author)) +
  geom_point(aes(color = most_contrib & top_rated), size = 3, alpha = 0.7) +
  geom_text_repel(data = (super_top_authors |> filter(author != "John Mitzewich")), size = 5) +
  labs(title = "Author Success: Number of Recipes vs Average Rating",
       x = "Number of Recipes",
       y = "Average Rating",
       color = "Top Contributor & Top Rated") +
  theme_classic() +
  #increase all text size
    theme(text = element_text(size = 20))
plots[["author_success_no_john"]] <- p

combo <- patchwork::wrap_plots(plots, ncol = 1)
ggsave("figures/author_success.png", combo, width = 20, height = 20)


# make interactive plot with plotly for all authors
all_authors <- df %>%
  group_by(author) %>%  
  summarise(num_recipes = n(),
            avg_rating = mean(avg_rating, na.rm = TRUE),
            num_ratings = mean(total_ratings, na.rm = TRUE)) %>%
  arrange(desc(num_recipes)) |>
    mutate( 
        #most_contrib = TRUE if more than 10 recipes
        most_contrib = ifelse(num_recipes > 10, TRUE, FALSE),
        #top_rated = TRUE if in the top 50 by avg_rating
        top_rated = ifelse(avg_rating >= 4.4, TRUE, FALSE)
    )

p_interactive <- ggplot(all_authors, aes(x = num_recipes, y = avg_rating, 
                    label = author, text = paste("Author:", author, "<br>Number of Recipes:", 
                                    num_recipes, "<br>Average Rating:", round(avg_rating, 2)))) +
  geom_point(aes(color = most_contrib & top_rated), size = 3, alpha = 0.7) +
  labs(title = "Author Success: Number of Recipes vs Average Rating",
       x = "Number of Recipes",
       y = "Average Rating",
       color = "Top Contributor & Top Rated") +
  theme_classic()   

# ggplotly(p_interactive, tooltip = "text")
# # save interactive plot
# htmlwidgets::saveWidget(ggplotly(p_interactive, tooltip = "text"), "figures/author_success_interactive.html")


# check type of food cuisines by these top authors
top_author_cuisines <- df %>%
  filter(author %in% super_top_authors$author) %>%
    group_by(author, country) %>%
    summarise(num_recipes = n()) %>%
    arrange(author, desc(num_recipes))
# plot stacked bar chart of top authors and their cuisines
p <- ggplot(top_author_cuisines, aes(x = author, y = num_recipes, fill = country)) +
  geom_bar(stat = "identity") +
  labs(title = "Top Authors by Cuisine Type",
       x = "Author",
       y = "Number of Recipes",
       fill = "Cuisine Type") +
  theme_classic() +
    theme(text = element_text(size = 16),
          axis.text.x = element_text(angle = 45, hjust = 1))
#save plot
ggsave("figures/top_authors_cuisines.png", p, width = 12 , height = 8)

# p_interactive <- ggplotly(p)
# #save interactive plot
# htmlwidgets::saveWidget(p_interactive, "figures/top_authors_cuisines_interactive.html")

