
# `macdefaultbrowser`

Swift rewrite of `reference/src` incorporating the `reference/good.sh` script:

1. `macdefaultbrowser` by itself lists the potential browsers and marks the default browser with a `*`

2. `macdefaultbrowser` with a browser name argument sets that browser as the default and if the dialog appears, confirms it (like `good.sh`)

3. The Makefile builds the tool with `make`, and installs the tool into the executable path (probably `/usr/local/bin`) with `make install`

4. Homebrew formula is provided for easy installation

5. MIT-licensed

6. Is built as universal binary

7. Includes Github actions to build on macOS, and on a new git tag formed like `vA.B.C` makes a Github release, and upload the binary to the release

8. To capture a snapshot of the codebase, run:

```
repomix -i ".giga,.cursorrules,.cursor,*.md" -o llms.txt .
```

