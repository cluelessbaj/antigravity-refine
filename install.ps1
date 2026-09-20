# Antigravity Refine Skill Installer for Windows PowerShell
# Usage:
#   .\install.ps1 -Mode workspace
#   .\install.ps1 -Mode global
#   irm https://raw.githubusercontent.com/cluelessbaj/antigravity-refine/main/install.ps1 | iex

param(
    [ValidateSet('workspace', 'global', 'all')]
    [string]$Mode = 'workspace'
)

$ErrorActionPreference = 'Stop'

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host " Installing /refine skill for Antigravity  " -ForegroundColor Cyan
Write-Host " (Windows PowerShell Edition)             " -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

$BaseUrl = "https://raw.githubusercontent.com/cluelessbaj/antigravity-refine/main"
$ScriptDir = $PSScriptRoot

function Repair-ConfigFile {
    param([string]$ConfigFile)
    if (Test-Path $ConfigFile) {
        try {
            $bytes = [System.IO.File]::ReadAllBytes($ConfigFile)
            # Detect and strip UTF-8 BOM (0xEF, 0xBB, 0xBF) which breaks Go's protobuf parser
            if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
                $cleanBytes = $bytes[3..($bytes.Length - 1)]
                [System.IO.File]::WriteAllBytes($ConfigFile, $cleanBytes)
                Write-Host "[✓] Repaired config.json: Stripped UTF-8 BOM" -ForegroundColor Green
            }
        } catch {
            Write-Host "[!] Note: Could not check BOM on config.json: $_" -ForegroundColor Yellow
        }
    }
}

function Install-Workspace {
    $TargetDir = Get-Location
    Write-Host "`n[*] Installing to workspace: $TargetDir" -ForegroundColor Yellow

    $AgentsSkillDir = Join-Path $TargetDir ".agents\skills\refine"
    $AntigravitySkillDir = Join-Path $TargetDir ".antigravity\skills"

    New-Item -ItemType Directory -Force -Path $AgentsSkillDir | Out-Null
    New-Item -ItemType Directory -Force -Path $AntigravitySkillDir | Out-Null

    if ($ScriptDir -and (Test-Path (Join-Path $ScriptDir "skills\refine\SKILL.md"))) {
        Copy-Item (Join-Path $ScriptDir "skills\refine\SKILL.md") (Join-Path $AgentsSkillDir "SKILL.md") -Force
        Copy-Item (Join-Path $ScriptDir ".antigravity\skills\refine.md") (Join-Path $AntigravitySkillDir "refine.md") -Force
        Copy-Item (Join-Path $ScriptDir "rules\AGENTS.md") (Join-Path $TargetDir "AGENTS.md") -Force
        Copy-Item (Join-Path $ScriptDir "rules\GEMINI.md") (Join-Path $TargetDir "GEMINI.md") -Force
    } else {
        Write-Host "Downloading latest skill files from GitHub..." -ForegroundColor Gray
        Invoke-RestMethod "$BaseUrl/skills/refine/SKILL.md" -OutFile (Join-Path $AgentsSkillDir "SKILL.md")
        Invoke-RestMethod "$BaseUrl/.antigravity/skills/refine.md" -OutFile (Join-Path $AntigravitySkillDir "refine.md")
        Invoke-RestMethod "$BaseUrl/rules/AGENTS.md" -OutFile (Join-Path $TargetDir "AGENTS.md")
        Invoke-RestMethod "$BaseUrl/rules/GEMINI.md" -OutFile (Join-Path $TargetDir "GEMINI.md")
    }

    Write-Host "[✓] Workspace installation complete!" -ForegroundColor Green
    Write-Host "    - .agents\skills\refine\SKILL.md"
    Write-Host "    - .antigravity\skills\refine.md"
    Write-Host "    - AGENTS.md"
    Write-Host "    - GEMINI.md"
}

