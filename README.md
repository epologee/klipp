# Klipp [![Build Status](https://travis-ci.org/epologee/klipp.png)](https://travis-ci.org/epologee/klipp) [![Coverage Status](https://coveralls.io/repos/epologee/klipp/badge.png)](https://coveralls.io/r/epologee/klipp)
## Code templates for the rest of us.


Klipp is a Ruby gem that you can use to replicate folder structures, while doing extensive search-and-replace operations on filenames, directory names and file contents.

I developed Klipp as an alternative to the templating system of Apple's Xcode, to use while developing iOS projects. However, there are no Apple or Xcode specific features in Klipp, so you can use it for pretty much any textfile-and-directory-based template.

I've borrowed some of the terminology of Klipp from the RubyGem and CocoaPods community, which is why you see things like this:

+ `.klippspec` files defining the structure of a template (compare to `.gemspec` and `.podspec`)
+ `Klippfile` files used to setup a new project from an existing template (compare to `Gemfile` and `Podfile`)
+ The `~/.klipp` folder containing your templates (compare to `~/.cocoapods`)

## Templates a.k.a. Specs

When you execute `klipp` the first time, it will create a `.klipp` folder in your home directory, where it will search for template directories. Each template has one `.klippspec` file. Upon first use however, you will not have any specs. For starters you might try my personal specs by executing:

    git clone https://github.com/epologee/klipp-specs.git ~/.klipp/epologee
    
After that, you can call `klipp template list` to see the specs it includes.

## Usage

You use klipp from the terminal, as a command line tool. For example, if you have a template setup in the `~/.klipp/` folder called `iPhoneProject`, you can call commands like:

+ `klipp template list` to list your templates
+ `klipp create iPhoneProject` interactively prompts you to enter the values required for the template. This works well with very small templates, like creating a new class.
+ `klipp prepare iPhoneProject` to create a new `Klippfile` for the `iPhoneProject` template. You edit the Klippfiles by hand to supply it with strings, numbers and booleans. This is easier for templates with more required values.
+ `klipp create` to create a new project from a `Klippfile`, relative to your current directory.
+ `klipp create -f` to re-create the project, overwriting the existing one.

You can always just start by running `klipp` and have the terminal tell you what commands to add to get your desired result.

## Contribute

The gem in its current state is very usable. It's got decent rspec coverage (96%+) and I personally use the publicly available gem build for all my templating needs. There are however areas in which I would love the project to evolve more:

+ Better terminal output during the creation process.
+ The ability to update an existing `Klippfile` when the corresponding `project.klippspec` is updated underneath.
+ Better feedback when something is missing, like token values or terminal commands.
+ A setup to share your templates, like the specs from CocoaPods and RubyGems projects.
