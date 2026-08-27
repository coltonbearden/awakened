---
description: Run the project's own build or type-check and fix the errors one at a time with the smallest safe edit, re-running after each. Stops and asks before any dependency change. Use when a build is red.
argument-hint: "[build-command-or-scope]"
allowed-tools: [Read, Grep, Glob, Edit]
---

# Build Fix

Interpret `$ARGUMENTS` as either the exact build command to run or a scope to limit fixes to (a directory or
package). If it is empty, detect the build command from the table below and fix everything it reports.

## Procedure

1. Detect the build tool from files already present. Run only what the project itself declares or has installed —
   never fetch a tool, never add a package.

   | Evidence in the repository | Command to run |
   |---|---|
   | `package.json` with a `build` script | that script via the lockfile's package manager |
   | `tsconfig.json` and a locally installed TypeScript | `./node_modules/.bin/tsc --noEmit` |
   | `Cargo.toml` | `cargo build` |
   | `go.mod` | `go build ./...` |
   | `pom.xml` or `build.gradle` | `mvn -q compile` or `./gradlew compileJava` |
   | `pyproject.toml` with a type checker configured | that checker as configured, else `python -m compileall -q .` |

   If none apply, ask the user for the build command and stop.
2. Capture the output, group errors by file, and order them so that import and type-definition errors come before
   the errors that depend on them. Report the total so progress is visible.
3. For each error: read the surrounding lines, name the root cause, make the single smallest edit that resolves
   it, and re-run the build. Confirm the error is gone and no new error appeared before moving on.
4. Stop and ask the user, showing the evidence, when any of these occur:
   - a fix produces more errors than it removed;
   - the same error survives three attempts;
   - the fix would require restructuring modules, interfaces, or architecture;
   - the error is a missing or mismatched dependency. State which package and version the build wants and let the
     user decide how to add it — this command never runs a package installer.
5. Never disable a check, suppress an error with an ignore directive, or loosen a compiler option to make the
   build pass. Those are decisions for the user.

## Response Format

| Section | Contents |
|---|---|
| Fixed | Each error resolved, with file path and a one-line description of the edit |
| Remaining | Errors still present and why they were not fixed here |
| Introduced | New errors caused by the fixes — expected to be none |
| Next | Suggested action for anything remaining, including any dependency the user must add |
