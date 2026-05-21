# Contributing

BoltForge is in early bootstrap. Keep changes small, documented, and aligned
with `AGENTS.md` and `docs/ratchet_clank_pc_port_plan.md`.

## Boundaries

- Do not commit game ISOs, extracted assets, original game binaries,
  proprietary SDK files, or leaked material.
- Use synthetic fixtures for committed tests.
- Keep real-disc research, traces, screenshots, Wrench output, and extracted
  assets local-only.
- Record third-party dependencies in `THIRD_PARTY.md` before linking or
  vendoring them.

## Local Checks

```powershell
.\scripts\check_repo_hygiene.ps1
cmake --preset windows-msvc-debug
cmake --build --preset windows-msvc-debug
ctest --preset windows-msvc-debug
```

If your toolchain is not installed yet, start with `docs/toolchain_setup.md`.
