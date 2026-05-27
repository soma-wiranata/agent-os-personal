# =============================================================================
# Agent OS Project Installation PowerShell Script
# Installs Agent OS into a project's codebase natively on Windows
# =============================================================================

param (
    [string]$Profile = $null,
    [switch]$CommandsOnly = $false,
    [switch]$Verbose = $false,
    [switch]$Help = $false
)

# -----------------------------------------------------------------------------
# Colors and Messaging
# -----------------------------------------------------------------------------

function Write-Status ($msg) {
    Write-Host ">>> $msg" -ForegroundColor Cyan
}

function Write-Success ($msg) {
    Write-Host "[OK] $msg" -ForegroundColor Green
}

function Write-WarningMsg ($msg) {
    Write-Host "[WARN] $msg" -ForegroundColor Yellow
}

function Write-ErrorMsg ($msg) {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
}

function Write-VerboseMsg ($msg) {
    if ($Verbose) {
        Write-Host "  [verbose] $msg" -ForegroundColor DarkGray
    }
}

function Show-Help {
    $HelpText = "
Usage: powershell -File project-install.ps1 [OPTIONS]

Install Agent OS into the current project directory.

Options:
    -Profile <name>      Use specified profile (default: from config.yml)
    -CommandsOnly        Only update commands, preserve existing standards
    -Verbose             Show detailed output
    -Help                Show this help message

Examples:
    powershell -File project-install.ps1
    powershell -File project-install.ps1 -Profile rails
    powershell -File project-install.ps1 -CommandsOnly
"
    Write-Host $HelpText
    exit 0
}

if ($Help) {
    Show-Help
}

# -----------------------------------------------------------------------------
# Path and Validation Setup
# -----------------------------------------------------------------------------

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ScriptDir
$ProjectDir = Get-Location

Write-VerboseMsg "Script Directory: $ScriptDir"
Write-VerboseMsg "Base Directory: $BaseDir"
Write-VerboseMsg "Project Directory: $ProjectDir"

# Validate base directory
if (-not (Test-Path "$BaseDir\config.yml")) {
    Write-ErrorMsg "Base installation config.yml not found at: $BaseDir\config.yml"
    exit 1
}

# Validate not installing in base
if ($ProjectDir.Path -eq $BaseDir) {
    Write-ErrorMsg "Cannot install Agent OS in the base installation directory!"
    Write-Host "`nNavigate to your project directory first:"
    Write-Host "  cd \path\to\your\project"
    exit 1
}

# -----------------------------------------------------------------------------
# Simple YAML Parser for config.yml
# -----------------------------------------------------------------------------

function Get-YamlValue ($filePath, $key, $defaultValue) {
    if (-not (Test-Path $filePath)) { return $defaultValue }
    $lines = Get-Content $filePath
    foreach ($line in $lines) {
        # Match 'key: value' ignoring comments
        if ($line -match "^\s*$key\s*:\s*([^#]+)") {
            return $Matches[1].Trim()
        }
    }
    return $defaultValue
}

# Recursively finds inheritance of profiles
function Get-ProfileInheritance ($filePath, $profileName) {
    if (-not (Test-Path $filePath)) { return @($profileName) }
    
    $lines = Get-Content $filePath
    $inherits = $null
    
    # We find profile-specific inherits_from block
    # Looks for:
    #   profile-name:
    #     inherits_from: parent
    $inProfiles = $false
    $inTarget = $false
    
    foreach ($line in $lines) {
        if ($line -match "^profiles\s*:") {
            $inProfiles = $true
            continue
        }
        if ($inProfiles -and $line -match "^\s{2}$profileName\s*:") {
            $inTarget = $true
            continue
        }
        if ($inProfiles -and $line -match "^[^\s]") {
            # Left aligned means we exited the profiles section
            $inProfiles = $false
            $inTarget = $false
        }
        if ($inTarget -and $line -match "^\s{4}inherits_from\s*:\s*([^#\s]+)") {
            $inherits = $Matches[1].Trim()
            break
        }
    }
    
    if ($null -ne $inherits) {
        return @($inherits)
    }
    return @()
}

# Build full inheritance chain with circular check
$ConfigFile = "$BaseDir\config.yml"
$DefaultProfile = Get-YamlValue $ConfigFile "default_profile" "default"
$EffectiveProfile = if ($Profile) { $Profile } else { $DefaultProfile }

Write-VerboseMsg "Effective Profile: $EffectiveProfile"

if (-not (Test-Path "$BaseDir\profiles\$EffectiveProfile")) {
    Write-ErrorMsg "Profile not found: $EffectiveProfile"
    exit 1
}

# Resolve inheritance chain
$InheritanceChain = @($EffectiveProfile)
$Visited = @{$EffectiveProfile = $true}
$Current = $EffectiveProfile

