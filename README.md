# Unitar

Unitar is a simple R package that wraps the [targets](https://github.com/ropensci/targets) package. It provides functionality to use targets that span projects, which is outside the scope of the base targets package. With unitar, you can very easily link two targets projects, loading in built targets from other projects so that you can share caches and computing across users and projects.


## Basic demo

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


## Using unitar with pepr

It's kind of annoying to set up and pass around a `projects_folders` variable like this, so I've simplified a connection to using a standard [PEP](http://pep.databio.org) to keep track of these things for you. To make this work, `unitar` provides a series of `peptar_*` functions that work like the `unitar_*` functions above, but operate on PEPs that you can configure with your list of project folders.

```
p = pepr::Project("pep/project_config.yaml")

peptar_path(p, "ref2")
peptar_meta(p, fields="name")
peptar_make(p)

peptar_load(p, "big_data_set")
my_meta()
```
