# `macdefaultbrowser`

## Regular cleanup and maintenance

Record all recent changes in CHANGELOG.md. 

Run:


```
npx repomix -i ".giga,.cursorrules,.cursor,*.md" -o llms.txt .
```

Analyze the entire codebase: ./llms.txt 

Into TODO.md, make an extensive `- [ ]` prefixed detailed step-by-step itemized plan that discusses at length how to improve the code. 

Then re-read TODO.md, and start implementing. Record all changes in CHANGELOG.md and keep updating TODO.md to reflect the progress. 

Implement all changes that lead to a well-functioning, elegant, efficient project. Keep documentation and the build tooling in sync with the codebase. 