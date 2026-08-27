---
name: good-scoped-agent
description: Fixture - a schema-valid read-only agent whose one shell grant is parameterised; expected to pass check C2.
tools: Read, Grep, Glob, Bash(git ls-files:*)
disallowedTools: Write, Edit
maxTurns: 4
model: inherit
---

# Good scoped agent (fixture)

Fixture only. Not a shipped component; it exists so a reviewer can confirm what check C2 accepts.
