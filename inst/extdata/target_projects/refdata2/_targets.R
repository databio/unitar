# _targets.R
library("targets")
options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("biglm", "tidyverse"))

ref_data_2 = function() {
  runif(100)
}

filter_2 = function(big_data_set) {
  big_data_set[big_data_set > 0]
}

list(
  tar_target(
    ref2,
    ref_data_2()
  ),
  tar_target(
    filt_ref2,
    filter_2(ref2)
  )
)
