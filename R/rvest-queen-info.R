library(rvest)

all_queens <- read_csv("data/all_queens_eps.csv")

all_queen_facts <- tibble()
edges <- tibble()

for (i in unique(all_queens$queen_id)) {

  # Get url ending for queen
  url_end <- all_queens %>%
    distinct(queen_id, url_end) %>%
    filter(queen_id == i) %>%
    select(url_end) %>%
    unlist()

  # Read page
  queen_wiki <- read_html(str_glue("https://rupaulsdragrace.fandom.com/wiki/{url_end}"))

  # Extract bio facts - labels
  fact_labels <- queen_wiki %>%
    html_nodes(".pi-data-label") %>%
    html_text()

  # Extract bio facts - data
  facts <- queen_wiki %>% html_nodes(".pi-data-value") %>%
    html_text() %>%
    as_tibble() %>%
    bind_cols(vars = fact_labels) %>%
    pivot_wider(names_from = vars) %>%
    janitor::clean_names()

  # Add bio facts to fact tibble
  all_queen_facts <- all_queen_facts %>%
    bind_rows(facts)

  # Extract friends list
  friends <- queen_wiki %>%
    html_nodes(".pi-data-value") %>%
    last() %>%
    html_nodes("a") %>%
    html_text()

  # Stick friends into a tibble
  friends <- tibble(
    queen_id = i,
    friend = friends
  )

  # Add friends to edges list
  edges <- edges %>% bind_rows(friends)

  # Note that queen has been completed
  print(str_glue("Complete: {url_end}"))

}

# TODO Victoria "PORKCHOP" Parker!!!!!