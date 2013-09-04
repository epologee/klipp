# Klipp
## Xcode templates for the rest of us.

Klipp is a command line gem for creating new (Xcode) projects from existing templates. Unlike Apple's private plist-based templating system, Klipp takes an existing Xcode project and creates a new project by copying and modifying an existing template project by your own specifications.

## Installation

Install Klipp with RubyGems:

    $ gem install klipp

Execute and read the usage instructions:

    $ klipp

## Usage

Klipp creates a template repository in your home directory, at ~/.klipp/templates
A template consists of a directory and an accompanying Yaml file, e.g.:

    TemplateA
	TemplateA.yml

Once you have templates like these present, you can prepare a new instance of that project by executing:

    $ klipp prepare TemplateA

This will create a TemplateA.klippfile in your current directory, for you to edit with your favorite text editor.
From there, customize your project and when happy with the results, run:

    $ klipp create

This will create a new directory called TemplateA, that contains your new project.
	
## Known issues

* Creating templates is done manually, this will be automated
* Errors while parsing the .klippfile are not yet handled gracefully
* Highline support for on-the-fly creation of new projects is not yet enabled
* The root of newly created projects carries the same name as the template, this will be adjustable.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
