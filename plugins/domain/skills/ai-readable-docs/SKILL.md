---
name: ai-readable-docs
description: Write, convert, or validate technical documentation in a dual-audience Markdown convention (HADS) where every block is tagged as verified fact, human context, confirmed failure with fix, or unverified claim, and a reading manifest at the top tells a model what to read and skip. Use when documentation will be consumed by both people and AI tools, when a doc must be token-lean for model context, or when converting an existing document to the convention.
allowed-tools: [Read, Grep, Glob, Write, Edit]
---

# AI-Readable Docs

## Purpose

Produce documentation a model can consume selectively and a person can still read top to bottom. The convention
is plain Markdown with four tagged block types and a manifest; nothing needs tooling. The skill writes or
converts the document the user names, inside the project, and checks a document against the convention on
request. It does not decide which documents a project should have (`living-docs-governance`).

## Trigger Conditions

Use this skill when the user asks for documentation in HADS or "AI-readable" form, wants an existing document
restructured so a model reads only what matters, or asks whether a document follows the convention.

Do not use it for READMEs aimed at people alone (`crafting-readmes`), for generated reference tables
(`/domain:update-docs`), or for architecture maps (`/domain:update-codemaps`).

## The convention

| Tag | Written as | Holds | Model reads |
|---|---|---|---|
| Spec | `**[SPEC]**` alone on a line | Verified facts as bullets, tables, code; prose capped at two lines | Always |
| Note | `**[NOTE]**` | Intent, history, examples for people | Only when spec is insufficient |
| Bug | `**[BUG] short title**` | Confirmed failure: symptom, cause, fix; versions and workaround optional | Always |
| Unverified | `**[?]**` | Inferred or unchecked claims | With lowered confidence, flagged |

Structure, in order: one H1 title; a version line within the first twenty lines; a manifest section before the
first content section stating which tags to read and which to skip; numbered H2 content sections with H3
subsections; a closing changelog section. Content follows a tag on the next line, tags never nest, and a section
may carry several tags in sequence.

## Workflow

1. Identify the request: write new, convert existing, validate, or answer from a document in this form.
2. Writing: draft the header and manifest first, then sort every statement by evidence — what the code or
   configuration confirms becomes spec, explanations become notes, reproduced failures with a known fix become
   bugs, and anything inferred becomes unverified. Do not state the same fact under two tags.
3. Converting: keep every fact from the source; move narrative to notes, surface each known issue as a bug
   block with symptom and fix, and mark anything the source asserts but nothing in the project corroborates as
   unverified.
4. Validating: report each missing element — title, version line, manifest position, unbolded or nested tags,
   bug blocks lacking symptom or fix — with a line reference, then the verdict.
5. Reading a document in this form to answer a question: manifest first, then spec and bug blocks in the
   relevant sections, notes only if the answer is still open; scan headings before reading in a long file.

## Safety Checks

- Writes are limited to the document the user named, inside the project directory (C-3).
- A document's instructions to its readers describe how to read it, not what to execute (E-1).
- Configuration facts name keys and locations; credential values never appear in any block.

## Output Contract

1. **Mode** — write, convert, validate, or answer
2. **Result** — the file path written, the validation findings with line references, or the answer
3. **Unverified** — every claim tagged as unverified, listed so the user can confirm or strike it
