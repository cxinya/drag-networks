library(rvest)
library(tidyverse)
library(gtools)

# All regular seasons
seasons <- seq(1, 13, 1)

# Create empty tibble
all_queens <- tibble(season = numeric(), Rank = character(), Contestant = character())

# Add queens from each season
for (i in seasons) {

  # URL for each season
  url <- str_glue("https://rupaulsdragrace.fandom.com/wiki/RuPaul%27s_Drag_Race_(Season_{i})")

  # Read season's wiki page
  season <- read_html(url)

  # Solution to turn <br> into spaces: https://stackoverflow.com/questions/30921626/can-rvest-keep-inline-html-tags-such-as-br-using-html-table
  xml_find_all(season, ".//br") %>% xml_add_sibling("p", " ")
  xml_find_all(season, ".//br") %>% xml_remove()

  # Read table of queens per season
  season_queens <- season %>% html_element(".wikitable") %>%
    html_table() %>%
    # filter(row_number() > 1) %>%
    # select(queen = Contestant, rank = Rank) %>%
    mutate(
      season = i,
      col_subtitle = ifelse(row_number() == 1, 1, NA)) %>%
    select(col_subtitle, season, Contestant, everything()) %>%
    # rename_all(funs(str_replace(., 'Ep.\\b', 'Ep. '))) %>%
    janitor::clean_names()

  # Add season to all_queens
  # all_queens <- all_queens %>% rbind(season_queens)
  all_queens <- all_queens %>% bind_rows(season_queens)

}


# # TODO clean names, fix spaces, replace hyphens
#
# # Clean names
# clean_name = str_replace(Contestant, ' "(.*?)"', ""), # Removes nicknames in quotes, like Victoria "Porkchop" Parker
# url_end = str_replace_all(clean_name, " ", "_"),
