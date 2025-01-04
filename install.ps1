# PowerShell script to install CyberPAM Agent
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

    # Create destination directory in user's profile
    $installDir = "$env:USERPROFILE\.cyberpamagent"
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null

    # Copy the exe
    Write-Host "Installing CyberPAM Agent to $installDir..." -ForegroundColor Blue
    Copy-Item -Path $exePath.FullName -Destination "$installDir\cyberpamagent.exe" -Force

    # Add to PATH if not already there
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$installDir*") {
        Write-Host "Adding CyberPAM Agent to PATH..." -ForegroundColor Blue
        [Environment]::SetEnvironmentVariable(
            "Path",
            "$userPath;$installDir",
            "User"
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