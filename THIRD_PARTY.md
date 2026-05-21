# Third-Party Inventory

This file tracks third-party tools and libraries selected for the initial
toolchain. Record exact versions when they become pinned by CI, vcpkg baselines,
or release artifacts.

## Linked C++ Dependencies

| Dependency | Source | Purpose | License note |
|---|---|---|---|
| Catch2 | vcpkg `catch2` | C++ smoke and unit tests | BSL-1.0 |
| CLI11 | vcpkg `cli11` | Command-line parser for `ratchetpc` | BSD-3-Clause |
| fmt | vcpkg `fmt` | Formatting | MIT |
| nlohmann-json | vcpkg `nlohmann-json` | JSON manifests and reports | MIT |
| spdlog | vcpkg `spdlog` | Logging | MIT |
| yaml-cpp | vcpkg `yaml-cpp` | YAML metadata and future disc database files | MIT |

## Required Local Build Tools

| Tool | Purpose | License note |
|---|---|---|
| Visual Studio 2026 C++ workload | MSVC compiler and Windows SDK | Microsoft product terms |
| CMake | Configure builds | BSD-3-Clause |
| Ninja | Build executor | Apache-2.0 |
| vcpkg | Dependency acquisition in manifest mode | MIT |
| Python 3.13 | Scripts and tooling support | PSF License |
| LLVM tools | `clang-format`, `clang-tidy`, and optional diagnostics | Apache-2.0 with LLVM exceptions |
| 7-Zip | Archive extraction for local tools | LGPL-2.1-or-later with unRAR restriction notes |
| ripgrep | Fast source search | MIT or Unlicense |

## Optional Research Tools

| Tool | Purpose | License note |
|---|---|---|
| Ghidra | Reverse-engineering research notes | Apache-2.0 |
| Ghidra Emotion Engine: Reloaded | PS2 Emotion Engine support for Ghidra | Apache-2.0 |
| PCSX2 | Local reference runs and traces from user-owned data | GPL-3.0 |
| RenderDoc | Native renderer frame capture once rendering exists | MIT |
| Tracy | Native runtime profiling once runtime loops exist | BSD-3-Clause |
| Wrench | Local-only comparison for public R&C format research | GPL-3.0; do not copy or link without a compatible license decision |
