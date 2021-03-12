# Unit tests
library("unitar")

test_that("load", {
	project_root = system.file("extdata", "target_projects", package="unitar")

	project_subfolders = list.files(project_root)
	project_folders = paste(project_root, project_subfolders, sep="/")

	unitar::unitar_make(project_folders)

	big_data_set = unitar::unitar_load(project_folders, "big_data_set")
	testthat::expect_equal(big_data_set[1] , -1.39609368)
})