# alpine-wsl-setup.ps1
# Script to install and configure Alpine Linux on WSL2
# Creates a minimal Alpine instance with zsh, doas, and shadow

param(
    [string]$InstallPath = "C:\WSL\Alpine",
    [string]$DistroName = "Alpine",
    [string]$AlpineVersion = "3.22.1"
)

Write-Host "=== Alpine Linux WSL2 Setup Script ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create directories
Write-Host "[1/6] Creating directories..." -ForegroundColor Yellow
$downloadPath = Join-Path $InstallPath "downloads"
$installDir = Join-Path $InstallPath "install"

New-Item -ItemType Directory -Path $downloadPath -Force | Out-Null
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

# Step 2: Download Alpine minirootfs
Write-Host "[2/6] Downloading Alpine Linux minirootfs v$AlpineVersion..." -ForegroundColor Yellow
$tarballUrl = "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-minirootfs-$AlpineVersion-x86_64.tar.gz"
$checksumUrl = "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-minirootfs-$AlpineVersion-x86_64.tar.gz.sha256"
$tarballPath = Join-Path $downloadPath "alpine-minirootfs.tar.gz"
$checksumPath = Join-Path $downloadPath "alpine-minirootfs.tar.gz.sha256"

try {
    Invoke-WebRequest -Uri $tarballUrl -OutFile $tarballPath -ErrorAction Stop
    Invoke-WebRequest -Uri $checksumUrl -OutFile $checksumPath -ErrorAction Stop
    Write-Host "  ✓ Download complete" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Download failed: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Verify checksum
Write-Host "[3/6] Verifying checksum..." -ForegroundColor Yellow
$downloadHash = (Get-FileHash $tarballPath -Algorithm SHA256).Hash.ToLower()
$expectedHash = (Get-Content $checksumPath).Split()[0]

if ($downloadHash -eq $expectedHash) {
    Write-Host "  ✓ Checksum verified" -ForegroundColor Green
} else {
    Write-Host "  ✗ Checksum mismatch! File may be corrupted." -ForegroundColor Red
    Write-Host "    Expected: $expectedHash" -ForegroundColor Red
    Write-Host "    Got:      $downloadHash" -ForegroundColor Red
    exit 1
}

# Step 4: Import into WSL2
Write-Host "[4/6] Importing Alpine into WSL2..." -ForegroundColor Yellow
$existingDistro = wsl --list --quiet | Where-Object { $_ -eq $DistroName }
if ($existingDistro) {
    Write-Host "  ⚠ Distribution '$DistroName' already exists." -ForegroundColor Yellow
    $response = Read-Host "  Do you want to overwrite it? (yes/no)"
    if ($response -eq "yes") {
        Write-Host "  Unregistering existing distribution..." -ForegroundColor Yellow
        wsl --unregister $DistroName
    } else {
        Write-Host "  Aborted." -ForegroundColor Red
        exit 1
    }
}

wsl --import $DistroName $installDir $tarballPath
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Import successful" -ForegroundColor Green
} else {
    Write-Host "  ✗ Import failed" -ForegroundColor Red
    exit 1
}

# Step 5: Configure Alpine (install packages)
Write-Host "[5/6] Configuring Alpine (updating and installing packages)..." -ForegroundColor Yellow
Write-Host "  This may take a few minutes..." -ForegroundColor Gray

# Run configuration commands in Alpine
wsl -d $DistroName -u root -- sh -c @"
apk update && \
apk upgrade && \
apk add zsh doas shadow
"@

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Configuration complete" -ForegroundColor Green
} else {
    Write-Host "  ✗ Configuration failed" -ForegroundColor Red
    exit 1
}

# Step 6: Export backup
Write-Host "[6/6] Creating backup tar file..." -ForegroundColor Yellow
$backupPath = Join-Path $InstallPath "alpine-wsl2-configured.tar"
wsl --export $DistroName $backupPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Backup created: $backupPath" -ForegroundColor Green
} else {
    Write-Host "  ✗ Backup creation failed" -ForegroundColor Red
    exit 1
}

# Summary
Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Distribution Name: $DistroName" -ForegroundColor White
Write-Host "Installation Path: $installDir" -ForegroundColor White
Write-Host "Backup File:       $backupPath" -ForegroundColor White
Write-Host ""
Write-Host "To launch Alpine:" -ForegroundColor Yellow
Write-Host "  wsl -d $DistroName" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Launch Alpine and create a user account" -ForegroundColor White
Write-Host "  2. Configure doas permissions" -ForegroundColor White
Write-Host "  3. Set default user in /etc/wsl.conf" -ForegroundColor White
Write-Host ""
Write-Host "For detailed instructions, see the README.md" -ForegroundColor Gray
