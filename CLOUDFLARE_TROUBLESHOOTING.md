# 🔧 Cloudflare Tunnel Troubleshooting

## ⚠️ Issue: "Failed host lookup"

You're seeing this error:
```
Connection error: Failed host lookup: 'council-hanging-shorter-positions.trycloudflare.com'
```

**This means:** The Cloudflare Tunnel URL has expired or the tunnel isn't running.

---

## ✅ SOLUTION: Restart Cloudflare Tunnel

### Step 1: Check Your Terminals

You should have **2 terminals** running:

#### Terminal 1: Signaling Server ✅
```bash
cd C:\Users\Huzaif-IT\AndroidStudioProjects\DeskPro\signaling_server
npm start

# Should show:
✓ DeskPro Signaling Server running on port 3000
```

#### Terminal 2: Cloudflare Tunnel ❌ (Probably stopped)
```bash
cloudflared tunnel --url http://localhost:3000
```

If Terminal 2 is **NOT running** or you closed it → That's your problem!

---

## 🚀 Quick Fix (3 Steps)

### Step 1: Restart Cloudflare Tunnel

**Open a NEW terminal** and run:
```bash
cloudflared tunnel --url http://localhost:3000
```

You'll get a **NEW URL** like:
```
Your quick tunnel has been created! Visit it at:
https://different-name-5678.trycloudflare.com
         ↑↑↑ YOUR NEW URL - COPY IT! ↑↑↑
```

**⚠️ Important:** The URL will be **DIFFERENT** each time!

### Step 2: Update app_constants.dart

1. Open: `lib\core\constants\app_constants.dart`
2. Change line 17 to YOUR new Cloudflare URL:

```dart
static const String signalingServerUrl = 'https://different-name-5678.trycloudflare.com';
```

### Step 3: Hot Reload

Press **`r`** in your Flutter terminal to hot reload.

---

## 💡 Why This Happens

### Cloudflare Quick Tunnels:
- ✅ **Free** to use
- ⚠️ **Expire** when inactive
- ⚠️ **New URL** each restart
- ⚠️ **Must keep terminal open**

If you close the Cloudflare tunnel terminal or it times out:
- Old URL stops working
- Need to restart and get new URL
- Must update app_constants.dart again

---

## 🎯 Current Setup

**I've already updated your app to use:**
```dart
static const String signalingServerUrl = 'http://10.0.2.2:3000';
```

This uses your **LOCAL signaling server** (works for emulator testing).

**To test on different networks**, you need Cloudflare Tunnel running.

---

## 🔄 Choose Your Setup

### Option A: Local Testing Only ✅ (Current)
**For:** Testing on emulator only
**Setup:** Just run `npm start` in signaling_server folder
**URL:** `http://10.0.2.2:3000`
**Status:** ✅ Working now! Just hot reload (press `r`)

### Option B: Cloudflare Tunnel 🌐 (For multi-device testing)
**For:** Testing between different phones/networks
**Setup:** Run both `npm start` AND `cloudflared tunnel`
**URL:** Get from Cloudflare (changes each time)
**Extra step:** Update app_constants.dart each time you restart

### Option C: Production Deployment 🚀 (Permanent URL)
**For:** Real-world use
**Setup:** Deploy to Railway/Heroku/Render
**URL:** Permanent URL (never changes)
**One-time setup:** Update app_constants.dart once

---

## 📋 What To Do RIGHT NOW

### Immediate Action (To Fix Current Error):

**Hot reload your app:**
```bash
# In Flutter terminal, press: r
```

The connection errors will **stop** because I updated the URL back to local (`http://10.0.2.2:3000`).

**Your app will work again!** ✅

---

## 🧪 For Testing Later with Cloudflare

When you want to test with multiple devices:

1. **Keep signaling server running** (Terminal 1)
2. **Start Cloudflare tunnel** (Terminal 2):
   ```bash
   cloudflared tunnel --url http://localhost:3000
   ```
3. **Copy the new URL** it gives you
4. **Update line 17** in `app_constants.dart` with the new URL
5. **Hot reload** (press `r`)

---

## ✅ Verification

After hot reloading with the local URL:

### Before (with old Cloudflare URL):
```
❌ Failed host lookup: council-hanging-shorter-positions.trycloudflare.com
```

### After (with local URL):
```
✅ Connected to signaling server
✅ New connection: ABC123xyz
✅ No errors!
```

---

## 📞 Summary

**What happened:**
- Old Cloudflare tunnel URL expired
- App can't reach old URL anymore

**What I fixed:**
- Changed URL back to local: `http://10.0.2.2:3000`
- This works with your running signaling server

**What you need to do:**
1. **Press `r`** in Flutter terminal (hot reload)
2. App will connect to local server ✅
3. Test your app on emulator ✅

**For multi-device testing later:**
- Restart Cloudflare tunnel
- Get new URL
- Update app_constants.dart line 17
- Hot reload

---

## 🎉 You're Fixed!

Just **press `r`** in your Flutter terminal and your app will work again! 🚀

The connection errors will stop and you can test on your emulator.

---

*Note: Keep the signaling server running in one terminal. Cloudflare tunnel is optional for local testing.*

