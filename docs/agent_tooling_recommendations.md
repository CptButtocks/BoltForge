# Agent Tooling Recommendations

This repository is young, so agent performance depends on giving future agents
strong local context and safe validation paths.

## Already Added

- `AGENTS.md` gives root-level agent instructions.
- `.codex/skills/boltforge-rac-port/` gives a repo-local Codex skill.
- `.gitignore` blocks common local disc images, extracted assets, caches, and
  build outputs.
- CMake/vcpkg starter skeleton builds a minimal `ratchetpc --version` CLI and
  smoke test.
- GitHub Actions is configured for Windows MSVC and Linux GCC build/test jobs.

## Recommended Next Tools

- GitHub connector or MCP access for issues, pull requests, CI logs, and code
  review context once the project moves to GitHub-hosted collaboration.
- Pre-commit checks for large files and forbidden game-data extensions.
- CI on Windows and Linux with build, unit test, parser fixture, and formatting
  jobs.
- `ripgrep`, Git, CMake or Meson, Ninja, clang-format, clang-tidy, and a
  consistent compiler toolchain.
- Ghidra Emotion Engine: Reloaded for research notes:
  https://github.com/chaoticgd/ghidra-emotionengine-reloaded
- PCSX2 for local-only reference runs and trace capture from user-owned discs:
  https://pcsx2.net/ and https://github.com/PCSX2/pcsx2
- RenderDoc once native rendering exists: https://github.com/baldurk/renderdoc
- Tracy once runtime loops exist: https://github.com/wolfpld/tracy
- A local artifact directory outside Git for ISOs, extracted assets, import
  caches, traces, screenshots, and Wrench comparison outputs.

## Recommended Source Set

- Wrench documentation for file loading, WADs, gameplay data, renderers,
  textures, and sound. Check GPL implications before using code:
  https://github.com/chaoticgd/wrench
- RatchetModding resource lists for public tools and reverse-engineering leads:
  https://github.com/RatchetModding/rac-modding-resources
- OpenGOAL materials for process comparison, not direct architecture reuse:
  https://opengoal.dev/ and https://github.com/open-goal/jak-project
- ps2tek and ps2sdk for public PS2 architecture context:
  https://psi-rockin.github.io/ps2tek/ and https://github.com/ps2dev/ps2sdk
- Locally generated import reports, hashes, synthetic fixtures, traces, and
  visual captures as the project's own ground truth.

## Agent Context To Keep Fresh

- Keep `AGENTS.md` updated with canonical build, test, format, and lint commands
  as soon as they exist.
- Record dependency licenses in `THIRD_PARTY.md` before incorporating code.
- Keep public-source links and local research workflow notes in `docs/`.
- Prefer small schemas, manifests, and synthetic fixtures over prose-only
  discoveries when documenting file formats.
- Keep `docs/toolchain_setup.md`, `CMakePresets.json`, and CI in sync whenever
  build commands or required tools change.
