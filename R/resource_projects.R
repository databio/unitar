# This is the latest way to do it.
#' Load targets specified by a CSV
#' 
#' This function will allow you to load and track files from a resource folder
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

# For functions
#' Load result of a function call with custom args
#' 
#' @param tname Target name
#' @param func Function to call
#' @param args List of arg names
#' @param vals List of arg values
#' @export
load_custom = function(tname, func, args, vals) {
  l = as.list(vals)
  names(l) = args
  command_data = substitute(do.call(func, args), env=list(args=l, 
      func=as.symbol(func)))

  list(
    tar_target_raw(tname, command_data)
  )  
}

#' Target factory to build targets from a PEP
#' 
#' @param p PEP defining targets to build
#' @export
build_pep_resource_targets = function(p) {
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
                                       tbl[[i, "arg"]],
                                      tbl[[i, "val"]])
    }
  }
  return(loadable_targets)
}
