# PACKAGE DOCUMENTATION
#' Targets that span projects
#'
#' Targets! now shared!
#'
#' @docType package
#' @name unitar
#' @author Nathan Sheffield
#'
#' @import fs withr pepr targets
NULL

#' Execute a function across a list of tar_target folders
#' @param tar_dirs A list of root folders of targets-managed projects
#' @param func Function to execute
#' @param ... Additional arguments to function
#' @export
#' @examples 
#' tar_dirs=""
#' unitar_exec(tar_dirs, tar_meta) 
unitar_exec = function(tar_dirs, func=tar_make, ...) {
	tar_dirs = getOption("tar_dirs")	
	lapply(tar_dirs, function(folder) {
		message(folder)
		tryCatch({
			withr::with_dir(folder, func(...))
		}, error=function(x) NA)
	})
}


#' A global tar_make function that spans all tar_target folders
#' @param tar_dirs A list of root folders of targets-managed projects
#' @examples
#' tar_dirs=""
#' unitar_meta(tar_dirs)
#' @export
unitar_make = function(tar_dirs) {
	tar_dirs = getOption("tar_dirs")	
	unitar_exec(tar_dirs, tar_make)
}


#' Call tar_meta across multiple tar projects
#' @param tar_dirs A list of root folders of targets-managed projects
#' @param ... Additional arguments to tar_meta function
#' @examples
#' tar_dirs=""
#' unitar_meta(tar_dirs)
#' @export
unitar_meta = function(tar_dirs, ...) {
	tar_dirs = getOption("tar_dirs")
	unitar_exec(tar_dirs, tar_meta, ...)
}


#' Gets a tar_dirs folder from either argument or R option
#' 
#' @param tar_dirs Folder or list of folders (or NULL if using option)
#' @export
get_tar_dirs = function(tar_dirs) {
	if (is.null(tar_dirs)) {
		tar_dirs = getOption("tar_dirs")
	}
	if (is.null(tar_dirs)) {
		stop("Must provide tar_dirs or set option tar_dirs")
	}
	return(tar_dirs)
}


#' Load targets from a list of possible target repositories
#' 
#' This looks in priority order through the list of tprojects, and, if it finds
#' a matching target, it reads it in and returns it.
#' 
#' @param tname The name of the target to query
#' @param tar_dirs A priority list of root folders of targets-managed projects
#' @export
unitar_read = function(tname, tar_dirs=NULL) {
	tar_dirs = get_tar_dirs(tar_dirs)
	utmeta = unitar_meta(tar_dirs)
	for (i in seq_len(length(utmeta))) {
		tmeta = utmeta[[i]]
		if (tname %in% tmeta$name) {
			folder = tar_dirs[i]
			return(withr::with_dir(folder, tar_read_raw(tname)))
		}
	}
}


#' Load targets from a list of possible target repositories
#' 
#' This looks in priority order through the list of tprojects, and, if it finds
#' a matching target, it loads it silently into the workspace
#' 
#' @param tname The name of the target to query
#' @param tar_dirs A priority list of root folders of targets-managed projects
#' @export
unitar_load = function(tname, tar_dirs=NULL) {
	tar_dirs = get_tar_dirs(tar_dirs)	
	utmeta = unitar_meta(tar_dirs)
	for (i in seq_len(length(utmeta))) {
		tmeta = utmeta[[i]]
		if (tname %in% tmeta$name) {
			folder = tar_dirs[i]
			withr::with_dir(folder, tar_load_raw(tname, envir=parent.frame()))
			return(invisible())
		}
	}
}


#' Returns the path to the cache of the given target
#' 
#' @param tname The name of the target to query
#' @param tar_dirs A priority list of root folders of targets-managed projects
#' @export
unitar_path = function(tname, tar_dirs=NULL) {
	tar_dirs = get_tar_dirs(tar_dirs)	
	utmeta = unitar_meta(tar_dirs)
	for (i in seq_len(length(utmeta))) {
		tmeta = utmeta[[i]]
		if (tname %in% tmeta$name) {
			folder = enforceTrailingSlash(tar_dirs[i])
			return(paste0(folder, "_targets/objects/", tname))
		}
	}	
}


#' Reads a target given a direct path, likely output from \code{unitar_path}
#' 
#' @param tpath The path to the target to read
#' @export
unitar_read_from_path = function(tpath) {
	folder = gsub("(.*)/_targets/objects/.*", "\\1", tpath)
	tname =  gsub(".*_targets/objects/(.*)", "\\1", tpath)
	unitar_read(folder, tname)
}


# Here's a cross-project target factory
#' Load targets across projects
#' 
#' This function will allow you to load and track cached targets
#' from other target projects.
#' @param tname The name of the target to query
#' @param tar_dirs A priority list of root folders of targets-managed projects
#' @export
unitar_read_xprj = function(tname, tar_dirs=NULL) {
	list(
		tar_target_raw("file", unitar_path(tname, tar_dirs), format = "file"),
		tar_target_raw(tname, quote(unitar_read_from_path(file)))
	)
}

