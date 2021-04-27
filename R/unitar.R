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
#' @param tar_folders A list of root folders of targets-managed projects
#' @param func Function to execute
#' @param ... Additional arguments to function
#' @export
#' @examples 
#' tar_folders=""
#' unitar_exec(tar_folders, tar_meta) 
unitar_exec = function(tar_folders, func=tar_make, ...) {
	lapply(tar_folders, function(folder) {
		message(folder)
		tryCatch({
			withr::with_dir(folder, func(...))
		}, error=function(x) NA)
	})
}


#' A global tar_make function that spans all tar_target folders
#' @param tar_folders A list of root folders of targets-managed projects
#' @examples
#' tar_folders=""
#' unitar_meta(tar_folders)
#' @export
unitar_make = function(tar_folders) {
	unitar_exec(tar_folders, tar_make)
}


#' Call tar_meta across multiple tar projects
#' @param tar_folders A list of root folders of targets-managed projects
#' @param ... Additional arguments to tar_meta function
#' @examples
#' tar_folders=""
#' unitar_meta(tar_folders)
#' @export
unitar_meta = function(tar_folders, ...) {
	unitar_exec(tar_folders, tar_meta, ...)
}


#' Load targets from a list of possible target repositories
#' 
#' This looks in priority order through the list of tprojects, and, if it finds
#' a matching target, it reads it in and returns it.
#' 
#' @param tar_folders A priority list of root folders of targets-managed projects
#' @param tname The name of the target to query
#' @export
unitar_read = function(tar_folders, tname) {
	utmeta = unitar_meta(tar_folders)
	for (i in seq_len(length(utmeta))) {
		tmeta = utmeta[[i]]
		if (tname %in% tmeta$name) {
			folder = tar_folders[i]
			# return(withr::with_dir(folder, readRDS(paste0("_targets/objects/", tname))))
			return(withr::with_dir(folder, tar_read_raw(tname)))
		}
	}
}

#' Load targets from a list of possible target repositories
#' 
#' This looks in priority order through the list of tprojects, and, if it finds
#' a matching target, it loads it silently into the workspace
#' 
#' @param tar_folders A priority list of root folders of targets-managed projects
#' @param tname The name of the target to query
#' @export
unitar_load = function(tar_folders, tname) {
	utmeta = unitar_meta(tar_folders)
	for (i in seq_len(length(utmeta))) {
		tmeta = utmeta[[i]]
		if (tname %in% tmeta$name) {
			folder = tar_folders[i]
			withr::with_dir(folder, tar_load_raw(tname, envir=parent.frame()))
			return(invisible())
		}
	}
}


#' Returns the path to the cache of the given target
#' 
#' @param tar_folders A priority list of root folders of targets-managed projects
#' @param tname The name of the target to query
#' @export
unitar_path = function(tar_folders, tname) {
	utmeta = unitar_meta(tar_folders)
	for (i in seq_len(length(utmeta))) {
		tmeta = utmeta[[i]]
		if (tname %in% tmeta$name) {
			folder = enforceTrailingSlash(tar_folders[i])
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
#' @param tar_folders A priority list of root folders of targets-managed projects
#' @param tname The name of the target to query
#' @export
unitar_read_xprj = function(tar_folders, tname) {
	list(
		tar_target_raw("file", unitar_path(tar_folders, tname), format = "file"),
		tar_target_raw(tname, quote(unitar_read_from_path(file)))
	)
}
