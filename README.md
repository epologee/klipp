# Klipp [![Build Status](https://travis-ci.org/epologee/klipp.png)](https://travis-ci.org/epologee/klipp)
## Code templates for the rest of us.

Klipp is a ruby gem with a command line interface for creating new programming projects from existing templates. It was originally designed to create Xcode projects. However, there are no Apple or Xcode specific features in Klipp, so you can use it for pretty much any textfile-and-directory-based template.

When compared to Xcode's plist-based templating system, Klipp takes an existing Xcode project and creates a new project by copying and modifying an existing template project by your own specifications.

## Installation

Install Klipp with RubyGems:

    $ gem install klipp

Execute and read the usage instructions:

    $ klipp

## CLI under construction ...

Klipp is still in the early development stage. When 0.1 ships, the CLI will feature:

* `klipp repo add <repo-name> [<repo-url>]` - git init [or clone] template repositories in the `~/.klipp` directory
* `klipp template spec <template-name>` - creates a new template specificiation called `<template-name>.klippspec`, for you to configure your template's properties.
* `klipp template push <repo-name>` - push a new template to one of your template repositories.
* `klipp template list [<repo-name>]` - list all available templates on your machine [per repository]
* `klipp prepare <template-name>` - prepare the creation of a new template, by authoring a `Klippfile`
* `klipp create [<template-name>]` - create files based on the prepared `Klippfile` [or interactively from the terminal].

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
