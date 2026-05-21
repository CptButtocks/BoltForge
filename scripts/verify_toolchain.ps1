$ErrorActionPreference = "Stop"

$checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param(
        [string] $Name,
        [bool] $Ok,
        [string] $Detail,
        [string] $Fix
    )

    $checks.Add([pscustomobject]@{
        Name = $Name
        Ok = $Ok
        Detail = $Detail
        Fix = $Fix
    })
}

function Test-CommandRuns {
    param(
        [string] $Command,
        [string[]] $Arguments = @("--version")
    )

    $resolved = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $resolved) {
        return [pscustomobject]@{ Ok = $false; Detail = "not found on PATH" }
    }

    try {
        $output = & $Command @Arguments 2>&1
        if ($LASTEXITCODE -ne 0) {
            return [pscustomobject]@{
                Ok = $false
                Detail = "found at $($resolved.Source), but command failed: $($output -join ' ')"
            }
        }

        return [pscustomobject]@{
            Ok = $true
            Detail = "found at $($resolved.Source): $($output | Select-Object -First 1)"
        }
    }
    catch {
        return [pscustomobject]@{
            Ok = $false
            Detail = "found at $($resolved.Source), but command failed: $($_.Exception.Message)"
        }
    }
}

$vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswhere) {
    $vsInstall = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    Add-Check `
        -Name "Visual Studio C++ workload" `
        -Ok ([bool] $vsInstall) `
        -Detail ($(if ($vsInstall) { $vsInstall } else { "C++ workload not found" })) `
        -Fix "Modify Visual Studio 2026 and add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended."
}
else {
    Add-Check `
        -Name "Visual Studio installer" `
        -Ok $false `
        -Detail "vswhere.exe not found" `
        -Fix "Install Visual Studio 2026 Community or Visual Studio Build Tools."
}

$commands = @(
    @{ Name = "cl"; Command = "cl"; Args = @("/?"); Fix = "Open Developer PowerShell for VS 2026 after installing the C++ workload." },
    @{ Name = "cmake"; Command = "cmake"; Args = @("--version"); Fix = "winget install --source winget --id Kitware.CMake --exact --accept-package-agreements --accept-source-agreements" },
    @{ Name = "ninja"; Command = "ninja"; Args = @("--version"); Fix = "winget install --source winget --id Ninja-build.Ninja --exact --accept-package-agreements --accept-source-agreements" },
    @{ Name = "python"; Command = "python"; Args = @("--version"); Fix = "winget install --source winget --id Python.Python.3.13 --exact --accept-package-agreements --accept-source-agreements" },
    @{ Name = "clang"; Command = "clang"; Args = @("--version"); Fix = "winget install --source winget --id LLVM.LLVM --exact --accept-package-agreements --accept-source-agreements" },
    @{ Name = "clang-format"; Command = "clang-format"; Args = @("--version"); Fix = "winget install --source winget --id LLVM.LLVM --exact --accept-package-agreements --accept-source-agreements" },
    @{ Name = "clang-tidy"; Command = "clang-tidy"; Args = @("--version"); Fix = "winget install --source winget --id LLVM.LLVM --exact --accept-package-agreements --accept-source-agreements" },
    @{ Name = "7z"; Command = "7z"; Args = @("i"); Fix = "winget install --source winget --id 7zip.7zip --exact --accept-package-agreements --accept-source-agreements" },
    @{ Name = "git"; Command = "git"; Args = @("--version"); Fix = "Install Git for Windows: winget install --source winget --id Git.Git --exact --accept-package-agreements --accept-source-agreements" },
    @{ Name = "rg"; Command = "rg"; Args = @("--version"); Fix = "winget install --source winget --id BurntSushi.ripgrep.MSVC --exact --accept-package-agreements --accept-source-agreements" }
)

foreach ($entry in $commands) {
    $result = Test-CommandRuns -Command $entry.Command -Arguments $entry.Args
    Add-Check -Name $entry.Name -Ok $result.Ok -Detail $result.Detail -Fix $entry.Fix
}

if ($env:VCPKG_ROOT) {
    $vcpkgExe = Join-Path $env:VCPKG_ROOT "vcpkg.exe"
    $toolchainFile = Join-Path $env:VCPKG_ROOT "scripts\buildsystems\vcpkg.cmake"
    Add-Check `
        -Name "VCPKG_ROOT" `
        -Ok (Test-Path $env:VCPKG_ROOT) `
        -Detail $env:VCPKG_ROOT `
        -Fix "Set VCPKG_ROOT to %USERPROFILE%\source\tools\vcpkg."
    Add-Check `
        -Name "vcpkg executable" `
        -Ok (Test-Path $vcpkgExe) `
        -Detail $vcpkgExe `
        -Fix "Run bootstrap-vcpkg.bat in %USERPROFILE%\source\tools\vcpkg."
    Add-Check `
        -Name "vcpkg CMake toolchain" `
        -Ok (Test-Path $toolchainFile) `
        -Detail $toolchainFile `
        -Fix "Run bootstrap-vcpkg.bat and keep VCPKG_ROOT pointed at the vcpkg checkout."
}
else {
    Add-Check `
        -Name "VCPKG_ROOT" `
        -Ok $false `
        -Detail "not set" `
        -Fix "Clone vcpkg to %USERPROFILE%\source\tools\vcpkg, bootstrap it, and set the user VCPKG_ROOT environment variable."
}

$checks | Format-Table Name, Ok, Detail -AutoSize

$failures = $checks | Where-Object { -not $_.Ok }
if ($failures) {
    Write-Host ""
    Write-Host "Missing or incomplete toolchain items:" -ForegroundColor Yellow
    foreach ($failure in $failures) {
        Write-Host "- $($failure.Name): $($failure.Fix)"
    }
    exit 1
}

Write-Host ""
Write-Host "Toolchain verification passed." -ForegroundColor Green
