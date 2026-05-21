# Legal Boundaries

This repository ships source code, schemas, tests, documentation, and tooling.
It must not ship copyrighted Ratchet & Clank game data.

## Allowed In Git

- Project-owned source code and documentation.
- Schemas and manifests that do not contain copyrighted game data.
- Synthetic fixtures created for parser and runtime tests.
- Public-source research notes with attribution and compatible licensing.

## Not Allowed In Git

- ISOs, disc images, executable game binaries, modules, or patches to original
  binaries.
- Extracted textures, models, collision, audio, movies, fonts, strings, save
  data, or asset packs from the original games.
- Sony SDK files, leaked headers, confidential symbols, or proprietary source.
- Decompiled proprietary code copied into project source.

## Local-Only Research

Developers may use legally obtained discs, PCSX2 traces, Wrench output, Ghidra
projects, screenshots, and captures locally. Keep those artifacts outside Git
under ignored locations such as `local_assets/`, `local_traces/`,
`local_captures/`, `.import-cache/`, or another private directory.

## Clean-Room Preference

Use reverse engineering to produce behavior descriptions, type sketches,
schemas, tests, and trace comparisons. Implement native systems from those
artifacts rather than copying decompiled code.
