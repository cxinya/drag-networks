library(rvest)

seasons <- seq(1, 13, 1)

html <- str_glue("https://rupaulsdragrace.fandom.com/wiki/RuPaul%27s_Drag_Race_(Season_{i})")

i <- 1

season <- read_html(html)

season %>% html_element(".wikitable") %>%
  html_table() %>%
  filter(row_number() > 1) %>%
  mutate(season = i) %>% View()
