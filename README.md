
# macdefaultbrowser

A command-line tool (written in Swift)for macOS that allows you to view installed browsers and set the default web browser, with automatic dialog confirmation.

## Features

- List all installed web browsers with the current default marked with `*`
- Set any browser as the default with a simple command
- Automatically confirms the system dialog (no manual clicking required)
- Built as a universal binary (Intel + Apple Silicon)
- Simple installation via Homebrew or manual install

## Installation

### Homebrew (coming soon)

```bash
brew install macdefaultbrowser
```

### Manual Installation

```bash
git clone https://github.com/twardoch/macdefaultbrowser.git
cd macdefaultbrowser
make install
```

This will build and install the binary to `/usr/local/bin`.

## Usage

### List all browsers

```bash
macdefaultbrowser
```

Output example:
```
  chrome
  firefox
* safari
  edge
```

### Set default browser

```bash
macdefaultbrowser chrome
```

The tool will automatically set Chrome as your default browser and confirm the system dialog.

## Building from Source

### Requirements

- macOS 10.15 or later
- Xcode 13.0 or later
- Swift 5.7 or later

### Build

```bash
make build
```

### Run tests

```bash
make test
```

### Clean

```bash
make clean
```

### Uninstall

```bash
make uninstall
```

## How it Works

The tool uses the macOS Launch Services API to:
1. Query all installed applications that can handle HTTP/HTTPS URLs
2. Get the current default browser
3. Set a new default browser for both HTTP and HTTPS schemes

When setting a new default browser, the tool also uses AppleScript automation to automatically click the confirmation button in the system dialog, providing a seamless experience.

## Development

To capture a snapshot of the codebase:

```bash
npx repomix -i ".giga,.cursorrules,.cursor,*.md" -o llms.txt .
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## References

- Check [macdefaultbrowsy](https://github.com/twardoch/macdefaultbrowsy) for a similar tool and package written in Python.