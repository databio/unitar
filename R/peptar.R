# peptar functions provide an easy interface to use unitar with pepr


#' Execute a function across all target folders specified in the current Project.
#' @param p A pepr::Project object representing your current project.
#' @param ... Function and parameters to execute
#' @export
peptar_exec = function(p, ...) {
	tar_folders = p@config$tprojects
	tar_folders
	unitar_exec(tar_folders, ...)
}


#' Retrieves tar folders from PEP
#' @param p A pepr::Project object representing your current project.
#' @export
peptar_folders = function(p) {
	# return(p@config$tprojects)  # No path normalization

	tproj_rel = function(relpath, relto) { 
		paste0(normalizePath(withr::with_dir(dirname(relto), fs::path_wd(relpath))), "/")
	}
	unlist(lapply(p@config$tprojects, tproj_rel, p@file))
}


#' Execute tar_meta across all target folders specified in the current Project.
#' @param p A pepr::Project object representing your current project.
#' @param ... Parameters to pass to tar_meta
#' @export
peptar_meta = function(p, ...) {
	unitar_meta(peptar_folders(p), ...)
}


#' Execute tar_make across all target folders specified in the current Project.
#' @param p A pepr::Project object representing your current project.
#' @param ... Parameters to pass to tar_make
#' @export
peptar_make = function(p, ...) {
	unitar_make(peptar_folders(p), ...)
}


#' Find path to a target from all your PEP target folders
#' @param p A pepr::Project object representing your current project.
#' @param tname The name of the target to query
#' @export
peptar_path = function(p, tname) {
	unitar_path(peptar_folders(p), tname)
}


#' Load a target and return it, from all your PEP target folders
#' @param p A pepr::Project object representing your current project.
#' @param tname The name of the target to query
#' @export
peptar_read = function(p, tname) {
	unitar_read(peptar_folders(p), tname)
}


#' Load a target invisibly, from all your PEP target folders
#' @param p A pepr::Project object representing your current project.
#' @param tname The name of the target to query
#' @export
peptar_load = function(p, tname) {
	unitar_load(peptar_folders(p), tname)
}


#' Simplified tar_meta function with only a few fields.
#' @export
my_meta = function() {
	tar_meta(fields=c("name", "bytes", "seconds", "path"))
}
