library(rvest)

# All regular seasons
seasons <- seq(1, 2, 1)

# Create empty tibble
all_queens <- tibble(season = numeric(), queen = character())

for (i in seasons) {

  # URL for each season
  url <- str_glue("https://rupaulsdragrace.fandom.com/wiki/RuPaul%27s_Drag_Race_(Season_{i})")

  # Read season's wiki page
  season <- read_html(url)

  # Read table of queens per season
  season_queens <- season %>% html_element(".wikitable") %>%
    html_table() %>%
    filter(row_number() > 1) %>%
    select(queen = Contestant) %>%
    mutate(season = i)

  # Add season to all_queens
  all_queens <- all_queens %>% rbind(season_queens)

}

# Clean names
clean_name = str_replace(Contestant, ' "(.*?)"', ""), # Removes nicknames in quotes, like Victoria "Porkchop" Parker
url_end = str_replace_all(clean_name, " ", "_"),
