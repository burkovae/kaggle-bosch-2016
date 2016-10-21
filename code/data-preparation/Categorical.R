library(reshape2)
library(tidyverse)
library(magrittr)

boschdb <- src_sqlite("basedb.sqlite3", create = T)

basedata <- data.frame()

dataColNames <- readr::read_csv("rawdata/train_categorical.csv", n_max = 1, col_names = F) %>%
  sapply("[[", 1) %>%
  as.vector()

cacheData <- readr::read_csv("rawdata/train_categorical.csv", n_max = 3, 
                             skip = 1, col_names = F)
colnames(cacheData) <- dataColNames

meltedCache <- melt(cacheData, id.vars = 1, na.rm = T, factorsAsStrings = F)

meltedCache %<>%
  tidyr::separate(col = "variable", into = c("line", "station", "feature"), sep = "_") %>%
  dplyr::mutate(line    = as.integer(gsub(pattern = "L", replacement = "", line)),
                station = as.integer(gsub(pattern = "S", replacement = "", station)),
                feature = as.integer(gsub(pattern = "F", replacement = "", feature)))

copy_to(boschdb, meltedCache, name = "categorical", temporary = F)


step <- 100000
for(i in 0:2000) {
  cacheData <- readr::read_csv("rawdata/train_categorical.csv", n_max = step, 
                   skip = i*step + 4, col_names = F)
    #data.table::fread("rawdata/train_categorical.csv", 
    #                  skip = i*step + 4, nrows = step, 
    #                  stringsAsFactors = F, 
    #                  na.strings = c("NA","N/A",""))
  colnames(cacheData) <- dataColNames
  
  meltedCache <- melt(cacheData, id.vars = 1, na.rm = T, factorsAsStrings = F) %>%
    tidyr::separate(col = "variable", into = c("line", "station", "feature"), sep = "_") %>%
    dplyr::mutate(line    = as.integer(gsub(pattern = "L", replacement = "", line)),
                  station = as.integer(gsub(pattern = "S", replacement = "", station)),
                  feature = as.integer(gsub(pattern = "F", replacement = "", feature)))
  
  db_insert_into(boschdb$con, "categorical", meltedCache)
  print(i)
}

#objsize((tbl(boschdb, from = "categorical")) %>% collect())