function Install-Global {
    $UserProfile = $env:USERPROFILE
    if (-not $UserProfile) {
        $UserProfile = [Environment]::GetFolderPath('UserProfile')
    }

    $ConfigDir = Join-Path $UserProfile ".gemini\config"
    $AppDir    = Join-Path $UserProfile ".gemini\antigravity"

    Write-Host "`n[*] Installing globally to:" -ForegroundColor Yellow
    Write-Host "    Config: $ConfigDir"
    Write-Host "    App:    $AppDir"

    $PluginSkillDir   = Join-Path $ConfigDir "plugins\refine\skills\refine"
    $PluginRulesDir   = Join-Path $ConfigDir "plugins\refine\rules"
    $GlobalSkillDir   = Join-Path $ConfigDir "skills\refine"
    $BuiltinSkillDir  = Join-Path $AppDir "builtin\skills\refine"
    $GlobalRulesDir   = Join-Path $AppDir "rules"

    New-Item -ItemType Directory -Force -Path $PluginSkillDir | Out-Null
    New-Item -ItemType Directory -Force -Path $PluginRulesDir | Out-Null
    New-Item -ItemType Directory -Force -Path $GlobalSkillDir | Out-Null
    New-Item -ItemType Directory -Force -Path $BuiltinSkillDir | Out-Null
    New-Item -ItemType Directory -Force -Path $GlobalRulesDir | Out-Null

    if ($ScriptDir -and (Test-Path (Join-Path $ScriptDir "skills\refine\SKILL.md"))) {
        Copy-Item (Join-Path $ScriptDir "plugin.json") (Join-Path $ConfigDir "plugins\refine\plugin.json") -Force
        Copy-Item (Join-Path $ScriptDir "skills\refine\SKILL.md") (Join-Path $PluginSkillDir "SKILL.md") -Force
        Copy-Item (Join-Path $ScriptDir "rules\AGENTS.md") (Join-Path $PluginRulesDir "AGENTS.md") -Force
        Copy-Item (Join-Path $ScriptDir "skills\refine\SKILL.md") (Join-Path $GlobalSkillDir "SKILL.md") -Force
        Copy-Item (Join-Path $ScriptDir "skills\refine\SKILL.md") (Join-Path $BuiltinSkillDir "SKILL.md") -Force
        Copy-Item (Join-Path $ScriptDir "rules\AGENTS.md") (Join-Path $GlobalRulesDir "refine.md") -Force
    } else {
        Write-Host "Downloading latest skill files from GitHub..." -ForegroundColor Gray
        Invoke-RestMethod "$BaseUrl/plugin.json" -OutFile (Join-Path $ConfigDir "plugins\refine\plugin.json")
        Invoke-RestMethod "$BaseUrl/skills/refine/SKILL.md" -OutFile (Join-Path $PluginSkillDir "SKILL.md")
        Invoke-RestMethod "$BaseUrl/rules/AGENTS.md" -OutFile (Join-Path $PluginRulesDir "AGENTS.md")
        Invoke-RestMethod "$BaseUrl/skills/refine/SKILL.md" -OutFile (Join-Path $GlobalSkillDir "SKILL.md")
        Invoke-RestMethod "$BaseUrl/skills/refine/SKILL.md" -OutFile (Join-Path $BuiltinSkillDir "SKILL.md")
        Invoke-RestMethod "$BaseUrl/rules/AGENTS.md" -OutFile (Join-Path $GlobalRulesDir "refine.md")
    }

    # Ensure config.json has no BOM if it was previously touched
    $ConfigFile = Join-Path $ConfigDir "config.json"
    Repair-ConfigFile -ConfigFile $ConfigFile

    Write-Host "[✓] Global installation complete!" -ForegroundColor Green
}

switch ($Mode) {
    'workspace' { Install-Workspace }
    'global'    { Install-Global }
    'all'       { Install-Workspace; Install-Global }
}

Write-Host "`nDone! You can now use '/refine <prompt>' or 'refine: <prompt>' in Antigravity." -ForegroundColor Cyan
