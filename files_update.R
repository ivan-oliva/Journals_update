library(tidyverse)
library(xml2)
library(rvest)
library(purrr)


rss_journals_xml <- list()
rss_journals <- list()
rss_journals_titles <- list()

# R journal
rss_journals_xml$r_j <- read_xml("https://journal.r-project.org/rss.atom") 

rss_journals$r_j <- rss_journals_xml$r_j %>%
  xml2::as_list()

aux_entries_ind <- which(names(rss_journals$r_j$feed)=="entry")

rss_journals_titles$r_j <- rss_journals$r_j$feed[aux_entries_ind] %>%
  map(.f=function(x) {
    x$title %>%
      flatten_chr()
  }) %>%
  flatten_chr()



# scientific data
rss_journals_xml$sci_data <- read_html("http://feeds.nature.com/sdata/rss/current")

rss_journals_xml$sci_data %>%
  html_structure()

rss_journals_xml$sci_data %>%
  html_node("body")

rss_journals_xml$sci_data %>%
  html_node("body") %>%
  html_node("rdf") %>%
  html_elements("item") %>%
  html_node("encoded")  %>%
  html_text()


rss_journals_xml$sci_data %>%
  html_node("body") %>%
  html_node("rdf") %>%
  html_elements("item") %>%
  html_node("encoded")  %>%
  html_text() %>%
  .[[1]] %>%
  str_extract_all(".*2022")

rss_journals_xml$sci_data %>%
  html_node("body") %>%
  html_node("rdf") %>%
  html_elements("item") %>%
  html_node("encoded")  %>%
  html_text() %>%
  str_replace_all(".*doi", "") %>%
  str_replace_all("^.+?\\s+?", "") %>%
  str_replace("\\]]", "") %>%
  str_replace(">", "")
  
# Journal of Business & Economic Statistics
rss_journals_xml$JBES <- read_html("https://www.tandfonline.com/feed/rss/ubes20")

rss_journals_xml$JBES %>%
  html_nodes("body") %>%
  html_nodes("rdf") %>%
  html_nodes("item") %>%
  html_node("title") %>%
  html_text()
 


# Annals of math
rss_journals_xml$annals_math <- system("curl 'https://annals.math.princeton.edu/2022/195-1' -k", intern = T) %>%
  paste(collapse="") %>%
  read_html()

rss_journals_xml$annals_math %>%
  html_nodes("body") %>%
  html_nodes(css='.entry-title') %>%
  html_text()
  

#Biostatistics
rss_journals_xml$biostats <- read_html("https://academic.oup.com/rss/site_5141/3003.xml")

rss_journals_xml$biostats %>%
  html_structure()


rss_journals_xml$biostats %>%
  html_nodes("body") %>%
  html_nodes("item") %>%
  html_node("title") %>%
  html_text()