while ($true) {
    $parentList = Get-ProfileInheritance $ConfigFile $Current
    if ($parentList.Count -eq 0) {
        break
    }
    $parent = $parentList[0]
    Write-VerboseMsg "$Current inherits from $parent"
    
    if ($Visited.ContainsKey($parent)) {
        Write-ErrorMsg "Circular dependency detected in profile inheritance chain!"
        exit 1
    }
    
    if (-not (Test-Path "$BaseDir\profiles\$parent")) {
        Write-ErrorMsg "Inherited profile not found: $parent"
        exit 1
    }
    
    $InheritanceChain += $parent
    $Visited[$parent] = $true
    $Current = $parent
}

# Reverse the chain so base profile is first (base is overwritten by specific profiles)
[array]::Reverse($InheritanceChain)

# -----------------------------------------------------------------------------
# Overwrite confirmation
# -----------------------------------------------------------------------------

$ExistingStandards = "$ProjectDir\agent-os\standards"
if (-not $CommandsOnly -and (Test-Path $ExistingStandards)) {
    Write-Host ""
    Write-WarningMsg "Existing standards folder detected at: $ExistingStandards"
    Write-Host ""
    Write-Host "This will overwrite your existing standards with standards from the '$EffectiveProfile' profile."
    $response = Read-Host "Do you want to continue? (y/N)"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "`nInstallation cancelled."
        Write-Host "To update only commands without touching standards, use:"
        Write-Host "  powershell -File scripts\project-install.ps1 -CommandsOnly"
        exit 0
    }
}

# -----------------------------------------------------------------------------
# Installation
# -----------------------------------------------------------------------------

Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "      Agent OS Project Installation" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

Write-Status "Configuration:"
# Display chain
for ($i = $InheritanceChain.Count - 1; $i -ge 0; $i--) {
    $profile = $InheritanceChain[$i]
    if ($i -eq $InheritanceChain.Count - 1) {
        Write-Host "  Profile: $profile"
    } else {
        $indent = "  " * ($InheritanceChain.Count - 1 - $i)
        Write-Host "$indent  -> inherits from: $profile"
    }
}
Write-Host "  Commands only: $CommandsOnly"
Write-Host ""

# Create directories
Write-Status "Creating project structure..."
$DirsToCreate = @(
    "$ProjectDir\agent-os",
    "$ProjectDir\agent-os\standards",
    "$ProjectDir\.agent\workflows",
    "$ProjectDir\.agent\skills"
)

foreach ($dir in $DirsToCreate) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Success "Created agent-os/ and .agent/ directory structures"

