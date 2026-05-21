# AGENTS.md

## Project Snapshot

BoltForge is a native PC tooling and runtime project for the PlayStation 2
Ratchet & Clank games. The current project strategy is documented in
`docs/ratchet_clank_pc_port_plan.md`.

Use this file as the first pass for agent work. Read the full plan, or the
relevant sections of it, before making changes that affect project scope,
architecture, legal boundaries, importer behavior, runtime behavior, or
reverse-engineering workflow.

## Non-Negotiable Boundaries

- Do not add, generate, commit, or request copyrighted game data, including
  ISOs, disc images, extracted assets, textures, models, audio, videos, fonts,
  original binaries, or proprietary SDK files.
- Keep user-owned game data local and opt-in. Tests committed to the repository
  must use synthetic, homebrew-like, or minimal generated fixtures.
- Do not use leaked Sony SDK material, confidential headers, proprietary
  symbols, or copied proprietary source.
- Prefer clean-room behavior descriptions, schemas, tests, and traces over
  copied decompiled code.
- Do not turn the project into a PS2 emulator or a modified PCSX2 wrapper. The
  target is a native PC runtime and tooling pipeline.
- Treat Wrench as GPL-3.0 licensed. Do not copy or link Wrench code unless the
  project license decision explicitly allows it. Invoking it as a separate
  local comparison tool is different from incorporating its code.

## Architecture Defaults

- Prioritize tools first: disc inspector, importer, WAD tools, asset browser,
  and level viewer before broad gameplay runtime work.
- Target one R&C1 build first unless a task explicitly says otherwise.
- Preserve provenance for imported data: source ISO hash, sector, byte offset,
  raw size, decoded size, parser version, and conversion status.
- Keep three data layers when designing import code: raw provenance, decoded
  original-like assets, and runtime-native assets.
- Reject unknown disc images by default. Add explicit override paths only for
  local research workflows.
- Make unknown fields visible in manifests and tools instead of silently
  discarding them.
- Favor deterministic parser tests, fuzz targets, and golden synthetic fixtures.
  Real ISO comparisons must be local-only and excluded from Git.

## Expected Workflow

1. Check `git status --short` before editing and preserve unrelated user
   changes.
2. Read `docs/ratchet_clank_pc_port_plan.md` sections relevant to the task.
3. For source selection and recommended tools, read
   `docs/agent_tooling_recommendations.md` and the repo-local skill reference at
   `.codex/skills/boltforge-rac-port/references/source-map.md`.
4. Keep changes narrow and document new assumptions in `docs/` when they affect
   reverse-engineering, legal policy, data formats, or runtime architecture.
5. When adding dependencies, record the license and reason. Create or update
   `THIRD_PARTY.md` when dependency decisions become concrete.
6. When changing commands or the build system, update this file with the
   canonical build, test, format, and lint commands.

## Canonical Commands

Windows development starts from Developer PowerShell for Visual Studio 2026.

```powershell
.\scripts\verify_toolchain.ps1
.\scripts\check_repo_hygiene.ps1
cmake --preset windows-msvc-debug
cmake --build --preset windows-msvc-debug
ctest --preset windows-msvc-debug
```

Linux CI uses:

```bash
cmake --preset linux-gcc-debug
cmake --build --preset linux-gcc-debug
ctest --preset linux-gcc-debug
```

## Current Repository State

The repository has a C++20 CMake/vcpkg starter skeleton with a minimal
`ratchetpc --version` CLI and a smoke test. Follow
`docs/toolchain_setup.md` before building locally.

The project scaffold includes:

- `docs/` for legal boundaries, reverse-engineering workflow, file formats, and
  engine notes.
- `data/` for schemas, disc database metadata, and synthetic fixtures.
- `tools/` for importers, inspectors, trace tools, and viewers.
- `engine/` for native runtime systems.
- `launcher/` for user-facing import and launch workflows.
- `tests/` for unit, parser, integration, fuzz, golden, and replay tests.

## Repo-Local Skill

This repository includes a Codex skill at:

`.codex/skills/boltforge-rac-port/SKILL.md`

Use it for BoltForge-specific importer, asset-format, reverse-engineering,
runtime, test, documentation, and agent setup tasks.
