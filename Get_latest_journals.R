library(tidyverse)
library(xml2)
library(rvest)
library(purrr)
library(odbc)
library(RMariaDB)
library(DT)

mariad_db_conn <- dbConnect(
  drv = RMariaDB::MariaDB(), 
  username = "PROD_JOURNALS",
  password = "PROD_JOURNALS", 
  host = "192.168.1.153", 
  port = 3306,
  dbname="JOURNALS_PAPERS",
  timeout=Inf
)

journals <- dbGetQuery(mariad_db_conn,
           "SELECT * FROM JOURNALS_PAPERS.PAPERS")


datatable(journals,
          options = list(
            pageLength=25,
            searchHighlit=T),
          filter="top",
          extensions = 'Responsive',
          rownames = FALSE,
          height=1600,
          width=800)

