
categoricalData <- tbl(boschdb, "categorical")

categoricalData %>%
  summarise(rows = n())

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