# Install standards
if (-not $CommandsOnly) {
    Write-Host ""
    Write-Status "Installing standards..."
    $totalCount = 0
    $profilesUsed = 0
    
    # Store dynamic standard tracking
    $CopiedFiles = @{}
    
    foreach ($profileName in $InheritanceChain) {
        $profileStandards = "$BaseDir\profiles\$profileName\standards"
        if (Test-Path $profileStandards) {
            $files = Get-ChildItem -Path $profileStandards -Filter "*.md" -Recurse -File
            $profileFileCount = 0
            
            foreach ($file in $files) {
                # Exclude .backups folders if any
                if ($file.FullName -match "\\\.backups\\") { continue }
                
                $relPath = $file.FullName.Substring($profileStandards.Length + 1)
                $destFile = "$ProjectDir\agent-os\standards\$relPath"
                
                $destFolder = Split-Path -Parent $destFile
                if (-not (Test-Path $destFolder)) {
                    New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
                }
                
                Copy-Item -Path $file.FullName -Destination $destFile -Force | Out-Null
                $CopiedFiles[$relPath] = $profileName
                $profileFileCount++
            }
            if ($profileFileCount -gt 0) {
                $profilesUsed++
            }
        }
    }
    
    $keys = $CopiedFiles.Keys | Sort-Object
    foreach ($key in $keys) {
        if ($InheritanceChain.Count -gt 1) {
            Write-Host "  $key (from $($CopiedFiles[$key]))"
        } else {
            Write-Host "  $key"
        }
        $totalCount++
    }
    
    if ($profilesUsed -gt 1) {
        Write-Success "Installed $totalCount standards files (from $profilesUsed profiles)"
    } else {
        Write-Success "Installed $totalCount standards files"
    }
    
    # -------------------------------------------------------------------------
    # Rebuild Index File index.yml
    # -------------------------------------------------------------------------
    Write-Host ""
    Write-Status "Updating standards index..."
    
    $StandardsDir = "$ProjectDir\agent-os\standards"
    $IndexFile = "$StandardsDir\index.yml"
    
    # Parse existing descriptions if index exists
    $OldIndexDesc = @{}
    if (Test-Path $IndexFile) {
        $lines = Get-Content $IndexFile
        $currentFolder = "root"
        $currentFile = $null
        foreach ($line in $lines) {
            if ($line -match "^([a-zA-Z0-9_-]+)\s*:\s*$") {
                $currentFolder = $Matches[1]
                continue
            }
            if ($line -match "^\s{2}([a-zA-Z0-9_-]+)\s*:\s*$") {
                $currentFile = $Matches[1]
                continue
            }
            if ($line -match "^\s{4}description\s*:\s*([^#]+)") {
                $desc = $Matches[1].Trim()
                if ($null -ne $currentFile) {
                    $OldIndexDesc["$currentFolder/$currentFile"] = $desc
                }
            }
        }
    }
    
    $indexContent = @("# Agent OS Standards Index", "")
    $entryCount = 0
    $newCount = 0
    
    # First: Root-level .md files
    $rootFiles = Get-ChildItem -Path $StandardsDir -Filter "*.md" -File | Sort-Object Name
    if ($rootFiles.Count -gt 0) {
        $indexContent += "root:"
        foreach ($file in $rootFiles) {
            $filename = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $lookupKey = "root/$filename"
            $desc = "Needs description - run /index-standards"
            if ($OldIndexDesc.ContainsKey($lookupKey) -and $OldIndexDesc[$lookupKey] -ne "Needs description - run /index-standards") {
                $desc = $OldIndexDesc[$lookupKey]
            } else {
                $newCount++
            }
            $indexContent += "  ${filename}:"
            $indexContent += "    description: $desc"
            $entryCount++
        }
        $indexContent += ""
    }
    
    # Second: Folders under standards/
    $folders = Get-ChildItem -Path $StandardsDir -Directory | Sort-Object Name
    foreach ($folder in $folders) {
        $mdFiles = Get-ChildItem -Path $folder.FullName -Filter "*.md" -File | Sort-Object Name
        if ($mdFiles.Count -gt 0) {
            $indexContent += "$($folder.Name):"
            foreach ($file in $mdFiles) {
                $filename = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                $lookupKey = "$($folder.Name)/$filename"
                $desc = "Needs description - run /index-standards"
                if ($OldIndexDesc.ContainsKey($lookupKey) -and $OldIndexDesc[$lookupKey] -ne "Needs description - run /index-standards") {
                    $desc = $OldIndexDesc[$lookupKey]
                } else {
                    $newCount++
                }
                $indexContent += "  ${filename}:"
                $indexContent += "    description: $desc"
                $entryCount++
            }
            $indexContent += ""
        }
    }
    
    Set-Content -Path $IndexFile -Value $indexContent -Encoding utf8
    if ($entryCount -gt 0) {
        if ($newCount -gt 0) {
            Write-Success "Updated index.yml ($entryCount entries, $newCount new)"
        } else {
            Write-Success "Updated index.yml ($entryCount entries)"
        }
    } else {
        Write-Success "Created index.yml (no standards to index)"
    }
} else {
    Write-Status "Skipping standards (-CommandsOnly)"
}

# -----------------------------------------------------------------------------
# Copy Commands
# -----------------------------------------------------------------------------
Write-Host ""
Write-Status "Installing commands..."

$commandsSource = "$BaseDir\commands\agent-os"
$commandsDestClaude = "$ProjectDir\.claude\commands\agent-os"
$commandsDestAntigravity = "$ProjectDir\.agent\workflows"

if (-not (Test-Path $commandsSource)) {
    Write-WarningMsg "No commands found in base installation"
} else {
    # Ensure folders exist
    if (-not (Test-Path $commandsDestClaude)) {
        New-Item -ItemType Directory -Path $commandsDestClaude -Force | Out-Null
    }
    if (-not (Test-Path $commandsDestAntigravity)) {
        New-Item -ItemType Directory -Path $commandsDestAntigravity -Force | Out-Null
    }
    
    $commandFiles = Get-ChildItem -Path $commandsSource -Filter "*.md" -File
    $count = 0
    foreach ($file in $commandFiles) {
        Copy-Item -Path $file.FullName -Destination "$commandsDestClaude\" -Force | Out-Null
        Copy-Item -Path $file.FullName -Destination "$commandsDestAntigravity\" -Force | Out-Null
        $count++
    }
    
    if ($count -gt 0) {
        Write-Success "Installed $count commands to both .claude/commands/agent-os/ and .agent/workflows/"
    } else {
        Write-WarningMsg "No command files found"
    }
}

Write-Host ""
Write-Success "Agent OS installed successfully!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Run /discover-standards to extract patterns from your codebase"
Write-Host "  2. Run /inject-standards to inject standards into your context"
Write-Host ""
