# _targets.R
library("targets")
options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("biglm", "tidyverse"))

build_big_reference_data = function() {
  rnorm(20000)
}

filter_big_reference_data = function(big_data_set) {
  big_data_set[big_data_set > 0]
}

list(
  tar_target(
    big_data_set,
    build_big_reference_data()
  ),
  tar_target(
    filtered_data,
    filter_big_reference_data(big_data_set)
  )
)
