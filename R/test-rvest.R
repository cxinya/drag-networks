library(rvest)

# Read Alaska Thunderfuck html
alaska <- read_html("https://rupaulsdragrace.fandom.com/wiki/Alaska")

# Extract bio facts
facts <- alaska %>% html_nodes(".pi-data-value")

vars <- c(
  "Drag Name",
  "Real Name",
  "Ethnicity",
  "Height",
  "Date of Birth",
  "Age",
  "Hometown",
  "Current City",
  "Season",
  "Place",
  "Eliminated",
  "Sent Home By",
  "Challenge Wins",
  "Friends")

# tibble of vars and fact values
html_text(facts) %>%
  as_tibble() %>%
  mutate(var = vars) %>%
  pivot_wider(names_from = var)

# Extract friends list
friends <- value[14] %>% html_nodes("a") %>% html_text()
