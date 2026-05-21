# Reverse-Engineering Workflow

BoltForge favors specification-driven implementation.

## Roles

- Research work may inspect public docs, original behavior, PCSX2 traces,
  Ghidra analysis, and local Wrench comparison output.
- Implementation work should consume behavior specs, schemas, tests, and trace
  summaries rather than copied decompiled code.

## Research Artifacts

Use docs, schemas, or tests to record durable findings:

- file offsets, field names, and confidence levels,
- state-machine sketches,
- object class notes,
- frame or input trace summaries,
- expected parser and runtime behavior,
- screenshots or captures only as local-only references unless legally safe.

## Ghidra Projects

Keep Ghidra databases out of Git. Commit templates, loader notes, symbol schema
ideas, and analysis procedures only when they do not contain proprietary code or
assets.
