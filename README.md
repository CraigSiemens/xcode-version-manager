# xcode-version-manager

A command line tool to manage multiple installations of Xcode. 

## Installation

```
brew install craigsiemens/tap/xcode-version-manager
```

## Usage

`xcvm -h` - Show the available subcommands.

`xcvm list` - Shows the installed versions of Xcode and the currently used one.

`xcvm install` - Installs Xcode from a passed in xip file. Names the Xcode app with the version number so multiple versions can be installed side by side.

`xcvm use {VERSION_NUMBER}` - Switches the current version of Xcode being used to one that matches the version number.
