#' Helper function to build target functions to track and read files
#' 
#' This is a target factory that will produce a target to track
#' a file, and then to read that file using an arbitrary function
#' provided by the user.
#' 
#' @param sample_name Name of the target
#' @param rootpath Path to where resource files are kept
#' @param filepath Relative path to file
#' @param func Function to use to load file in R
#' @export
#' 
load_external_file = function(sample_name, rootpath, filepath, func) {
  fullpath = paste0(rootpath, filepath)
  name_file = paste0(sample_name, "_file")
  command_data = substitute(func(fullpath), env=list(fullpath=as.symbol(name_file), func=as.symbol(func)))

  list(
    tar_target_raw(name_file, fullpath, format = "file"),
    tar_target_raw(sample_name, command_data)
  )  
}


#' Experimental target factory to track but not duplicate external files.
#'
#' EXPERIMENTAL. This function is just a concept that has not been tested.
#' It will change or disappear in future versions.
#' @export
track_external_target = function(tname, ext_tname, func) {
  fullpath = unitar_path(ext_tname)
  name_file = paste0(sample_name, "_file")
  command_data = substitute(func(fullpath), env=list(fullpath=as.symbol(name_file), func=as.symbol(func)))

  list(
    tar_target_raw(name_file, fullpath, format = "file"),
    tar_target_raw(tname, command_data)
  )  
}


#' Helper function to build targets from function calls with custom args
#' 
#' This function is a target factory that will produce a target for an
#' arbitrary function call with arbitrary arguments and values.
#' 
#' @param tname Target name
#' @param func Function to call
#' @param argnames List of arg names
#' @param argvals List of arg values
#' @param argtypes List of arg types (use 'symbol' for targets)
load_custom_old = function(tname, func, argvals, argtypes, argnames) {
  l = as.list(argvals)
  names(l) = argnames
  l[argtypes == "symbol"] = lapply(l[argtypes == "symbol"], as.symbol)
  l[argtypes == "numeric"] = lapply(l[argtypes == "numeric"], as.numeric) 
  args_expr = as.call(c(as.symbol("list"), l))
  command_data = substitute(
    do.call(func, args),
    env = list(args = args_expr, func = as.symbol(func))
  )
  tar_target_raw(tname, command_data)
}


# This version adds support for argtypes=file
#' Helper function to build targets from function calls with custom args
#' 
#' This function is a target factory that will produce a target for an
#' arbitrary function call with arbitrary arguments and values.
#' 
#' @param tname Target name
#' @param func Function to call
#' @param argvals List of arg values
#' @param argtypes List of arg types (use 'symbol' for targets)
#' @param argnames List of arg names
#' @export
load_custom = function(tname, func, argvals, argtypes, argnames=NULL) {
  l = as.list(argvals)
  # if (!is.null(argnames)) {
    names(l) = argnames
  # }

  # First, handle function calls that have file paths as argument:
  # 1. Add a file tracking target, with _fileX appended to the target name
  # 2. Adjust the argument to be a symbol with appropriate target name
  nFiles = length(l[argtypes == "file"])
  targets_list = list()
  for (i in seq_len(nFiles)) {
    path = l[argtypes == "file"][i]
    tname_file = paste0(tname, "_file", i)
    targets_list = append(targets_list, 
        tar_target_raw(tname_file, path, format="file"))
    l[argtypes == "file"][i] = tname_file  
    argtypes[argtypes == "file"][i] = "symbol"
  }

  # Next, handle all other argument types.
  l[argtypes == "symbol"] = lapply(l[argtypes == "symbol"], as.symbol)
  l[argtypes == "numeric"] = lapply(l[argtypes == "numeric"], as.numeric) 
  args_expr = as.call(c(as.symbol("list"), l))
  command_data = substitute(
    do.call(func, args),
    env = list(args = args_expr, func = as.symbol(func))
  )
  targets_list = append(targets_list, tar_target_raw(tname, command_data))
  targets_list
}




