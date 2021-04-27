# _targets.R
library("targets")
library("simpleCache")
library("unitar")
source("R/functions.R")


p = pepr::Project("metadata/project_config.yaml")

options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("biglm", "tidyverse", "BiocProject"))
get_dhs_112_path = function() {
  return ("/home/nsheff/code/incubator/pep_targets/Rcache/dhs112.RData")
}

local_proc_ref = function(tgt) {
  d = readRDS(tgt)
  mean(d)
}

list(
  tar_target(
    ext_ref2,
    peptar_path(p, "ref2"),
    format="file"
  ),
  tar_target(
    mean_ref2,
    local_proc_ref(ext_ref2)
  ),
  tar_target( #shared cache
    dhs112_file,
    get_dhs_112_path(),
    format="file"
  ),
  tar_target(
    dhs112,
    simpleCache("dhs112", cacheDir="/home/nsheff/code/incubator/pep_targets/Rcache")
  ),
  tar_target(
    raw_data_file,
    "data/raw_data.csv",
    format = "file"
  ),
  tar_target(
    raw_data,
    read_csv(raw_data_file, col_types = cols())
  )
)
