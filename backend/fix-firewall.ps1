# Quick Firewall Fix - Run in PowerShell AS ADMINISTRATOR

# This adds a firewall rule to allow incoming connections to port 5000
New-NetFirewallRule `
    -DisplayName "GreenGuard Backend Server" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5000 `
    -Action Allow `
    -Profile Any

Write-Host "✓ Firewall rule created! Now restart your backend server." -ForegroundColor Green
