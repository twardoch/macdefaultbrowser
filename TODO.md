# TODO: macdefaultbrowser

### 1. Project Restructuring

- [x] Create `macdefaultbrowser` folder in the project root.
- [x] Move all Swift project files and folders into `macdefaultbrowser`:
    - `Sources/`
    - `Tests/`
    - `Package.swift`
- [x] Update `Makefile` and any other build scripts to reflect the new paths.
- [x] Verify that the Swift project still builds and runs correctly from its new location.

### 2. Python Port (`macdefaultbrowsy`)

- [x] Create `macdefaultbrowsy` folder in the project root.
- [x] Create `macdefaultbrowsy/pyproject.toml` with basic package metadata and dependencies (like `pyobjc-framework-CoreServices`, `typer`, `rich`).
- [x] Create the Python package structure inside `macdefaultbrowsy`:
    - `macdefaultbrowsy/`
        - `macdefaultbrowsy/`
            - `__init__.py`
            - `main.py` (CLI entry point)
            - `browser_manager.py` (equivalent to `BrowserManager.swift`)
            - `launch_services.py` (equivalent to `LaunchServicesWrapper.swift`)
            - `dialog_automation.py` (equivalent to the AppleScript logic)
        - `tests/`
            - `test_browser_manager.py`
- [x] Implement the core logic in `macdefaultbrowsy/launch_services.py` to get and set the default browser using `pyobjc`.
- [x] Implement `macdefaultbrowsy/browser_manager.py` to handle browser name extraction and listing.
- [x] Implement the command-line interface in `macdefaultbrowsy/main.py`.
- [x] Implement `macdefaultbrowsy/dialog_automation.py`.
- [x] Write unit tests in `tests/test_browser_manager.py`.
- [x] Add a `README.md` to the `macdefaultbrowsy` folder with installation and usage instructions.
- [x] Update the main `Makefile` to include targets for running the Python version.
- [x] Port CLI from `Typer` to `fire`.
