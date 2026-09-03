#Requires -Version 7.0
<#
.SYNOPSIS
    Validates the structure of a Fabric project repository.

.DESCRIPTION
    Provider-neutral: runs identically in GitHub Actions, Azure Pipelines and on a laptop.
    Uses only PowerShell 7 built-ins — no modules, no network.

    Checks performed:
      1. Every folder has a README.md index (workspace-synced folders excluded)
      2. No unreplaced <placeholders> outside projects/_template
      3. .platform files are valid, complete, and consistent with their folder name
      4. logicalId is unique within each workspace directory
      5. Fabric item display names avoid characters that force a GUID folder name
      6. No stray non-Fabric files inside Git-connected workspace directories
      7. Relative markdown links resolve
      8. No obvious secrets

.PARAMETER Path
    Repository root. Defaults to the parent of this script's folder.

.PARAMETER SkipLinks
    Skip the markdown link check.

.EXAMPLE
    ./scripts/validate-structure.ps1
    ./scripts/validate-structure.ps1 -Path . -SkipLinks
#>
[CmdletBinding()]
param(
    [string] $Path = (Split-Path -Parent $PSScriptRoot),
    [switch] $SkipLinks
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path $Path).Path
$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Add-Failure { param([string]$File, [string]$Message) $errors.Add("$File`n    $Message") }
function Add-Warning { param([string]$File, [string]$Message) $warnings.Add("$File`n    $Message") }
function Get-Rel { param([string]$FullName) $FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/') }

$excludedDirs = @('.git', 'node_modules', 'vendor', '.venv', '__pycache__', '.ipynb_checkpoints')

function Test-Excluded {
    param([string]$FullName)
    $rel = Get-Rel $FullName
    foreach ($d in $excludedDirs) { if ($rel -eq $d -or $rel -like "$d/*") { return $true } }
    return $false
}

# A path is workspace-synced if it is at or below projects/<project>/workspaces/<ws-dir>/
function Test-FabricOwned {
    param([string]$FullName)
    return (Get-Rel $FullName) -match '^projects/[^/]+/workspaces/[^/]+/'
}

# The workspace directory itself (one level below workspaces/)
function Test-IsWorkspaceDir {
    param([string]$FullName)
    return (Get-Rel $FullName) -match '^projects/[^/]+/workspaces/[^/]+$'
}

Write-Host "Validating $root" -ForegroundColor Cyan

$allDirs = Get-ChildItem -Path $root -Directory -Recurse -Force |
    Where-Object { -not (Test-Excluded $_.FullName) }
$allFiles = Get-ChildItem -Path $root -File -Recurse -Force |
    Where-Object { -not (Test-Excluded $_.FullName) }

# --- 1. README index in every folder ---------------------------------------
Write-Host '  [1/8] README index coverage'
foreach ($dir in $allDirs) {
    if (Test-FabricOwned $dir.FullName) { continue }   # Fabric owns these; a README would sync
    if (Test-IsWorkspaceDir $dir.FullName) { continue }
    if ($dir.Name -eq 'workflows' -or $dir.Name -eq 'pipelines' -or $dir.Name -eq 'ISSUE_TEMPLATE') { continue }
    if ($dir.Name -like '_*' -and $dir.Parent.Name -eq 'skills') { continue }
    if ($dir.Name -eq '.vscode' -or $dir.Name -eq '.github') { continue }

    $hasIndex = Test-Path (Join-Path $dir.FullName 'README.md')
    $hasSkill = Test-Path (Join-Path $dir.FullName 'SKILL.md')
    if (-not $hasIndex -and -not $hasSkill) {
        Add-Failure (Get-Rel $dir.FullName) 'Folder has no README.md index. Every folder needs one.'
    }
}

# --- 2. Unreplaced placeholders --------------------------------------------
Write-Host '  [2/8] Template placeholders'
foreach ($file in ($allFiles | Where-Object { $_.Extension -eq '.md' })) {
    $rel = Get-Rel $file.FullName
    if ($rel -like 'projects/_template/*') { continue }
    if ($rel -notlike 'projects/*') { continue }

    $body = Get-Content $file.FullName -Raw
    $body = [regex]::Replace($body, '(?ms)^```.*?^```', '')   # placeholders inside code fences are illustrative
    $hits = [regex]::Matches($body, '<[a-z][a-z0-9 _/\-,\.]*>') |
        ForEach-Object { $_.Value } | Select-Object -Unique
    if ($hits) {
        Add-Failure $rel "Unreplaced template placeholder(s): $($hits -join ', ')"
    }
}

# --- 3./4./5. .platform files ----------------------------------------------
Write-Host '  [3/8] .platform files'
$platformFiles = $allFiles | Where-Object { $_.Name -eq '.platform' }
$logicalIdsByWorkspace = @{}

$forbiddenNameChars = '["/:<>\\*?|]'

foreach ($pf in $platformFiles) {
    $rel = Get-Rel $pf.FullName
    try { $json = Get-Content $pf.FullName -Raw | ConvertFrom-Json }
    catch { Add-Failure $rel "Not valid JSON: $($_.Exception.Message)"; continue }

    foreach ($p in 'metadata', 'config') {
        if (-not $json.PSObject.Properties.Name.Contains($p)) { Add-Failure $rel "Missing '$p' property." }
    }
    if (-not $json.PSObject.Properties.Name.Contains('metadata')) { continue }
    if (-not $json.metadata.PSObject.Properties.Name.Contains('type')) { Add-Failure $rel "Missing 'metadata.type'." }
    if (-not $json.metadata.PSObject.Properties.Name.Contains('displayName')) { Add-Failure $rel "Missing 'metadata.displayName'."; continue }

    $folder = $pf.Directory
    $folderBase = $folder.Name
    $folderType = ''
    if ($folderBase.Contains('.')) {
        $folderType = $folderBase.Substring($folderBase.LastIndexOf('.') + 1)
        $folderBase = $folderBase.Substring(0, $folderBase.LastIndexOf('.'))
    }

    $displayName = $json.metadata.displayName

    if ($folderType -and $json.metadata.type -ne $folderType) {
        Add-Failure (Get-Rel $folder.FullName) "Folder type '.$folderType' does not match metadata.type '$($json.metadata.type)'. Fabric names folders '{displayName}.{type}'."
    }
    if ($folderBase -ne $displayName) {
        Add-Warning (Get-Rel $folder.FullName) "Folder name '$folderBase' differs from displayName '$displayName'. Expected after a rename in Git; check the item still resolves."
    }

    # Hard checks: these force Fabric to fall back to a GUID folder name.
    if ($displayName -match $forbiddenNameChars) { Add-Failure $rel "displayName '$displayName' contains a forbidden character. Not allowed: double-quote / : < > backslash * ? pipe" }
    if ($displayName -match '[\. ]$')            { Add-Failure $rel "displayName '$displayName' ends with a space or dot." }
    if ($displayName.Length -gt 256)             { Add-Failure $rel "displayName is $($displayName.Length) characters; the limit is 256." }
    if ($displayName -match '_(dev|test|prod|acc)$') {
        Add-Warning $rel "displayName '$displayName' carries a stage suffix. Stage belongs on the workspace; a suffix breaks deployment-pipeline item matching."
    }

    # logicalId uniqueness, scoped to the workspace directory
    if ($json.config.PSObject.Properties.Name.Contains('logicalId')) {
        $lid = $json.config.logicalId
        if ($lid -notmatch '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$') {
            Add-Failure $rel "logicalId '$lid' is not a GUID."
        }
        $wsMatch = [regex]::Match((Get-Rel $pf.FullName), '^(projects/[^/]+/workspaces/[^/]+)/')
        $wsKey = if ($wsMatch.Success) { $wsMatch.Groups[1].Value } else { '<root>' }
        if (-not $logicalIdsByWorkspace.ContainsKey($wsKey)) { $logicalIdsByWorkspace[$wsKey] = @{} }
        if ($logicalIdsByWorkspace[$wsKey].ContainsKey($lid)) {
            Add-Failure $rel "Duplicate logicalId '$lid' — also in '$($logicalIdsByWorkspace[$wsKey][$lid])'. Copying an item folder requires a new GUID and a new displayName."
        }
        else { $logicalIdsByWorkspace[$wsKey][$lid] = $rel }
    }
}
Write-Host "        $($platformFiles.Count) item(s) checked"

# --- 6. Stray files in workspace directories -------------------------------
Write-Host '  [4/8] Workspace directory hygiene'
$allowedAtWorkspaceRoot = @('.gitkeep', '.gitignore')
foreach ($file in $allFiles) {
    $rel = Get-Rel $file.FullName
    $m = [regex]::Match($rel, '^projects/[^/]+/workspaces/[^/]+/(?<rest>.+)$')
    if (-not $m.Success) { continue }
    $rest = $m.Groups['rest'].Value
    if ($rest -notmatch '/') {
        # Sits directly in the workspace directory, so it is not inside an item folder.
        if ($allowedAtWorkspaceRoot -notcontains $file.Name) {
            Add-Failure $rel 'File sits directly in a Git-connected workspace directory. Only Fabric item folders belong here — put documentation beside the directory, not inside it.'
        }
    }
}

# --- 7. Relative markdown links --------------------------------------------
if (-not $SkipLinks) {
    Write-Host '  [5/8] Markdown links'
    # Allows one level of nested parentheses so filenames like "foo (bar).md" are not truncated.
    $linkPattern = '\[[^\]]*\]\((?<target>(?:[^()]|\([^()]*\))*)\)'
    $checked = 0
    foreach ($file in ($allFiles | Where-Object { $_.Extension -eq '.md' })) {
        $content = Get-Content $file.FullName -Raw
        foreach ($m in [regex]::Matches($content, $linkPattern)) {
            $target = $m.Groups['target'].Value.Trim()
            if (-not $target) { continue }
            if ($target -match '^(https?:|mailto:|#)') { continue }
            $target = ($target -split '\s+"')[0]          # strip an optional "title"
            $target = ($target -split '#')[0]               # strip an anchor
            if (-not $target) { continue }
            $target = [uri]::UnescapeDataString($target)
            $resolved = Join-Path $file.DirectoryName $target
            $checked++
            if (-not (Test-Path -LiteralPath $resolved)) {
                Add-Failure (Get-Rel $file.FullName) "Broken link: $target"
            }
        }
    }
    Write-Host "        $checked link(s) checked"
}
else { Write-Host '  [5/8] Markdown links (skipped)' }

# --- 8. Secrets -------------------------------------------------------------
Write-Host '  [6/8] Secret scan'
$secretPatterns = @{
    'Azure storage key'      = 'AccountKey\s*=\s*[A-Za-z0-9+/=]{40,}'
    'SAS token'              = '(sig|sv)=[A-Za-z0-9%+/=]{20,}&'
    'Connection password'    = '(?i)(password|pwd)\s*=\s*[^;\s"'']{6,}'
    'Bearer token'           = '(?i)bearer\s+eyJ[A-Za-z0-9_\-\.]{20,}'
    'Client secret literal'  = '(?i)client[_\-]?secret\s*[:=]\s*["''][^"'']{16,}["'']'
    'Private key block'      = '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
}
foreach ($file in $allFiles) {
    if ($file.Length -gt 2MB) { continue }
    if ($file.Extension -in '.png', '.jpg', '.jpeg', '.gif', '.pbix', '.pbit', '.xlsx') { continue }
    $rel = Get-Rel $file.FullName
    if ($rel -eq 'scripts/validate-structure.ps1') { continue }   # this file defines the patterns
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    foreach ($name in $secretPatterns.Keys) {
        if ($content -match $secretPatterns[$name]) {
            Add-Failure $rel "Possible secret: $name. Move it to Key Vault or the pipeline's secret store."
        }
    }
}

# --- 7./8. Required top-level files ----------------------------------------
Write-Host '  [7/8] Required files'
foreach ($required in 'README.md', 'LICENSE', 'AGENTS.md', '.gitignore', '.github/copilot-instructions.md') {
    if (-not (Test-Path (Join-Path $root $required))) {
        Add-Failure $required 'Required file is missing.'
    }
}

Write-Host '  [8/8] Done'
Write-Host ''

# --- Report -----------------------------------------------------------------
if ($warnings.Count -gt 0) {
    Write-Host "Warnings ($($warnings.Count))" -ForegroundColor Yellow
    foreach ($w in $warnings) { Write-Host "  ! $w" -ForegroundColor Yellow }
    Write-Host ''
}

if ($errors.Count -gt 0) {
    Write-Host "Failed ($($errors.Count))" -ForegroundColor Red
    foreach ($e in $errors) { Write-Host "  x $e" -ForegroundColor Red }
    Write-Host ''
    Write-Host "Structure validation FAILED with $($errors.Count) error(s)." -ForegroundColor Red
    exit 1
}

Write-Host 'Structure validation PASSED.' -ForegroundColor Green
exit 0
