# =============================================================================
# Agent OS Sync to Profile PowerShell Script
# Syncs project standards back to a base profile for reuse natively on Windows
# =============================================================================

param (
    [string]$Profile = $null,
    [string]$NewProfile = $null,
    [switch]$All = $false,
    [switch]$Overwrite = $false,
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
Usage: powershell -File sync-to-profile.ps1 [OPTIONS]

Sync project standards back to a base profile for reuse.

Options:
    -Profile <name>      Target profile (skips selection prompt)
    -NewProfile <name>   Create a new profile with these standards
    -All                 Sync all standards (skips file selection)
    -Overwrite           Overwrite existing files without prompting
    -Verbose             Show detailed output
    -Help                Show this help message

Examples:
    powershell -File sync-to-profile.ps1
    powershell -File sync-to-profile.ps1 -Profile rails
    powershell -File sync-to-profile.ps1 -All -Overwrite
    powershell -File sync-to-profile.ps1 -NewProfile nextjs -All
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
if (-not (Test-Path "$BaseDir\profiles")) {
    Write-ErrorMsg "No profiles directory in base installation: $BaseDir\profiles"
    exit 1
}

# Validate project standards
$ProjectStandardsDir = "$ProjectDir\agent-os\standards"
if (-not (Test-Path $ProjectStandardsDir)) {
    Write-ErrorMsg "No standards directory found at agent-os\standards\"
    Write-Host "`nRun project-install.ps1 first to set up Agent OS in this project."
    exit 1
}

# Find all standard files
$Files = Get-ChildItem -Path $ProjectStandardsDir -Filter "*.md" -Recurse -File | Sort-Object FullName
$StandardsFiles = @()

foreach ($file in $Files) {
    # Exclude .backups folders if any
    if ($file.FullName -match "\\\.backups\\") { continue }
    
    $relPath = $file.FullName.Substring($ProjectStandardsDir.Length + 1)
    $StandardsFiles += $relPath
}

if ($StandardsFiles.Count -eq 0) {
    Write-ErrorMsg "No standards to sync."
    Write-Host "`nCreate standards first using /discover-standards or manually."
    exit 1
}

Write-VerboseMsg "Found $($StandardsFiles.Count) standards files"

# -----------------------------------------------------------------------------
# Profile Selection
# -----------------------------------------------------------------------------

function Get-ExistingProfiles {
    $profileDirs = Get-ChildItem -Path "$BaseDir\profiles" -Directory
    $names = @()
    foreach ($dir in $profileDirs) {
        $names += $dir.Name
    }
    return $names
}

function Create-NewProfile ($name) {
    $profileDir = "$BaseDir\profiles\$name"
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path "$profileDir\standards" -Force | Out-Null
        Write-Success "Created new profile: $name"
    }
}

$TargetProfile = $null

if ($NewProfile) {
    $TargetProfile = $NewProfile
    Create-NewProfile $TargetProfile
} elseif ($Profile) {
    $TargetProfile = $Profile
    if (-not (Test-Path "$BaseDir\profiles\$TargetProfile")) {
        Write-Host ""
        $response = Read-Host "Profile '$TargetProfile' doesn't exist. Create it? (y/n)"
        if ($response -match "^[Yy]") {
            Create-NewProfile $TargetProfile
        } else {
            Write-ErrorMsg "Cancelled."
            exit 1
        }
    }
} else {
    # Interactive profile selection
    Write-Host ""
    Write-Status "Available profiles:"
    Write-Host ""
    
    $existing = Get-ExistingProfiles
    $i = 1
    foreach ($p in $existing) {
        Write-Host "  $i) $p"
        $i++
    }
    Write-Host "  $i) [Create new profile]"
    Write-Host ""
    
    $choice = $null
    while ($true) {
        $ans = Read-Host "Select profile (1-$i)"
        if ($ans -match "^\d+$" -and [int]$ans -ge 1 -and [int]$ans -le $i) {
            $choice = [int]$ans
            break
        }
        Write-Host "Invalid choice. Please enter a number between 1 and $i."
    }
    
    if ($choice -eq $i) {
        Write-Host ""
        $name = Read-Host "Enter new profile name"
        if ([string]::IsNullOrWhiteSpace($name)) {
            Write-ErrorMsg "Profile name cannot be empty."
            exit 1
        }
        $TargetProfile = $name.Trim()
        Create-NewProfile $TargetProfile
    } else {
        $TargetProfile = $existing[$choice - 1]
    }
}

Write-VerboseMsg "Selected profile: $TargetProfile"

# -----------------------------------------------------------------------------
# File Selection
# -----------------------------------------------------------------------------

$SelectedFiles = @()

