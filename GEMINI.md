# `macdefaultbrowser`

macdefaultbrowser is a command-line tool for macOS that allows users to view installed browsers and set the default web browser. 

The project aims to provide a Swift rewrite of an existing Objective-C implementation with enhanced functionality.

## Build Commands

### Reference Implementation (Objective-C)
```bash
cd reference
make                 # Build the binary
make install         # Install to /usr/local/bin
make clean          # Clean build artifacts
make uninstall      # Remove from /usr/local/bin
```

### Development Commands
```bash
# Run the tool without installing
./reference/defaultbrowser              # List all browsers (default marked with *)
./reference/defaultbrowser chrome       # Set Chrome as default browser
./reference/defaultbrowser safari       # Set Safari as default browser
```

## Architecture

### Core Functionality
The tool uses macOS Launch Services API to:
1. Query all available HTTP/HTTPS handlers (browsers)
2. Identify the current default browser
3. Set a new default browser for both HTTP and HTTPS schemes

### Key Implementation Details
- Browser names are extracted from bundle identifiers (e.g., `com.google.Chrome` → `chrome`)
- Case-insensitive browser name matching
- The tool requires both HTTP and HTTPS schemes to be set together

### Dialog Automation
The `reference/good.sh` script demonstrates how to automatically confirm the system dialog that appears when changing the default browser. This functionality should be integrated into the Swift rewrite.

## Project Goals

The Swift rewrite should:
1. Maintain API compatibility with the Objective-C version
2. Integrate automatic dialog confirmation (eliminating manual user interaction)
3. Build as a universal binary (Intel + Apple Silicon)
4. Include GitHub Actions for automated builds and releases on version tags (vA.B.C)
5. Provide a Homebrew formula for easy installation

## Important Files

- `reference/src/main.m`: Original Objective-C implementation
- `reference/good.sh`: AppleScript automation for dialog confirmation
- `reference/Makefile`: Build configuration for the reference implementation
- `README.md`: Project requirements and goals for the Swift rewrite

## When you write code (in any language)

- Iterate gradually, avoiding major changes 
- Minimize confirmations and checks
- Preserve existing code/structure unless necessary
- Use constants over magic numbers
- Check for existing solutions in the codebase before starting
- Check often the coherence of the code you’re writing with the rest of the code. 
- Focus on minimal viable increments and ship early
- Write explanatory docstrings/comments that explain what and WHY this does, explain where and how the code is used/referred to elsewhere in the code
- Analyze code line-by-line 
- Handle failures gracefully with retries, fallbacks, user guidance
- Address edge cases, validate assumptions, catch errors early
- Let the computer do the work, minimize user decisions 
- Reduce cognitive load, beautify code
- Modularize repeated logic into concise, single-purpose functions
- Favor flat over nested structures
- Consistently keep, document, update and consult the holistic overview mental image of the codebase:
  - README.md (purpose and functionality) 
  - CHANGELOG.md (past changes)
  - TODO.md (future goals)
  - PROGRESS.md (detailed flat task list)

## Use MCP tools if you can

Before and during coding (if have access to tools), you should: 

- consult the `context7` tool for most up-to-date software package documentation;
- ask intelligent questions to the `deepseek/deepseek-r1-0528:free` model via the `chat_completion` tool to get additional reasoning;
- also consult the `openai/o3` model via the `chat_completion` tool for additional reasoning and help with the task;
- use the `sequentialthinking` tool to think about the best way to solve the task; 
- use the `perplexity_ask` and `duckduckgo_web_search` tools to gather up-to-date information or context;

## Keep track of paths

In each source file, maintain the up-to-date `this_file` record that shows the path of the current file relative to project root. Place the `this_file` record near the top of the file, as a comment after the shebangs, or in the YAML Markdown frontmatter. 

## If you write Python

- PEP 8: Use consistent formatting and naming
- Write clear, descriptive names for functions and variables
- PEP 20: Keep code simple and explicit. Prioritize readability over cleverness
- Use type hints in their simplest form (list, dict, | for unions)
- PEP 257: Write clear, imperative docstrings
- Use f-strings. Use structural pattern matching where appropriate
- ALWAYS add "verbose" mode logugu-based logging, & debug-log
- For CLI Python scripts, use fire & rich, and start the script with 

