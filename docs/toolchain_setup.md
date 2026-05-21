# Toolchain Setup

BoltForge starts Windows-first with C++20, CMake, Ninja, and vcpkg manifest
mode. Use these steps before building the repo locally.

## Required Windows Tools

Run PowerShell as a normal user unless a command prompts for elevation.

```powershell
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\setup.exe" modify `
  --installPath "C:\Program Files\Microsoft Visual Studio\18\Community" `
  --add Microsoft.VisualStudio.Workload.NativeDesktop `
  --includeRecommended `
  --passive `
  --norestart
```

Install command-line tools from the `winget` source to avoid Microsoft Store
source prompts:

```powershell
winget install --source winget --id Kitware.CMake --exact --accept-package-agreements --accept-source-agreements
winget install --source winget --id Ninja-build.Ninja --exact --accept-package-agreements --accept-source-agreements
winget install --source winget --id Python.Python.3.13 --exact --accept-package-agreements --accept-source-agreements
winget install --source winget --id LLVM.LLVM --exact --accept-package-agreements --accept-source-agreements
winget install --source winget --id 7zip.7zip --exact --accept-package-agreements --accept-source-agreements
winget install --source winget --id BurntSushi.ripgrep.MSVC --exact --accept-package-agreements --accept-source-agreements
```

Bootstrap vcpkg in manifest mode:

```powershell
$tools = Join-Path $env:USERPROFILE "source\tools"
$vcpkgRoot = Join-Path $tools "vcpkg"
New-Item -ItemType Directory -Force $tools | Out-Null
git clone https://github.com/microsoft/vcpkg $vcpkgRoot
& "$vcpkgRoot\bootstrap-vcpkg.bat" -disableMetrics
[Environment]::SetEnvironmentVariable("VCPKG_ROOT", $vcpkgRoot, "User")
$env:VCPKG_ROOT = $vcpkgRoot
```

Open a new Developer PowerShell for Visual Studio 2026 so `cl` is on `PATH`.

If Visual Studio 2026 cannot provide a working MSVC environment after the C++
workload is installed, use Visual Studio Build Tools 2022 as the fallback:

```powershell
winget install --source winget --id Microsoft.VisualStudio.2022.BuildTools --exact `
  --accept-package-agreements `
  --accept-source-agreements `
  --override "--wait --passive --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```

Then build from the Developer PowerShell profile installed with Build Tools.

## Build And Test

```powershell
.\scripts\verify_toolchain.ps1
.\scripts\check_repo_hygiene.ps1
cmake --preset windows-msvc-debug
cmake --build --preset windows-msvc-debug
ctest --preset windows-msvc-debug
.\build\windows-msvc-debug\ratchetpc.exe --version
```

Use `windows-msvc-release` for an optimized local build.

## Optional Research Tools

These are useful for reverse engineering and validation, but they are not
required to build the starter CLI.

```powershell
winget install --source winget --id Microsoft.OpenJDK.21 --exact --accept-package-agreements --accept-source-agreements
winget install --source winget --id PCSX2Team.PCSX2 --exact --accept-package-agreements --accept-source-agreements
winget install --source winget --id BaldurKarlsson.RenderDoc --exact --accept-package-agreements --accept-source-agreements
winget install --source winget --id wolfpld.tracy --exact --accept-package-agreements --accept-source-agreements
```

Install Ghidra manually from
https://github.com/NationalSecurityAgency/ghidra/releases, then install Ghidra
Emotion Engine: Reloaded from
https://github.com/chaoticgd/ghidra-emotionengine-reloaded/releases.

Wrench can be used as a local-only comparison tool from
https://github.com/chaoticgd/wrench. Treat it as GPL-3.0 software and do not
copy or link its code unless the project deliberately adopts a compatible
license strategy.

## Local Data Rule

Keep ISOs, extracted assets, Wrench outputs, PCSX2 traces, screenshots, and
RenderDoc captures outside Git. The committed test suite uses only synthetic or
empty smoke fixtures.
