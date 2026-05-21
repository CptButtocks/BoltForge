# BoltForge Source Map

Use this reference when selecting public sources, local tools, or validation
data for BoltForge tasks.

## Canonical Project Source

- `docs/ratchet_clank_pc_port_plan.md`: current project strategy, legal
  boundaries, architecture, milestones, risk register, and first backlog.

## Public Technical Sources

- Wrench: https://github.com/chaoticgd/wrench
  - Use for public documentation on R&C PS2 file loading, WADs, gameplay data,
    renderers, textures, and sound.
  - Use local Wrench output only as an opt-in comparison aid.
  - Do not copy or link Wrench code without an explicit GPL-compatible license
    decision.
- RatchetModding resources:
  https://github.com/RatchetModding/rac-modding-resources
  - Use as the first discovery map for public R&C modding and
    reverse-engineering tools.
- OpenGOAL: https://opengoal.dev/ and
  https://github.com/open-goal/jak-project
  - Use as a process and quality reference for a PS2-era native port.
  - Do not assume its engine architecture or code applies to R&C.
- ps2tek: https://psi-rockin.github.io/ps2tek/
  - Use for public PS2 architecture notes.
- ps2sdk: https://github.com/ps2dev/ps2sdk
  - Use for open-source PS2 development context, not as a substitute for R&C
    behavior.
- Clank: https://github.com/hashsploit/clank
  - Use only for future online/Medius research. Single-player comes first.

## High-Value Local Artifacts

- Known-good disc hash reports for user-owned images.
- Import reports with sector maps and `SYSTEM.CNF` output.
- Synthetic binary fixtures for parser tests.
- PCSX2 traces and screenshots generated locally from user-owned data.
- Wrench comparison manifests generated locally, if license boundaries remain
  clear.
- RenderDoc captures and Tracy traces from native tooling once the renderer and
  runtime exist.

## Tooling To Prefer

- `rg` for text search and `git` for history and diff inspection.
- Ghidra Emotion Engine: Reloaded for binary analysis notes:
  https://github.com/chaoticgd/ghidra-emotionengine-reloaded
- PCSX2 for local reference behavior and trace generation:
  https://pcsx2.net/ and https://github.com/PCSX2/pcsx2
- RenderDoc for graphics debugging once native rendering exists:
  https://github.com/baldurk/renderdoc
- Tracy for profiling once runtime loops exist:
  https://github.com/wolfpld/tracy
- Pre-commit or CI checks that block accidental game media, large binary blobs,
  and extracted copyrighted assets.
