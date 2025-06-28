#!/usr/bin/env bash

npx repomix -i "AGENTS.md,GEMINI.md" -o llms.txt .

make build && make dist && make install
