# PowerShell script to install CyberPAM Agent

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator. Please restart PowerShell as Administrator." -ForegroundColor Red
    exit 1
}

$ErrorActionPreference = "Stop"

Write-Host "Installing CyberPAM Agent..." -ForegroundColor Blue

# Create temp directory
$tempDir = Join-Path $env:TEMP "cyberpamagent_install"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Download URL
$downloadUrl = "https://raw.githubusercontent.com/RamboRogers/cyberpamagent/master/bins/cyberpamagent-windows-amd64.zip"
$zipPath = Join-Path $tempDir "cyberpamagent.zip"

try {
    # Download the zip file
    Write-Host "Downloading CyberPAM Agent..." -ForegroundColor Blue
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

    # Extract the zip
    Write-Host "Extracting files..." -ForegroundColor Blue
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

    # Find the exe
    $exePath = Get-ChildItem -Path $tempDir -Filter "cyberpamagent.exe" -Recurse | Select-Object -First 1

    # Create destination directory in Program Files
    $installDir = "${env:ProgramFiles}\CyberPAM"
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null

    # Copy the exe
    Write-Host "Installing CyberPAM Agent to $installDir..." -ForegroundColor Blue
    Copy-Item -Path $exePath.FullName -Destination "$installDir\cyberpamagent.exe" -Force

    # Add to PATH if not already there
    $systemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($systemPath -notlike "*$installDir*") {
        Write-Host "Adding CyberPAM Agent to PATH..." -ForegroundColor Blue
        [Environment]::SetEnvironmentVariable(
            "Path",
            "$systemPath;$installDir",
            "Machine"
        )
    }

    Write-Host "CyberPAM Agent installed successfully!" -ForegroundColor Green
    Write-Host "Starting interactive setup..." -ForegroundColor Blue

    # Run the program in interactive mode
    & "$installDir\cyberpamagent.exe"
}
catch {
    Write-Host "Error installing CyberPAM Agent: $_" -ForegroundColor Red
    exit 1
}
finally {
    # Cleanup
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}