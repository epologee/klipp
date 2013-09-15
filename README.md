# Klipp [![Build Status](https://travis-ci.org/epologee/klipp.png)](https://travis-ci.org/epologee/klipp)
## Code templates for the rest of us.

Klipp is a command line gem for creating new programming projects from existing templates. It was originally designed to create Xcode projects. However, there are no Apple or Xcode specific features in Klipp, so you can use it for pretty much any textfile-and-directory-based template.

When compared to Xcode's plist-based templating system, Klipp takes an existing Xcode project and creates a new project by copying and modifying an existing template project by your own specifications.

## Installation

Install Klipp with RubyGems:

    $ gem install klipp

Execute and read the usage instructions:

    $ klipp

## Usage

    klipp template list
    klipp template init [NewTemplateName]
    klipp project init [TemplateName]
    klipp project make [-v]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
