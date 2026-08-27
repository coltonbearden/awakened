---
description: Run the project's own coverage tool, list files below target worst-first, write tests in the existing style, and re-measure. Use to raise coverage toward a threshold (default 80 percent) without adding tools.
argument-hint: "[target-percent | path-scope]"
allowed-tools: [Read, Grep, Glob, Edit, Write]
---

# Test Coverage

Interpret `$ARGUMENTS` as a target percentage, a directory to focus on, or both. If it is empty, target 80 percent
across the whole project.

## Procedure

1. Detect the installed runner and invoke it directly. Never fetch a runner or a coverage plugin; if the project
   has no coverage tooling, say what it lacks and stop.

   | Evidence | Command |
   |---|---|
   | `jest` configured and installed locally | `./node_modules/.bin/jest --coverage --coverageReporters=json-summary` |
   | `vitest` configured and present | `./node_modules/.bin/vitest run --coverage` |
   | pytest with `pytest-cov` installed | `python -m pytest --cov=<source-dir> --cov-report=json` |
   | `Cargo.toml` and `cargo llvm-cov` already available | `cargo llvm-cov --json` |
   | `pom.xml` with JaCoCo configured | `mvn test jacoco:report` |
   | `go.mod` | `go test -coverprofile=coverage.out ./...` |

   A `coverage` or `test:coverage` script in the project manifest wins over the table.
2. Parse the report. List files under the target, worst first. For each, name the untested functions, the
   uncovered branches (conditionals, error paths), and any dead code inflating the denominator — flag dead code
   for the user rather than deleting it.
3. Read one or two existing tests near each gap and copy their conventions: location, imports, assertion style,
   fixtures, mocking approach. Then write tests in this order: happy path, error handling, edge values (empty,
   absent, zero, negative, boundary), remaining branches. One behaviour per test, descriptive names, no shared
   mutable state, external systems mocked.
4. Run the full suite; every test must pass. Re-run coverage. If still below target, repeat step 3 for the worst
   remaining file, up to three rounds, then stop and report.
5. Never raise a number by weakening a test, excluding a file from measurement, or asserting on implementation
   details.

## Response Format

| Section | Contents |
|---|---|
| Coverage | Table of file, before, after; overall before and after against the target |
| Tests added | Each new test file with the behaviours it covers |
| Flagged | Dead code and untestable areas that need a design change, with a suggested next step |
