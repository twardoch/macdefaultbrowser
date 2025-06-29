# macdefaultbrowser & macdefaultbrowsy

**Manage your macOS default web browser with ease from the command line.**

`macdefaultbrowser` (written in Swift) and its Python counterpart `macdefaultbrowsy` are powerful command-line tools for macOS. They allow you to effortlessly view your installed web browsers, check the current default, and set a new default browser—all with simple commands and automatic system dialog confirmation.

This project provides two implementations:
*   **`macdefaultbrowser`**: A native Swift application, compiled to a universal binary for maximum performance and minimal dependencies on Intel and Apple Silicon Macs.
*   **`macdefaultbrowsy`**: A Python port offering similar functionality, ideal for users within the Python ecosystem or those who prefer Python-based tools.

## Who is this for?

These tools are perfect for:

*   **macOS users** who prefer managing their system via the command line.
*   **Developers and Power Users** needing to quickly switch between different browsers for testing or workflow purposes.
*   **System Administrators** looking to script or automate default browser settings on multiple machines.
*   Anyone who appreciates a **fast, non-intrusive way** to change their default browser without navigating through system settings.

## Why is it useful?

*   **Speed & Efficiency:** List browsers and set a new default in seconds.
*   **Automation-Friendly:** Easily integrate into scripts for automated setups or testing routines.
*   **Seamless Experience:** Automatically confirms the macOS system dialog that usually requires manual clicking when changing the default browser.
*   **Native Performance (Swift):** `macdefaultbrowser` is a compiled universal binary.
*   **Python Ecosystem Integration (Python):** `macdefaultbrowsy` is easy to integrate into Python workflows.
*   **Lightweight:** Minimal footprint and dependencies for both versions.

## Installation

### `macdefaultbrowser` (Swift)

#### Homebrew
The Homebrew formula is available in this repository (`macdefaultbrowser.rb`).
While a dedicated tap is not yet set up, you can install it directly:
```bash
# Ensure you have Homebrew installed
# To install/update the formula directly from the main branch:
brew install https://raw.githubusercontent.com/twardoch/macdefaultbrowser/main/macdefaultbrowser.rb --build-from-source
# Or, clone the repo and then:
# brew install --build-from-source macdefaultbrowser.rb
```
*Future (once tap is established):*
```bash
# brew tap twardoch/tap  (Example tap name)
# brew install macdefaultbrowser
```

#### Manual Installation (from source)

1.  Ensure you have Xcode Command Line Tools installed.
    *   If not, run: `xcode-select --install`
2.  Clone the repository:
    ```bash
    git clone https://github.com/twardoch/macdefaultbrowser.git
    cd macdefaultbrowser
    ```
3.  Build and install:
    ```bash
    make install
    ```
    This will compile the Swift project (located in the `macdefaultbrowser/` subdirectory) and install the `macdefaultbrowser` binary to `/usr/local/bin`.

### `macdefaultbrowsy` (Python)

1.  Ensure you have Python 3.8 or newer installed. `uv` is recommended for environment and package management.
2.  Navigate to the Python project directory:
    ```bash
    # If you cloned the main project:
    cd macdefaultbrowser/macdefaultbrowsy
    ```
