library(reshape2)
library(tidyverse)
library(magrittr)

boschdb <- src_sqlite("basedb.sqlite3", create = T)

basedata <- data.frame()
tablename <- "dateinfo"

dataFile <- "rawdata/train_date.csv"

dataColNames <- readr::read_csv(dataFile, n_max = 1, col_names = F) %>%
  sapply("[[", 1) %>%
  as.vector()

cacheData <- readr::read_csv(dataFile, n_max = 3, 
                             skip = 1, col_names = F)
colnames(cacheData) <- dataColNames

meltedCache <- melt(cacheData, id.vars = 1, na.rm = T, factorsAsStrings = F)

meltedCache %<>%
  tidyr::separate(col = "variable", into = c("line", "station", "feature"), sep = "_") %>%
  dplyr::mutate(line    = as.integer(gsub(pattern = "L", replacement = "", line)),
                station = as.integer(gsub(pattern = "S", replacement = "", station)),
                feature = as.integer(gsub(pattern = "F", replacement = "", feature)))

copy_to(boschdb, meltedCache, name = tablename, temporary = F)
db_create_index(boschdb$con, tablename,  c("line", "station", "feature"))

step <- 100000
for(i in 0:1500) {
  cacheData <- readr::read_csv(dataFile, n_max = step, 
                   skip = i*step + 4, col_names = F)
    #data.table::fread(dataFile, 
    #                  skip = i*step + 4, nrows = step, 
    #                  stringsAsFactors = F, 
    #                  na.strings = c("NA","N/A",""))
  colnames(cacheData) <- dataColNames
  
  meltedCache <- melt(cacheData, id.vars = 1, na.rm = T, factorsAsStrings = F) %>%
    tidyr::separate(col = "variable", into = c("line", "station", "feature"), sep = "_") %>%
    dplyr::mutate(line    = as.integer(gsub(pattern = "L", replacement = "", line)),
                  station = as.integer(gsub(pattern = "S", replacement = "", station)),
                  feature = as.integer(gsub(pattern = "F", replacement = "", feature)))
  
  db_insert_into(boschdb$con, tablename, meltedCache)
  print(i)
}

#objsize((tbl(boschdb, from = "categorical")) %>% collect())