if ($All) {
    $SelectedFiles = @($StandardsFiles)
    Write-VerboseMsg "Selected all $($SelectedFiles.Count) files"
} else {
    # Interactive Selection
    $selected = @{}
    foreach ($file in $StandardsFiles) {
        $selected[$file] = $true # select all by default
    }
    
    while ($true) {
        # Clear screen is hard in PowerShell console without scrollback issues, 
        # so we just print the state nicely
        Write-Host "`n========================================="
        Write-Status "Select standards to sync:"
        Write-Host ""
        
        $i = 1
        foreach ($file in $StandardsFiles) {
            $check = if ($selected[$file]) { "[x]" } else { "[ ]" }
            Write-Host "  $i) $check $file"
            $i++
        }
        Write-Host ""
        Write-Host "  Enter number to toggle | a) All | n) None | d) Done"
        Write-Host ""
        
        $choice = Read-Host "Toggle (1-$($StandardsFiles.Count)), a, n, or d"
        
        if ($choice -match "^[dD]$") {
            break
        } elseif ($choice -match "^[aA]$") {
            foreach ($file in $StandardsFiles) { $selected[$file] = $true }
        } elseif ($choice -match "^[nN]$") {
            foreach ($file in $StandardsFiles) { $selected[$file] = $false }
        } elseif ($choice -match "^\d+$" -and [int]$choice -ge 1 -and [int]$choice -le $StandardsFiles.Count) {
            $file = $StandardsFiles[[int]$choice - 1]
            $selected[$file] = -not $selected[$file]
        }
    }
    
    foreach ($file in $StandardsFiles) {
        if ($selected[$file]) {
            $SelectedFiles += $file
        }
    }
    
    if ($SelectedFiles.Count -eq 0) {
        Write-ErrorMsg "No files selected."
        exit 1
    }
}

# -----------------------------------------------------------------------------
# Conflict Detection and Backup
# -----------------------------------------------------------------------------

$ProfileStandards = "$BaseDir\profiles\$TargetProfile\standards"
$Conflicts = @()

foreach ($file in $SelectedFiles) {
    if (Test-Path "$ProfileStandards\$file") {
        $Conflicts += $file
    }
}

if ($Conflicts.Count -gt 0) {
    if ($Overwrite) {
        # Backup and overwrite
        Backup-Files $Conflicts
    } else {
        Write-Host ""
        Write-WarningMsg "$($Conflicts.Count) file(s) already exist in profile '$TargetProfile':"
        foreach ($file in $Conflicts) {
            Write-Host "    - $file"
        }
        Write-Host ""
        Write-Host "What do you want to do?"
        Write-Host "  1) Overwrite all (with backup)"
        Write-Host "  2) Skip existing files"
        Write-Host "  3) Cancel"
        Write-Host ""
        
        $choice = $null
        while ($true) {
            $ans = Read-Host "Choice (1-3)"
            if ($ans -match "^[123]$") {
                $choice = [int]$ans
                break
            }
            Write-Host "Invalid choice."
        }
        
        if ($choice -eq 1) {
            Backup-Files $Conflicts
        } elseif ($choice -eq 2) {
            $temp = @()
            foreach ($file in $SelectedFiles) {
                if ($Conflicts -notcontains $file) {
                    $temp += $file
                }
            }
            $SelectedFiles = $temp
            if ($SelectedFiles.Count -eq 0) {
                Write-WarningMsg "No files left to sync after skipping conflicts."
                exit 0
            }
        } else {
            Write-ErrorMsg "Cancelled."
            exit 1
        }
    }
}

function Backup-Files ($filesToBackup) {
    if ($filesToBackup.Count -eq 0) { return }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"
    $backupDir = "$ProfileStandards\.backups\$timestamp"
    
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    
    $backupCount = 0
    foreach ($file in $filesToBackup) {
        $source = "$ProfileStandards\$file"
        $dest = "$backupDir\$file"
        
        if (Test-Path $source) {
            $destFolder = Split-Path -Parent $dest
            if (-not (Test-Path $destFolder)) {
                New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
            }
            Copy-Item -Path $source -Destination $dest -Force | Out-Null
            $backupCount++
            Write-VerboseMsg "Backed up: $file"
        }
    }
    
    if ($backupCount -gt 0) {
        Write-Success "Backed up $backupCount file(s) to .backups\$timestamp\"
    }
}

# -----------------------------------------------------------------------------
# Execute Sync
# -----------------------------------------------------------------------------

Write-Host ""
Write-Status "Sync summary:"
Write-Host "  Profile: $TargetProfile"
Write-Host "  Files to sync: $($SelectedFiles.Count)"
Write-Host ""

$syncCount = 0
foreach ($file in $SelectedFiles) {
    $source = "$ProjectStandardsDir\$file"
    $dest = "$ProfileStandards\$file"
    
    $destFolder = Split-Path -Parent $dest
    if (-not (Test-Path $destFolder)) {
        New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
    }
    
    Copy-Item -Path $source -Destination $dest -Force | Out-Null
    $syncCount++
    Write-VerboseMsg "Synced: $file"
}

Write-Success "Synced $syncCount file(s) to profile '$TargetProfile'"
Write-Host ""
