# Quick Start - GreenGuard Backend Production Setup

## 🚀 **IMMEDIATE SETUP (5 Minutes)**

### Step 1: Verify MongoDB Atlas Connection String

Your connection string:
```
mongodb+srv://Vedant4233:Vedan%4040206@greenguard-cluster.5arml6k.mongodb.net/greenguard?retryWrites=true&w=majority
```

**Note:** The `@` symbol in password is URL-encoded as `%40` ✅

### Step 2: Start the Server

```bash
cd backend
npm install
npm start
```

### Step 3: Verify Success

Look for this output:
```
============================================================
🚀 GreenGuard Backend Server Started Successfully!
============================================================
✓ Environment: production
✓ Server running on port 5000
✓ Accessible locally: http://localhost:5000
✓ Health check: http://localhost:5000/api/health
============================================================

============================================================
✓ MongoDB Atlas Connected Successfully!
✓ Database: greenguard
============================================================
```

### Step 4: Test Health Endpoint

Open browser:
```
http://localhost:5000/api/health
```

Should show:
```json
{"status":"ok","service":"greenguard-backend"}
```

### Step 5: Test Plant Creation

Using curl:
```bash
curl -X POST http://localhost:5000/api/plants \
  -F "plantName=Test Plant" \
  -F "latitude=20.5937" \
  -F "longitude=78.9629" \
  -F "status=Healthy"
```

Expected response:
```json
{
  "success": true,
  "plant": {
    "id": "...",
    "plantName": "Test Plant",
    ...
  }
}
```

---

## 🔧 **IF MONGODB CONNECTION FAILS**

### Check 1: Network Access in Atlas

1. Go to https://cloud.mongodb.com
2. Select your cluster
3. Network Access → Add IP Address
4. Click "Allow Access from Anywhere" (0.0.0.0/0)
5. Confirm

### Check 2: Credentials

Verify in `.env`:
```env
MONGO_URI=mongodb+srv://Vedant4233:Vedan%4040206@greenguard-cluster.5arml6k.mongodb.net/greenguard?retryWrites=true&w=majority
```

### Check 3: Database User

In MongoDB Atlas:
- Database Access tab
- Ensure user `Vedant4233` exists
- Password should match the one in connection string

---

## 📱 **FLUTTER APP INTEGRATION**

### For Local Testing

Update `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://10.3.51.253:5000/api';
// OR use ADB reverse:
static const String baseUrl = 'http://127.0.0.1:5000/api';
```

### For Production (After Render Deploy)

Update to:
```dart
static const String baseUrl = 'https://your-app-name.onrender.com/api';
```

---

## ☁️ **DEPLOY TO RENDER (Quick)**

### 1. Push to GitHub
```bash
git init
git add .
git commit -m "Production ready backend"
git remote add origin https://github.com/yourusername/greenguard-backend.git
git push -u origin main
```

### 2. Deploy on Render.com

1. Login to https://render.com
2. New + → Web Service
3. Connect repository
4. Configure:
   - **Name**: greenguard-backend
   - **Root Directory**: backend
   - **Build Command**: npm install
   - **Start Command**: npm start
5. Add environment variables (copy from `.env`)
6. Deploy!

### 3. Update Flutter App

After deployment:
```dart
static const String baseUrl = 'https://greenguard-backend.onrender.com/api';
```

---

## 🎯 **SUCCESS INDICATORS**

### Backend Logs Show:
```
=== Plant Creation Request ===
Incoming plant request: { ... }
✓ Plant created successfully: 67890abcdef
============================
```

### MongoDB Compass Shows:
- Connected to Atlas cluster
- `greenguard` database exists
- `plants` collection has documents
- Documents have proper structure

### Flutter App Shows:
- No timeout errors
- Success message: "Plant saved."
- Plants appear in list
- Photos load correctly

---

## 🆘 **QUICK TROUBLESHOOTING**

| Problem | Solution |
|---------|----------|
| "MongoDB connection error" | Check Atlas Network Access (0.0.0.0/0) |
| "Timeout creating plant" | Check firewall allows port 5000 |
| "Cannot find module" | Run `npm install` |
| Port already in use | Change PORT in `.env` |
| Photos not loading | Check `/uploads` folder exists |

---

## ✅ **CHECKLIST**

Before testing with Flutter app:

- [ ] Server starts without errors
- [ ] MongoDB Atlas connected
- [ ] Health check returns OK
- [ ] Can create plant via curl
- [ ] Can fetch plants via browser
- [ ] Logs show detailed output
- [ ] No crash on errors
- [ ] Uploads folder exists
- [ ] CORS enabled
- [ ] Environment variables set

---

## 🎉 **READY TO GO!**

Your backend is now:
✅ Connected to MongoDB Atlas  
✅ Configured for production  
✅ Ready for deployment  
✅ Optimized for performance  

**Start server and test!**
```bash
npm start
```

Then run your Flutter app and create a plant! 🌿
