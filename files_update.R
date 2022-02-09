library(tidyverse)
library(xml2)
library(rvest)
library(purrr)
library(odbc)
library(RMariaDB)


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

rss_journals_titles$sci_data <- rss_journals_xml$sci_data %>%
  html_node("body") %>%
  html_elements("item") %>%
  html_node("encoded")  %>%
  html_text() %>%
  str_replace_all(".*doi", "") %>%
  str_replace_all("^.+?\\s+?", "") %>%
  str_replace("\\]]", "") %>%
  str_replace(">", "")
  
# Journal of Business & Economic Statistics
rss_journals_xml$JBES <- read_html("https://www.tandfonline.com/feed/rss/ubes20")

rss_journals_titles$JBES <- rss_journals_xml$JBES %>%
  html_nodes("body") %>%
  html_nodes("rdf") %>%
  html_nodes("item") %>%
  html_node("title") %>%
  html_text()
 
# Annals of math
date_annals_math_num <- today()
#date_annals_math_num <- dmy("01082022")

annals_math_page <- paste('https://annals.math.princeton.edu/',
                          year(date_annals_math_num),
                          '/',
                          (year(date_annals_math_num)-2022) + 194 + ceiling(month(date_annals_math_num)/6),
                          '-',
                          ceiling((month(date_annals_math_num) %% 6)/2),
                          sep="")

aux_code_curl <- paste("curl ",
                       "'", annals_math_page, "'",
                       " -k",
                       sep="")
                          


rss_journals_xml$annals_math <- system(aux_code_curl, intern = T) %>%
  paste(collapse="") %>%
  read_html()

rss_journals_titles$annals_math <- rss_journals_xml$annals_math %>%
  html_nodes("body") %>%
  html_nodes(css='.entry-title') %>%
  html_text()
  

#Biostatistics
rss_journals_xml$biostats <- read_html("https://academic.oup.com/rss/site_5141/3003.xml")

rss_journals_titles$biostats <- rss_journals_xml$biostats %>%
  html_nodes("body") %>%
  html_nodes("item") %>%
  html_node("title") %>%
  html_text()


# Union of papers
jounrnals_db_table <- map2(.x=rss_journals_titles, .y=names(rss_journals_titles), .f = function(x, y) {
  tibble(PAPER=x, JOURNAL=y) %>%
    return()
}
) %>%
  reduce(bind_rows) %>%
  mutate(DATE_ADDED=today())






mariad_db_conn <- dbConnect(
    drv = RMariaDB::MariaDB(), 
    username = "PROD_JOURNALS",
    password = "PROD_JOURNALS", 
    host = "192.168.1.153", 
    port = 3306,
    dbname="JOURNALS_PAPERS",
    timeout=Inf
)

papers_in_base <- dbGetQuery(mariad_db_conn,
           "SELECT PAPER FROM JOURNALS_PAPERS.PAPERS") %>%
  pull(PAPER)

jounrnals_db_table <- jounrnals_db_table %>%
  filter(!PAPER %in% papers_in_base)

if(nrow(jounrnals_db_table)>0) {
  table_id <- Id(schema="JOURNALS_PAPERS",
                 table="PAPERS")
  
  odbc::dbWriteTable(mariad_db_conn,
                     table_id,
                     jounrnals_db_table,
                     append=T)  
}








