# Xcode Version Manager (xcvm)

Manage multiple installations of Xcode with a simple command line tool. All commands have completions for bash, fish, and zsh shells.


## Installation

### Homebrew
```shell
brew install craigsiemens/tap/xcode-version-manager
```

### Manually
Clone the repo then build the binary.
```shell
make build
```
The binary will be available at `.build/release/xcvm`.

Shell completions can be generated as well.
```shell
make completions
```
They will be available in `.build/completions` for you to copy to the specific location required by your shell.


## Usage

### Download

Pass a specific version or `latest` to download Xcode. It will open the download url in your browser to use your existing Apple ID authentication.

```shell
xcvm download latest
# or
xcvm download 15.4
```


### Install

Pass the path to the downloaded xip file or in the progress download file for your browser (`*.download` or `*.crdownload`). The Xcode app will be renamed based on the version to allow multiple versions to be installed at the same time.

```shell
xcvm install ~/Downloads/Xcode-15.xip
# or
xcvm install ~/Downloads/Xcode-15.xip.download
```

### Use

Pass the version number of Xcode to use for the command line developer tools.

```shell
xcvm use 15.4
``` 

Since this command calls `xcode-select`, which requires super user permissions, you may need to call it with `sudo` or by passing the `--sudo-askpass` flag. See `xcvm use --help` for more details.

### Uninstall

Pass a version number to uninstall a version of Xcode.

```shell
xcvm uninstall 15.0
```

This is faster than moving Xcode the Trash since it doesn't spend time counting the files to show a progress bar when emptying the Trash. 


## `xcvm help`
```
OVERVIEW: Manage multiple installed versions of Xcode.

USAGE: xcvm <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  list (default)          Lists the installed versions of Xcode.
  download                Open the browser to download a version of Xcode.
  install                 Installs a version of Xcode from a downloaded xip
                          file.
  uninstall               Uninstalls a version of Xcode.
  use                     Changes the version of Xcode being used.

  See 'xcvm help <subcommand>' for detailed help.
```
