# Unitar

Unitar is a simple R package that wraps the [targets](https://github.com/ropensci/targets) package. It provides functionality to use targets that span projects, which is outside the scope of the base targets package. With unitar, you can very easily link two targets projects, loading in built targets from other projects so that you can share caches and computing across users and projects.


## Basic demo using unitar to span projects

In the [target_projects](/target_projects), we have 2 subfolders. Each of these represents a separate project that uses targets; you can find a `_targets.R` file in each subfolder. These represent your typical, independent targets project folders.

Here's how you'd load these targets in using `unitar_load`:

```
library("unitar")
project_root = "target_projects"
project_subfolders = list.files(project_root)
project_folders = paste(project_root, project_subfolders, sep="/")

big_data_set = unitar::unitar_load(project_folders, "big_data_set")
big_data_set
```

`unitar_load` works like `tar_load`, but you give it a priority list of targets folders to search, and so it can search outside your current targets environment. This way you can share built targets across projects.

`unitar_meta` works like `tar_meta`, but runs across all the given project folders:

```
unitar_meta(project_folders)
```


## Configuring external target folders with pepr

It's kind of annoying to set up and pass around a `projects_folders` variable like this, so you can provide a list of folders in a configuration file for your project instead. `unitar` uses a project configuration file in [standard PEP format](http://pep.databio.org). You specify a list of target folders using the `tprojects` attribute, which may specify paths either absolute or relative to the configuration file. 

For example, the `project_config.yaml` file for the above `project_folders` example might look like this:

```
pep_version: "2.0.0"

tprojects:
  - ../target_projects/refdata1/
  - ../target_projects/refdata2/
  - ../
```

To make this work, `unitar` provides a series of `peptar_*` functions that work like the `unitar_*` functions above, but operate on PEPs that you can configure with your list of project folders.

```
p = pepr::Project("pep/project_config.yaml")

unitar::peptar_path(p, "ref2")
unitar::peptar_meta(p, fields="name")
unitar::peptar_make(p)

unitar::peptar_load(p, "big_data_set")
unitar::my_meta()
```
