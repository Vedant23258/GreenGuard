# GreenGuard Backend - Firewall Setup Script
# Run this in PowerShell with Administrator privileges

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "GreenGuard Backend - Windows Firewall Configuration" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click on this file and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Running as Administrator... OK" -ForegroundColor Green
Write-Host ""

# Find Node.js path
$nodePath = Get-Command node -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

if (-not $nodePath) {
    Write-Host "ERROR: Node.js not found in PATH!" -ForegroundColor Red
    Write-Host "Please install Node.js first." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Node.js found at: $nodePath" -ForegroundColor Green
Write-Host ""

# Create firewall rule for Node.exe (allows all Node.js apps)
Write-Host "Creating firewall rule for Node.js..." -ForegroundColor Cyan

$ruleName = "GreenGuard Backend (Node.js)"
$existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

if ($existingRule) {
    Write-Host "Rule '$ruleName' already exists. Removing old rule..." -ForegroundColor Yellow
    Remove-NetFirewallRule -DisplayName $ruleName
}

New-NetFirewallRule `
    -DisplayName $ruleName `
    -Direction Inbound `
    -Program $nodePath `
    -Protocol TCP `
    -LocalPort 5000 `
    -Action Allow `
    -Profile Any `
    -Description "Allows incoming connections to Node.js backend server on port 5000"

Write-Host "✓ Firewall rule created successfully!" -ForegroundColor Green
Write-Host ""

# Also create a specific rule for port 5000 as backup
Write-Host "Creating backup firewall rule for port 5000..." -ForegroundColor Cyan

$portRuleName = "GreenGuard Backend (Port 5000)"
$existingPortRule = Get-NetFirewallRule -DisplayName $portRuleName -ErrorAction SilentlyContinue

if ($existingPortRule) {
    Write-Host "Rule '$portRuleName' already exists. Skipping..." -ForegroundColor Yellow
} else {
    New-NetFirewallRule `
        -DisplayName $portRuleName `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort 5000 `
        -Action Allow `
        -Profile Any `
        -Description "Allows incoming TCP connections on port 5000"
    
    Write-Host "✓ Port 5000 firewall rule created successfully!" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Firewall Configuration Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your backend server should now be accessible from other devices." -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Restart your backend server (npm start)" -ForegroundColor White
Write-Host "2. Test from your phone: http://<your-ip>:5000/api/health" -ForegroundColor White
Write-Host "3. Try creating a plant from the Flutter app" -ForegroundColor White
Write-Host ""
Write-Host "Your LAN IP is likely: 10.3.51.253" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"