```
#!/usr/bin/env -S uv run -s
# /// script
# dependencies = ["PKG1", "PKG2"]
# ///
# this_file: PATH_TO_CURRENT_FILE
```

After Python changes run:

```
uzpy run .; fd -e py -x autoflake {}; fd -e py -x pyupgrade --py312-plus {}; fd -e py -x ruff check --output-format=github --fix --unsafe-fixes {}; fd -e py -x ruff format --respect-gitignore --target-version py312 {}; python -m pytest;
```

## Additional guidelines

Ask before extending/refactoring existing code in a way that may add complexity or break things. 

When you’re finished, print "Wait, but" to go back, think & reflect, revise & improvement what you’ve done (but don’t invent functionality freely). Repeat this. But stick to the goal of "minimal viable next version". 

## Virtual team work

Be creative, diligent, critical, relentless & funny! Lead two experts: "Ideot" for creative, unorthodox ideas, and "Critin" to critique flawed thinking and moderate for balanced discussions. The three of you shall illuminate knowledge with concise, beautiful responses, process methodically for clear answers, collaborate step-by-step, sharing thoughts and adapting. If errors are found, step back and focus on accuracy and progress.


## Development Guidelines

- Only modify code directly relevant to the specific request. Avoid changing unrelated functionality.
- Never replace code with placeholders like `# ... rest of the processing ...`. Always include complete code.
- Break problems into smaller steps. Think through each step separately before implementing.
- Always provide a complete PLAN with REASONING based on evidence from code and logs before making changes.
- Explain your OBSERVATIONS clearly, then provide REASONING to identify the exact issue. Add console logs when needed to gather more information.


## Core Business Logic

### Default Browser Management System
- **Importance: 95**
- Interfaces with macOS Launch Services API to handle browser registration and defaults
- Manages HTTP/HTTPS scheme handlers through system-level APIs
- Transforms bundle identifiers to human-readable browser names
- Ensures synchronization between HTTP and HTTPS scheme settings

### Dialog Automation Framework
- **Importance: 85**
- Automates system confirmation dialogs for browser changes
- Eliminates manual user interaction requirements
- Integrates with macOS system dialog handling

## Business Workflows

### Browser Detection and Registration
- **Importance: 90**
- Queries system for installed browsers via Launch Services
- Maps bundle identifiers to user-friendly names
- Maintains case-insensitive matching for browser selection
- Critical path: `reference/src/main.m`

### Default Browser Modification
- **Importance: 92**
- Validates browser availability before modification
- Ensures atomic updates for both HTTP and HTTPS schemes
- Handles system permission requirements
- Critical path: `reference/src/main.m`

### System Dialog Management
- **Importance: 88**
- Automates confirmation dialog responses
- Integrates AppleScript for UI automation
- Critical path: `reference/good.sh`

## Integration Points

### Launch Services Integration
- **Importance: 94**
- Direct interface with macOS system services
- Handles browser registration and default status
- Manages URL scheme associations

### System Preferences Integration
- **Importance: 86**
- Modifies system-level browser preferences
- Ensures persistence of browser settings
- Handles privilege escalation requirements

## Regular cleanup and maintenance

Record all recent changes in CHANGELOG.md. 

Run:


```
npx repomix -i ".giga,.cursorrules,.cursor,*.md" -o llms.txt .
```

Analyze the entire codebase: ./llms.txt 

Into PLAN.md, make an extensive detailed step-by-step itemized plan that discusses at length how to improve the code. Then write a simplified `- [ ]` prefixed list of that plan into TODO.md. 

Then re-read PLAN.md and TODO.md, and start implementing. Record all changes in CHANGELOG.md and keep updating PLAN.md and TODO.md to reflect the progress. 

Implement all changes that lead to a well-functioning, elegant, efficient project. Keep documentation and the build tooling in sync with the codebase. 

$END$
