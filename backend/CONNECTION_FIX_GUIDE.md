# GreenGuard Backend - Connection Timeout Fix

## Problem
Flutter app shows "Timeout creating plant" when trying to save plants.

## Root Cause
**Windows Firewall is blocking incoming connections from your phone to the laptop.**

The backend server is:
- ✅ Running correctly on port 5000
- ✅ Bound to 0.0.0.0 (all network interfaces)
- ✅ Accessible from localhost (laptop itself)
- ❌ NOT accessible from other devices (phone) due to firewall

---

## SOLUTION 1: Run the Automated Firewall Script (RECOMMENDED)

### Step 1: Open PowerShell as Administrator
1. Press `Win + X`
2. Select "Windows PowerShell (Admin)" or "Terminal (Admin)"

### Step 2: Navigate to backend folder
```powershell
cd C:\Users\mishr\green_guard\backend
```

### Step 3: Run the firewall setup script
```powershell
.\setup-firewall.ps1
```

If you get an execution policy error, run this first:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then run the script again.

### Step 4: Restart backend server
```bash
npm start
```

You should see:
```
============================================================
🚀 GreenGuard Backend Server Started Successfully!
============================================================
✓ Server running on port 5000
✓ Accessible locally: http://localhost:5000
✓ Accessible on network: http://10.3.51.253:5000
============================================================
```

---

## SOLUTION 2: Manual Firewall Rule (Alternative)

### Run in PowerShell AS ADMINISTRATOR:

```powershell
New-NetFirewallRule `
    -DisplayName "GreenGuard Backend" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5000 `
    -Action Allow `
    -Profile Any
```

---

## SOLUTION 3: Quick Test (Temporary)

### Temporarily disable firewall to test:

1. Open Windows Security
2. Firewall & network protection
3. Turn off Domain network firewall
4. Turn off Private network firewall
5. Test the connection
6. **TURN FIREWALL BACK ON!**
7. Then use Solution 1 or 2 for permanent fix

⚠️ **WARNING**: Only disable firewall temporarily for testing!

---

## VERIFICATION STEPS

### Test 1: From Laptop Browser
Open: http://10.3.51.253:5000/api/health

Expected: `{"status":"ok","service":"greenguard-backend"}`

### Test 2: From Phone Browser
Open: http://10.3.51.253:5000/api/health

Expected: Same JSON response

### Test 3: From Flutter App
1. Login to app
2. Register a plant
3. Should succeed without timeout

---

## STILL NOT WORKING? Check these:

### 1. Verify Server Binding
```powershell
netstat -ano | findstr :5000
```

Should show:
```
TCP    0.0.0.0:5000    0.0.0.0:0    LISTENING
```

If it shows `127.0.0.1:5000`, restart the server.

### 2. Check IP Address
```powershell
ipconfig
```

Find your Wi-Fi adapter IPv4 address. If it's different from `10.3.51.253`, update it in:
- `controllers/plantController.js` line 7
- `lib/services/api_service.dart` line 16

### 3. Same Network?
Ensure phone and laptop are on the **same Wi-Fi network**.

### 4. Router Settings
Some routers have "AP Isolation" or "Client Isolation" that prevents devices from talking to each other. Disable it in router settings.

---

## ALTERNATIVE: Use ADB Reverse (USB Only)

If firewall issues persist, use USB tethering instead:

### Step 1: Connect phone via USB
Enable USB debugging on phone.

### Step 2: Setup ADB reverse
```bash
adb reverse tcp:5000 tcp:5000
```

### Step 3: Update Flutter API
In `lib/services/api_service.dart` line 16:
```dart
static const String baseUrl = 'http://127.0.0.1:5000/api';
```

### Step 4: Restart Flutter app
```bash
flutter run
```

This routes phone traffic through USB cable, bypassing firewall entirely.

---

## SUCCESS INDICATORS

When it works, you'll see in Flutter logs:
```
I/flutter: Sending plant creation request to: http://10.3.51.253:5000/api/plants
I/flutter: Response status: 201
I/flutter: Response body: {"success":true,"plant":{...}}
I/flutter: Plant created successfully
```

And in Backend logs:
```
Incoming plant request: { plantName: '...', latitude: '...', ... }
Uploaded file: { filename: '...', ... }
Plant created successfully: 67890abcdef
```

---

## QUICK REFERENCE

| Command | Purpose |
|---------|---------|
| `netstat -ano \| findstr :5000` | Check if server listening |
| `ipconfig` | Find your LAN IP |
| `adb reverse tcp:5000 tcp:5000` | Setup USB tunneling |
| `Get-NetFirewallRule \| Where DisplayName -like "*GreenGuard*"` | Check existing firewall rules |
| `Remove-NetFirewallRule -DisplayName "GreenGuard Backend"` | Remove old firewall rule |

---

## CONTACT / HELP

If still having issues:
1. Check backend logs for errors
2. Check Flutter logs for detailed error messages
3. Verify both devices on same network
4. Try the ADB reverse method as workaround