#' Target factory to build targets from a PEP
#' 
#' @param p PEP defining targets to build
build_pep_resource_targets_prj_old = function(p) {
  tbl = sampleTable(p)
  loadable_targets = list()
  i=1
  for (i in 1:nrow(tbl)) {
    if (tbl[[i, "type"]] == "file") {
      loadable_targets[[i]] = load_external_file(tbl[[i, "sample_name"]],
                                     config(p)$data_root,
                                     tbl[[i, "local_path"]],
                                     tbl[[i, "function"]])
    } else if (tbl[[i, "type"]] == "call") {
      loadable_targets[[i]] = load_custom(tbl[[i, "sample_name"]],
                                       tbl[[i, "function"]],
                                       tbl[[i, "argval"]],
                                       tbl[[i, "argtype"]],
                                       tbl[[i, "argname"]]
                                    )
    }
  }
  return(loadable_targets)
}


#' Target factory to build targets from a PEP
#' 
#' @param p PEP defining targets to build
#' @export
build_pep_resource_targets_prj = function(p) {
  tbl = sampleTable(p)
  loadable_targets = list()
  i=1
  for (i in 1:nrow(tbl)) {
      loadable_targets[[i]] = load_custom(tbl[[i, "sample_name"]],
                                       tbl[[i, "function"]],
                                       pepr::.expandPath(tbl[[i, "argval"]]),
                                       tbl[[i, "argtype"]],
                                       tbl[[i, "argname"]]
                                    )
  }
  return(loadable_targets)
}

#' Target factory for arbitrary functions on PEP samples
#' 
#' This target factory creates a target for each element of a PEP. You can
#' name the targets using a pattern that uses brackets to indicate sample
#' attributes, like `{sample_name}`.
#' 
#' @param p PEP.
#' @param tpattern Target name, with patterns allowed
#' @param func Function to call
#' @param argvals_pattern List of arg values, with patterns allowed
#' @param argtypes List of arg types (use 'symbol' for targets)
#' @param argnames List of arg names
#' @param combine_tname Target name for a combined target that merges all of the individual targets
#' @param combine_func_name Character vector of a function that will combine them.
#' 
#' @export
tar_pep_foreach = function(p, tpattern, func, argvals_pattern, argtypes, argnames=NULL,
  combine_tname=NULL, combine_func_name="list") {
  tbl = sampleTable(p)
  loadable_targets = list() 
  for (i in 1:nrow(tbl)) {
    tname = with(tbl[i,], glue::glue(tpattern))
    argvals = sapply(argvals_pattern, function(x) {
      with(tbl[i,], glue::glue(x))
    })
    loadable_targets[[tname]] = unitar::load_custom(tname, func, argvals, argtypes, argnames)
  }
  tnames = names(loadable_targets)
  
  if (!is.null(combine_tname)) {
     loadable_targets[[length(loadable_targets)+1]] = unitar::load_custom(
       combine_tname, combine_func_name, tnames, rep("symbol", length(tnames)), tnames) 
  }
  return(loadable_targets)
}




#' Target factory to build targets from a PEP
#' 
#' @param config Path to PEP config file
#' @export
build_pep_resource_targets = function(config) {
  p = pepr::Project("config.yaml")
  return(build_pep_resource_targets_prj(p))
}


#' Helper function to load target-creation functions from PEP config
#' 
#' This function simple sources the target functions specified in
#' a 'target_load_functions' attribute of a PEP. It's meant to be
#' called from a _targets.R file, so you don't have to source those
#' scripts individually, but can consolidate the configuration into
#' the PEP config file.
#' @param config Path to the PEP config file for the resource targets list.
#' @export
source_target_functions = function(config) {
  p = pepr::Project("config.yaml")

  # The config should have a pointer to source files:
  tf = config(p)$target_load_functions
  for (i in 1:length(tf)) {
    source(tf[[i]], local=parent.frame())
  }
}
