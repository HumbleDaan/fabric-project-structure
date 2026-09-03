#Requires -Version 7.0
<#
.SYNOPSIS
    Makes the Microsoft Fabric agent skills available to this repository.

.DESCRIPTION
    The Fabric technical skills are published by Microsoft at github.com/microsoft/skills-for-fabric.
    They are consumed, not copied — this script sets up whichever consumption path suits your host
    and network.

      Plugin   Prints the Copilot CLI / Claude Code commands. The recommended path.
      Vendor   Clones the repo to vendor/skills-for-fabric (git-ignored) so any agent can read it
               locally. Use for Cursor, Windsurf, or an Azure DevOps-only environment.
      Submodule Adds it as a pinned git submodule. Use when you need a reproducible, reviewed
               version rather than latest.

.PARAMETER Mode
    Plugin (default) | Vendor | Submodule

.PARAMETER Ref
    Branch or tag to check out in Vendor/Submodule mode. Default: main.

.EXAMPLE
    ./scripts/bootstrap-skills.ps1
    ./scripts/bootstrap-skills.ps1 -Mode Vendor
    ./scripts/bootstrap-skills.ps1 -Mode Submodule -Ref v0.3.0
#>
[CmdletBinding()]
param(
    [ValidateSet('Plugin', 'Vendor', 'Submodule')]
    [string] $Mode = 'Plugin',
    [string] $Ref = 'main'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoUrl = 'https://github.com/microsoft/skills-for-fabric.git'
$root = Split-Path -Parent $PSScriptRoot
$vendorPath = Join-Path $root 'vendor/skills-for-fabric'

switch ($Mode) {

    'Plugin' {
        Write-Host ''
        Write-Host 'GitHub Copilot CLI' -ForegroundColor Cyan
        Write-Host '  /plugin marketplace add microsoft/skills-for-fabric'
        Write-Host '  /plugin install fabric-skills@fabric-collection'
        Write-Host '  /plugin install powerbi-authoring@fabric-collection   # semantic models + reports'
        Write-Host ''
        Write-Host 'Claude Code' -ForegroundColor Cyan
        Write-Host '  /plugin  ->  Marketplaces  ->  add microsoft/skills-for-fabric  ->  install fabric-skills'
        Write-Host ''
        Write-Host 'Keep them current' -ForegroundColor Cyan
        Write-Host '  copilot plugin update --all'
        Write-Host ''
        Write-Host 'No marketplace access from this network? Use -Mode Vendor.' -ForegroundColor Yellow
        Write-Host ''
    }

    'Vendor' {
        if (Test-Path $vendorPath) {
            Write-Host "Updating $vendorPath ..." -ForegroundColor Cyan
            git -C $vendorPath fetch --depth 1 origin $Ref
            git -C $vendorPath checkout --force FETCH_HEAD
        }
        else {
            Write-Host "Cloning skills-for-fabric ($Ref) to vendor/ ..." -ForegroundColor Cyan
            New-Item -ItemType Directory -Path (Split-Path $vendorPath) -Force | Out-Null
            git clone --depth 1 --branch $Ref $repoUrl $vendorPath
        }
        if ($LASTEXITCODE -ne 0) { throw 'git failed. Check network access to github.com.' }

        $sha = (git -C $vendorPath rev-parse --short HEAD).Trim()
        Write-Host ''
        Write-Host "Vendored at $sha" -ForegroundColor Green
        Write-Host 'vendor/ is git-ignored, so this stays out of your history.'
        Write-Host 'Point your agent at vendor/skills-for-fabric/ for Fabric platform know-how.'
        Write-Host ''
    }

    'Submodule' {
        Write-Host "Adding pinned submodule at $Ref ..." -ForegroundColor Cyan
        Push-Location $root
        try {
            git submodule add -b $Ref $repoUrl vendor/skills-for-fabric
            git submodule update --init --recursive
        }
        finally { Pop-Location }

        Write-Host ''
        Write-Host 'Submodule added. Two follow-ups:' -ForegroundColor Yellow
        Write-Host '  1. Remove vendor/skills-for-fabric/ from .gitignore, or the submodule will be ignored.'
        Write-Host '  2. Azure DevOps: enable "Checkout submodules" on the pipeline job.'
        Write-Host '     Cross-provider submodules need an authenticated remote — see docs/06-azure-devops-port.md.'
        Write-Host ''
    }
}
