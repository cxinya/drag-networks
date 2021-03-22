library(rvest)
library(tidyverse)
library(gtools)


# rvest data --------------------------------------------------------------


# Create empty tibble
all_queens <- tibble()

# All regular seasons
seasons <- seq(1, 13, 1)

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
    mutate(
      season = i,
      ep_info = ifelse(row_number() == 1, 1, NA)) %>%    # th spans 2 rows, flag second row that contains ep info (e.g., Ball Challenge)
    janitor::clean_names()

  # Add season to all_queens
  all_queens <- all_queens %>% bind_rows(season_queens)

}


# Clean names and create url endings --------------------------------------

all_queens <- all_queens %>%
  mutate(
    real_name = ifelse(is.na(real_name), name, real_name),
    hometown = ifelse(is.na(hometown), current_city, hometown),
    contestant = str_replace(contestant, ' \\(Group [[:digit:]]\\)', ""), # Get rid of (Group #) in premieres where split into groups
    url_end = str_replace(contestant, ' "(.*?)"', ""), # Removes nicknames in quotes, like Victoria "Porkchop" Parker
    url_end = str_replace_all(url_end, " ", "_"),
    url_end = str_replace_all(url_end, "'", "%27"))



# Assign ids to unique queens ---------------------------------------------

ids <- all_queens %>%
  filter(is.na(ep_info)) %>%
  distinct(contestant) %>%
  rowid_to_column(var = "queen_id")

all_queens <- all_queens %>%
  left_join(ids) %>%
  select(ep_info, queen_id, season, Contestant, everything()) %>%
  select(-name, -current_city, -photo)

