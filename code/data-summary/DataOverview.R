library(reshape2)
library(magrittr)
library(tidyverse)


boschdb <- src_sqlite("F:/basedb.sqlite3", create = T)



categoricalData <- tbl(boschdb, "categorical")

categoricalData %>%
  summarise(rows = n())

categoricalData %>%
  dplyr::group_by(line, station) %>%
  dplyr::summarise(nitems = (count(distinct(select(Id < 500000)))))

dataSummary <- categoricalData %>%
  dplyr::group_by(line, station) %>%
  dplyr::summarise_each(funs = funs(count(distinct(.)))) %>%
  collect() %>%
  ungroup() %>%
  tbl_df()
  
  
#dataSummary <- tbl(boschdb, sql("SELECT line, station, 
#                                count(distinct(id)) AS nitems, 
#                                count(distinct(feature)) AS nfeatures,
#                                count(distinct(value)) AS nvalues
#                                FROM categorical GROUP BY line, station")) %>%
#  dplyr::collect()

dataSummary