3.  Install using pip (it's highly recommended to use a virtual environment):
    ```bash
    # Create and activate a virtual environment (e.g., using uv)
    uv venv
    source .venv/bin/activate

    # Install in editable mode
    uv pip install -e .
    ```
    If not using `uv`:
    ```bash
    # python -m venv .venv
    # source .venv/bin/activate
    # pip install -e .
    ```

## Usage

Both tools follow a similar command structure. The browser name is typically the lowercase version of the application name (e.g., `chrome`, `safari`, `firefoxdeveloperedition`, `arc`).

### List Available Browsers

To see all installed web browsers and identify the current default (marked with `*`):

**Swift:**
```bash
macdefaultbrowser
```

**Python:**
```bash
macdefaultbrowsy
```
or from within the activated virtual environment in the `macdefaultbrowsy` directory:
```bash
python -m macdefaultbrowsy
```

**Example Output:**
```
  arc
  brave
  chrome
  firefox
* safari
  edge
  opera
```

### Set Default Browser

To set a new default web browser (e.g., Chrome):

**Swift:**
```bash
macdefaultbrowser chrome
```

**Python:**
```bash
macdefaultbrowsy chrome
```
or
```bash
python -m macdefaultbrowsy chrome
```

The tool will set "Chrome" as your default browser and automatically confirm the system dialog that appears.

### Getting Help & Version

**Swift (`macdefaultbrowser`):**
*   For usage instructions: `macdefaultbrowser --help`
*   To check the version: `macdefaultbrowser --version`

**Python (`macdefaultbrowsy`):**
The `fire` library automatically provides help.
*   For usage instructions: `macdefaultbrowsy -- --help` or `python -m macdefaultbrowsy -- --help`
*   Version information is determined at build time from git tags via `hatch-vcs`. After installation, you can typically find it with package inspection tools or by checking the `macdefaultbrowsy/__version__.py` file (if generated and included in the wheel).

## Technical Details

### How `macdefaultbrowser` (Swift) Works

The Swift version (`macdefaultbrowser`) is designed for performance and deep integration with macOS.

*   **Core Technology:** Built entirely in Swift, leveraging modern language features.
*   **macOS Launch Services:**
    *   Uses the `LaunchServices` framework to query all installed applications capable of handling HTTP/HTTPS URL schemes.
    *   Retrieves the bundle identifier of the current default browser.
    *   Sets a new default browser by updating the Launch Services database for both HTTP and HTTPS schemes.
*   **Dialog Automation:**
    *   When a new default browser is set, macOS typically presents a confirmation dialog. `macdefaultbrowser` automates clicking the "Use as Default" (or similarly named) button in this dialog.
    *   This is achieved by running an embedded AppleScript in a separate thread that targets the `CoreServicesUIAgent` process responsible for the dialog. The script waits for the dialog and button to appear, then programmatically clicks it.
*   **Code Structure (located in `macdefaultbrowser/` subdirectory):**
    *   `main.swift`: Entry point for the command-line tool, handles argument parsing (using `swift-argument-parser`) and orchestrates operations.
    *   `BrowserManager.swift`: Contains the primary logic for listing browsers and setting the default. It interfaces with `LaunchServicesWrapper` and `DialogAutomation`.
    *   `LaunchServicesWrapper.swift`: A Swift-friendly wrapper around the macOS Launch Services C APIs. It includes logic to handle API deprecations by using modern `NSWorkspace` APIs on newer macOS versions (12.0+) and falling back to older Launch Services functions for backward compatibility (macOS 10.15+).
    *   `DialogAutomation.swift`: Manages the AppleScript execution for automatic dialog confirmation. It runs the script in a detached asynchronous task.
    *   `Version.swift`: This file is dynamically generated at build time (from `Version.swift.template`) by the `Makefile` to embed version information (derived from git tags) directly into the binary. This version is accessible via the `--version` flag.
*   **Universal Binary:** Compiled as a universal binary, ensuring native performance on both Intel and Apple Silicon Macs.
*   **Command-Line Interface:** Uses the `swift-argument-parser` library to provide a robust and user-friendly CLI experience, including automatic help text generation (`--help`).

### How `macdefaultbrowsy` (Python) Works

The Python version (`macdefaultbrowsy`) offers similar functionality with a focus on ease of development and Python ecosystem integration.

*   **Core Technology:** Written in Python 3 (3.8+).
*   **macOS Launch Services via PyObjC:**
    *   Utilizes the `pyobjc-framework-CoreServices` library, which provides Python bindings to the native macOS Launch Services C APIs. This allows `macdefaultbrowsy` to perform the same underlying operations as the Swift version:
        *   Querying all registered handlers for HTTP/HTTPS URL schemes.
        *   Identifying the current default handler.
        *   Setting a new default handler for both HTTP and HTTPS schemes.
*   **Dialog Automation:**
    *   Similar to the Swift version, `macdefaultbrowsy` automates the system confirmation dialog.
    *   It executes an AppleScript via a subprocess (`osascript`). The script runs in a background thread, polling for the dialog and clicking the confirmation button once it appears. The AppleScript logic is designed to be robust, retrying several times and identifying the correct button.
*   **Code Structure (located in `macdefaultbrowser/macdefaultbrowsy/macdefaultbrowsy/` subdirectory):**
    *   `__main__.py`: Entry point for the command-line tool when invoked (e.g., `python -m macdefaultbrowsy` or via the installed `macdefaultbrowsy` script). It uses the `fire` library to expose functionality.
    *   `macdefaultbrowsy.py`: Contains the core logic:
        *   `list_browsers()`: Lists available browsers.
        *   `read_default_browser()`: Gets the current default browser.
        *   `set_default_browser(browser_id)`: Sets the specified browser as default, including orchestrating the dialog automation.
    *   `launch_services.py`: A wrapper around `pyobjc-framework-CoreServices` functions, providing an interface to the Launch Services API.
    *   `dialog_automation.py`: Manages the execution of the AppleScript for dialog confirmation. It starts the AppleScript in a separate thread and the main process waits for this thread to complete.
*   **Command-Line Interface:** Uses the `fire` library to automatically generate a command-line interface from the Python functions.
*   **Versioning & Packaging:** Uses `hatch` with `hatch-vcs` (configured in `macdefaultbrowser/macdefaultbrowsy/pyproject.toml`) to dynamically determine the version from git tags at build time. The version is intended to be available via `macdefaultbrowsy/__version__.py`.

### Build Process

Both projects use a root `Makefile` for common development tasks.

*   **Swift (`macdefaultbrowser`):**
    *   Located in the `macdefaultbrowser/` subdirectory.
    *   `make build`: Compiles the Swift source code into a universal binary located in `macdefaultbrowser/build/`.
    *   `make install`: Builds and installs the binary to `/usr/local/bin`.
    *   `make test`: Runs unit tests.
    *   `make dist`: Creates distributable `.pkg` and `.dmg` installers.
    *   `make sign`: Signs the binary (requires `CODESIGN_IDENTITY` to be set).
    *   `make notarize`: Notarizes the signed binary/package (requires Apple ID credentials).
    *   The build process also dynamically generates `macdefaultbrowser/Sources/macdefaultbrowser/Version.swift` from git tags.
*   **Python (`macdefaultbrowsy`):**
    *   Located in the `macdefaultbrowser/macdefaultbrowsy/` subdirectory.
    *   Uses `hatch` as the build backend, configured in `pyproject.toml`.
    *   `make py-install`: Installs the Python package in editable mode (e.g., `uv pip install -e .`).
    *   `make py-test`: Runs Python unit tests (using `pytest`).
    *   `make py-run`: A convenience target to run the installed Python script (may require virtual environment activation).

### Coding and Contribution Guidelines

This project follows several key principles (largely detailed in `AGENTS.md` and `CLAUDE.md`):

*   **Iterative Development:** Changes are made gradually, focusing on minimal viable increments.
*   **Clarity and Readability:** Code should be simple, explicit, and well-documented with comments explaining the "what" and "why."
*   **Error Handling:** Failures should be handled gracefully.
*   **Modularity:** Repeated logic is modularized into concise, single-purpose functions.
*   **Documentation:**
    *   `README.md` (this file) provides purpose and functionality.
    *   `CHANGELOG.md` tracks notable changes.
    *   `TODO.md` outlines future goals and tasks.
*   **Code Snapshots:** `npx repomix -o llms.txt .` is used to generate a complete snapshot of the codebase for analysis or sharing.
*   **Python Specifics:** Adherence to PEP 8, use of type hints, f-strings, and `loguru` for logging. `ruff` is used for linting and formatting.
*   **Swift Specifics:** Modern Swift practices, use of `swift-argument-parser` for CLI.

For more detailed guidelines, please refer to the `AGENTS.md` or `CLAUDE.md` files in the repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
