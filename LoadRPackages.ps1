# Check script is running as Administrator
function Test-IsAdministrator {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Find R executable dynamically
function Find-RExecutable {
    # 1) Check R_HOME environment variable
    if ($env:R_HOME) {
        $candidate = Join-Path $env:R_HOME 'bin\R.exe'
        if (Test-Path $candidate) { return $candidate }
    }

    # 2) Check if 'R' is on PATH
    $cmd = Get-Command R -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Path) { return $cmd.Path }

    # 3) Check registry entries (64-bit and 32-bit locations)
    $regKeys = @('HKLM:\SOFTWARE\R-core\R','HKLM:\SOFTWARE\WOW6432Node\R-core\R')
    foreach ($key in $regKeys) {
        if (Test-Path $key) {
            $props = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
            if ($props -and $props.InstallPath) {
                $candidate = Join-Path $props.InstallPath 'bin\R.exe'
                if (Test-Path $candidate) { return $candidate }
            }
        }
    }

    # 4) Search Program Files folders for R installations and pick the newest
    $programRoots = @($env:ProgramFiles,  ${env:ProgramFiles(x86)} ) | Where-Object { $_ }
    foreach ($root in $programRoots) {
        $rRoot = Join-Path $root 'R'
        if (Test-Path $rRoot) {
            $subdirs = Get-ChildItem -Path $rRoot -Directory -ErrorAction SilentlyContinue |
                       Where-Object { $_.Name -match '^R-\d' } |
                       Sort-Object Name -Descending
            foreach ($d in $subdirs) {
                $candidate = Join-Path $d.FullName 'bin\R.exe'
                if (Test-Path $candidate) { return $candidate }
            }
        }
    }

    return $null
}

if (-not (Test-IsAdministrator)) {
    Write-Error "This script must be run as Administrator. Please re-run in an elevated PowerShell session."
    exit 1
}

# Determine R executable path
$rPath = Find-RExecutable

# Check that the R executable exists
if (-not (Test-Path $rPath)) {
    Write-Error "R executable not found. Please ensure R is installed and either on PATH or R_HOME is set."
    exit 1
}

# Path to the packages folder
$packagesFolder = ".\packages"

# Get all .zip files in the folder
$packageZips = Get-ChildItem -Path $packagesFolder -Filter "*.zip" -File -ErrorAction SilentlyContinue

# If no zip files found, inform and exit
if (-not $packageZips -or $packageZips.Count -eq 0) {
    Write-Output "No package .zip files found in '$packagesFolder'. Nothing to install."
    exit 0
}

# Loop through each zip and install
foreach ($zip in $packageZips) {
    $zipPath = $zip.FullName
    Write-Output "Installing $($zip.Name)..."
    Start-Process -FilePath $rPath -ArgumentList "CMD INSTALL `"$zipPath`"" -NoNewWindow -Wait
}
