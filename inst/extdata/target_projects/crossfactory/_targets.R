# _targets.R
library("targets")
library("unitar")
options(tidyverse.quiet = TRUE)

target_folders="../refdata1"

list(
  unitar_read_xprj(target_folders, "big_data_set")
)
