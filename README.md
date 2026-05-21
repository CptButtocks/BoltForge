# BoltForge

Native PC tooling and runtime research for the PlayStation 2 Ratchet & Clank
games.

Start with:

- `AGENTS.md` for AI-agent and contributor operating rules.
- `CONTRIBUTING.md` for contribution boundaries and local checks.
- `docs/toolchain_setup.md` for local build toolchain setup.
- `docs/legal-boundaries.md` for project distribution limits.
- `docs/ratchet_clank_pc_port_plan.md` for the current project plan.
- `docs/agent_tooling_recommendations.md` for recommended tools and sources.

Initial local build commands:

```powershell
.\scripts\check_repo_hygiene.ps1
cmake --preset windows-msvc-debug
cmake --build --preset windows-msvc-debug
ctest --preset windows-msvc-debug
```

The repository scaffold includes documentation, schema, tool, engine, launcher,
test, and external-dependency areas. Real game data and local research outputs
must stay outside Git.

This repository must not contain game ISOs, extracted copyrighted assets,
original game binaries, or proprietary SDK material.
