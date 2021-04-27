# _targets.R
library("targets")
library("unitar")
options(tidyverse.quiet = TRUE)


# Function that takes an external dataset (from another targets project),
# and returns a modified version for this project.
local_filter_big_reference_data = function(big_data_set_path) {
  big_data_set = unitar_read_from_path(big_data_set_path)
  big_data_set[big_data_set > 2]
}

list(
  tar_target(
    big_data_set_path,
    unitar_path("../refdata1", "big_data_set"),
    format = "file"
  ),
  tar_target(
    filtered_data_set,
    local_filter_big_reference_data(big_data_set_path)
  )
)
