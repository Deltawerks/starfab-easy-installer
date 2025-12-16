<#
.SYNOPSIS
    Automated launcher and fixer for StarFab.
    
.DESCRIPTION
    This script sets up a local Python environment, installs StarFab, 
    and applies the "multiple datacores" fix by installing the development 
    version of scdatatools.
    
.NOTES
    Author: Gemini
    Date: 2025-12-15
#>

$ErrorActionPreference = "Stop"

trap {
    Write-Host "AN ERROR OCCURRED: $_" -ForegroundColor Red
    Pause
    exit 1
}
$ScriptDir = $PSScriptRoot
$VenvDir = Join-Path $ScriptDir ".venv"
$PythonExec = "python"
$PipExec = Join-Path $VenvDir "Scripts/pip.exe"
$StarFabExec = Join-Path $VenvDir "Scripts/starfab.exe"

# ANSI Colors
$Green = "[32m"
$Yellow = "[33m"
$Red = "[31m"
$Reset = "[0m"

function Write-Log {
    param([string]$Message, [string]$Color = $Reset)
    Write-Host "$([char]27)$Color$Message$([char]27)$Reset"
}

function Test-Command {
    param([string]$Name)
    try {
        Get-Command $Name -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

Write-Log "=== StarFab Zero-Config Launcher ===" $Green

# 1. Check for Git
if (-not (Test-Command "git")) {
    Write-Log "Error: Git is not installed or not in your PATH." $Red
    Write-Log "Please install Git for Windows from: https://git-scm.com/download/win" $Yellow
    Write-Log "After installing, please run this script again." $Yellow
    Pause
    exit 1
}

# 2. Check for Python 3.10
# We specifically need 3.10 for StarFab compatibility
Write-Log "Checking for Python 3.10..." $Yellow
try {
    $PyVersion = & $PythonExec --version 2>&1
    if ($PyVersion -match "3\.10") {
        Write-Log "Found $PyVersion" $Green
    } else {
        # Try finding a specific 3.10 launcher or winget
        Write-Log "Default python is $PyVersion. Looking for py -3.10..." $Yellow
        if (Test-Command "py") {
                $pyResult = Start-Process -FilePath "py" -ArgumentList "-3.10", "--version" -PassThru -NoNewWindow -Wait
                if ($pyResult.ExitCode -ne 0) {
                    throw "Python 3.10 not found via launcher."
                }
                $PythonExec = "py -3.10"
                Write-Log "Found Python 3.10 via launcher." $Green
        } else {
            throw "Python 3.10 not found."
        }
    }
} catch {
    Write-Log "Python 3.10 requirement not met." $Red
    Write-Log "StarFab requires Python 3.10. Attempting to install via Winget..." $Yellow
    if (Test-Command "winget") {
        try {
            winget install -e --id Python.Python.3.10 --accept-source-agreements --accept-package-agreements
            Write-Log "Python 3.10 installed. Please restart this script." $Green
            Pause
            exit 0
        } catch {
            Write-Log "Failed to install Python 3.10 via Winget." $Red
        }
    }
    Write-Log "Please manually install Python 3.10 from python.org." $Red
    Pause
    exit 1
}

# 3. Create Virtual Environment
if (-not (Test-Path $VenvDir)) {
    Write-Log "Creating virtual environment in .venv..." $Yellow
    # Split command string if using "py -3.10"
    $PyCmd = $PythonExec -split " "
    & $PyCmd[0] $PyCmd[1] -m venv $VenvDir
    if (-not $?) {
        Write-Log "Failed to create virtual environment." $Red
        Pause
        exit 1
    }
    Write-Log "Virtual environment created." $Green
} else {
    Write-Log "Virtual environment already exists." $Green
}

# 4. Install/Update StarFab and Fix
Write-Log "Updating dependencies..." $Yellow

# Upgrade pip to ensure we can build from pyproject.toml
& $PythonExec -m pip install --upgrade pip --quiet

# Install missing dependency 'line_profiler' which seems to be required by update but missing from pyproject.toml
Write-Log "Installing missing dependency..." $Yellow
& $PipExec install line_profiler --quiet

# Install/Update StarFab core from GitLab
# (PyPI release seems to be missing or broken, so we use the source)
Write-Log "Installing StarFab from GitLab..." $Yellow
& $PipExec install -U "git+https://gitlab.com/scmodding/tools/starfab.git" --quiet
if (-not $?) {
    Write-Log "Failed to install StarFab from GitLab." $Red
    Pause
    exit 1
}

# Apply the FIX: Overwrite scdatatools with the devel branch
Write-Log "Applying 'Multiple Datacores' Fix..." $Yellow
& $PipExec install -U "git+https://gitlab.com/scmodding/frameworks/scdatatools.git@devel" --quiet
if (-not $?) {
    Write-Log "Failed to apply fix." $Red
    Pause
    exit 1
}

# 5. Download Converter Tools (cgf-converter and texconv)
$ContribDir = Join-Path $VenvDir "Lib/site-packages/starfab/contrib"
if (-not (Test-Path $ContribDir)) {
    New-Item -ItemType Directory -Path $ContribDir -Force | Out-Null
}

$CgfConverterPath = Join-Path $ContribDir "cgf-converter.exe"
$TexconvPath = Join-Path $ContribDir "texconv.exe"

# Download cgf-converter.exe if not present
if (-not (Test-Path $CgfConverterPath)) {
    Write-Log "Downloading cgf-converter.exe (this may take a minute)..." $Yellow
    $CgfConverterUrl = "https://github.com/Markemp/Cryengine-Converter/releases/download/v1.7.1/cgf-converter.exe"
    try {
        Invoke-WebRequest -Uri $CgfConverterUrl -OutFile $CgfConverterPath -UseBasicParsing
        Write-Log "cgf-converter.exe downloaded successfully." $Green
    } catch {
        Write-Log "Warning: Failed to download cgf-converter.exe. Model conversion may not work." $Yellow
    }
} else {
    Write-Log "cgf-converter.exe already present." $Green
}

# Download texconv.exe if not present
if (-not (Test-Path $TexconvPath)) {
    Write-Log "Downloading texconv.exe..." $Yellow
    $TexconvUrl = "https://github.com/microsoft/DirectXTex/releases/download/jul2025/texconv.exe"
    try {
        Invoke-WebRequest -Uri $TexconvUrl -OutFile $TexconvPath -UseBasicParsing
        Write-Log "texconv.exe downloaded successfully." $Green
    } catch {
        Write-Log "Warning: Failed to download texconv.exe. Texture conversion may not work." $Yellow
    }
} else {
    Write-Log "texconv.exe already present." $Green
}

Write-Log "Setup complete!" $Green

# 5. Run StarFab
Write-Log "Launching StarFab..." $Green
Write-Log "---------------------------------------------------"
# Run directly so we can see any startup errors
Write-Log "Starting StarFab module..." $Yellow
$VenvPython = Join-Path $VenvDir "Scripts/python.exe"
& $VenvPython -m starfab
if (-not $?) {
    Write-Log "StarFab crashed or exited with an error." $Red
}
Write-Log "---------------------------------------------------"
Pause

