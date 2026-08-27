---
name: codebase-design
description: Shared vocabulary and method for designing deep modules — much behaviour behind a small interface, placed at a real seam, tested through that interface. Use when designing or reshaping a module's interface, deciding where a seam belongs, finding shallow pass-through code worth merging, making code easier to test or navigate, or when another skill needs this vocabulary.
allowed-tools: [Read, Grep, Glob]
---

# Codebase Design

## Purpose

Give design conversations one precise language and a small set of tests for whether a structure earns its keep.
The skill produces recommendations and interface sketches in the conversation; it edits no code and records no
decision. Implementation belongs to the workflow plugin doing the work; the eventual decision record belongs to
`rinnegan`.

## Trigger Conditions

Use this skill when the user is shaping a new module, unhappy with a wide or leaky interface, choosing where an
abstraction should sit, or asking why code is hard to test or hard to find.

Do not use it to review a finished change for defects (`sharingan`), to define business terms
(`domain-modeling`), or to map an unfamiliar repository (`codebase-onboarding`).

## Vocabulary

Use these words exactly; substitutes blur the discussion.

| Term | Meaning | Say it instead of |
|---|---|---|
| Module | Anything with an interface and an implementation, at any scale | unit, component, service |
| Interface | All a caller must know: signature, invariants, ordering, error modes, setup, cost | API, signature |
| Implementation | The body behind the interface | — |
| Seam | The place where behaviour can be swapped without editing there; where an interface lives | boundary |
| Adapter | A concrete thing that satisfies an interface at a seam; names a role, not a size | — |
| Depth | Behaviour a caller gets per unit of interface learned | — |
| Leverage | The caller's gain from depth: one implementation repaid across many call sites and tests | — |
| Locality | The maintainer's gain from depth: change, bugs, and knowledge concentrate in one place | — |

A module is deep when a small interface hides a lot; shallow when the interface is nearly as wide as what sits
behind it. Depth is a property of the interface, so a deep module may still be built from small, swappable
internal parts with their own private seams.

## Method

1. Name the module and write its interface in full — types, invariants, ordering, failure modes, required
   setup, performance shape. If that list is long relative to the behaviour, the module is shallow.
2. Apply the deletion test: imagine the module gone. If complexity disappears, it was pass-through; if it
   reappears across several callers, it was earning depth.
3. Place the seam only where something varies. One adapter is a hypothetical seam; two (usually production and
   test) make it real. Classify each dependency to decide the testing shape: pure in-process logic merges
   freely; a dependency with a local stand-in is tested with the stand-in; a service you own gets a port with a
   production adapter and an in-memory one; a third-party service gets a port with a test double.
4. Check testability through the interface alone: dependencies are accepted rather than constructed inside,
   results are returned rather than applied as side effects, and tests describe behaviour, not internals. A test
   that must change when the implementation changes is reaching past the interface.
5. Design it twice, inline. Before recommending, sketch the interface at least three different ways in this
   session, each under a different pressure — fewest entry points, most flexibility, easiest common call, and
   ports-and-adapters when a dependency crosses a seam. Present them in turn, compare on depth, locality, and
   seam placement, and give a firm recommendation or a hybrid. No subagents are dispatched for this.
6. When shallow modules are merged, write new tests at the deepened interface and retire the old ones on the
   parts; layering both is waste.

## Safety Checks

- Read-only: the skill reads code and writes nothing (C-3).
- Do not adopt lines-of-implementation over lines-of-interface as a depth measure; it rewards padding.
- Language- and framework-specific idioms enter only when the user asks for them (P-2).

## Output Contract

1. **Module and interface** — the full interface as it stands, and the depth verdict
2. **Alternatives** — the sketches from step 5, compared
3. **Recommendation** — the chosen shape, seam placement, dependency strategy, and test surface
