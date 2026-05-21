$ErrorActionPreference = "Stop"

$forbiddenExtensions = @(
    ".iso", ".cso", ".chd", ".mdf", ".cue", ".bin", ".elf", ".irx",
    ".wad", ".vag", ".pss"
)

$allowedBinaryRoots = @(
    "data/synthetic_fixtures/"
)

$maxFileBytes = 10MB
$failures = New-Object System.Collections.Generic.List[string]

function Convert-ToRepoPath {
    param([string] $Path)
    return ($Path -replace "\\", "/")
}

function Is-AllowedSyntheticPath {
    param([string] $RepoPath)
    foreach ($root in $allowedBinaryRoots) {
        if ($RepoPath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

$files = git ls-files
foreach ($file in $files) {
    $repoPath = Convert-ToRepoPath $file
    $extension = [System.IO.Path]::GetExtension($repoPath).ToLowerInvariant()

    if ($forbiddenExtensions -contains $extension -and -not (Is-AllowedSyntheticPath $repoPath)) {
        $failures.Add("Forbidden game-data-like extension: $repoPath")
    }

    if (Test-Path -LiteralPath $file) {
        $item = Get-Item -LiteralPath $file
        if ($item.Length -gt $maxFileBytes -and -not (Is-AllowedSyntheticPath $repoPath)) {
            $failures.Add("File exceeds 10 MiB limit: $repoPath ($($item.Length) bytes)")
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host "Repository hygiene check failed:" -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "- $failure"
    }
    exit 1
}

Write-Host "Repository hygiene check passed." -ForegroundColor Green
