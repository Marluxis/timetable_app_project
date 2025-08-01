# Notification Debugging Guide 🔔

## Quick Fix Checklist ✅

If notifications aren't working, follow these steps **in order**:

### 1. **Test Basic Functionality**
   - Open the app
   - Tap the bug icon (🐛) in the top right of the schedule screen
   - Run "1. Show Immediate Test Notification"
   - **Expected**: You should see a notification appear immediately
   - **If this fails**: Check step 2

### 2. **Check Permissions**
   - In the test screen, tap "2. Check Permissions & Status"
   - Look at the console logs (or debugging output)
   - **Required permissions**: All should show "granted"
   - **If permissions denied**: Go to Android Settings > Apps > Study Scheduler > Permissions

### 3. **Test Scheduled Notifications**
   - In the test screen, tap "3. Schedule 1-Minute Test"
   - **IMPORTANT**: Put the app in the background immediately
   - Wait 1 full minute
   - **Expected**: Notification should appear after 1 minute

### 4. **Android Settings Check**
   Go to: **Settings > Apps > Study Scheduler > Notifications**
   - ✅ **Allow notifications**: ON
   - ✅ **Show on lock screen**: ON
   - ✅ **Override Do Not Disturb**: ON

### 5. **Battery Optimization**
   Go to: **Settings > Battery > Battery optimization**
   - Find "Study Scheduler"
   - Set to **"Don't optimize"** or **"Allow"**
   - This is **critical** for scheduled notifications

### 6. **Do Not Disturb Mode**
   - Turn OFF Do Not Disturb during testing
   - Check notification sound/vibration settings

---

## Common Issues & Solutions 🔧

### Issue: "Immediate notifications work, but scheduled ones don't"
**Cause**: Battery optimization or exact alarm permissions
**Solution**:
1. Disable battery optimization for the app
2. Go to Settings > Apps > Special access > Alarms & reminders
3. Enable for Study Scheduler

### Issue: "No notifications at all"
**Cause**: Notification permissions or channel issues
**Solution**:
1. Uninstall and reinstall the app
2. Grant ALL permissions when prompted
3. Test immediate notification first

### Issue: "Notifications appear but no sound/vibration"
**Cause**: Notification importance level or system settings
**Solution**:
1. Go to Settings > Apps > Study Scheduler > Notifications
2. Set notification category to "High importance" or "Urgent"
3. Enable sound and vibration

### Issue: "Notifications work sometimes but not consistently"
**Cause**: Android's aggressive power management
**Solutions**:
1. Add app to "Auto-start" whitelist (varies by manufacturer)
2. Disable adaptive battery for this app
3. Keep app running in background occasionally

---

## Manufacturer-Specific Settings 📱

### Samsung
- **Settings > Apps > Study Scheduler > Battery**
  - Set to "Unrestricted"
- **Settings > Battery and device care > Battery > Background app limits**
  - Remove app from "Sleeping apps" if present

### Xiaomi/MIUI
- **Settings > Apps > Manage apps > Study Scheduler**
  - Battery saver: No restrictions
  - Autostart: Enable
- **Settings > Notifications & Control center > App notifications**
  - Enable all notification types

### OnePlus/OxygenOS
- **Settings > Apps & notifications > Study Scheduler > Battery**
  - Battery optimization: Don't optimize
- **Settings > Battery > Battery optimization > Advanced optimization**
  - Turn off "Optimize battery use"

### Huawei/EMUI
- **Settings > Apps > Study Scheduler > Battery**
  - App launch: Manage manually
  - Enable: Auto-launch, Secondary launch, Run in background

---

## Testing Workflow 🧪

### Phase 1: Basic Test
1. Open notification test screen
2. Run immediate test → Should work
3. Check permissions → All should be granted

### Phase 2: Scheduled Test
1. Run 1-minute test
2. **Put app in background** (home button)
3. Wait and observe
4. Check "Pending notifications" to verify it was scheduled

### Phase 3: Real-World Test
1. Create a test study session for 2 minutes from now
2. Set a 1-minute reminder
3. Background the app
4. Wait for notification

### Phase 4: Custom Message Test
1. Run custom message test
2. Verify different notification ID works
3. Test with longer messages

---

## Debug Console Output 📋

When testing, watch for these console messages:

### ✅ **Good Signs**:
```
✅ Notification service initialized successfully
✅ Notification channel created: study_scheduler_channel_id
📱 Notification permission: granted
⏰ Exact alarm permission: granted
🔋 Battery optimization exemption: granted
✅ Notification scheduled successfully
📋 Total pending notifications: 1
```

### ❌ **Warning Signs**:
```
❌ Notification permissions not granted
❌ Failed to schedule notification: [error]
⚠️ Cannot schedule notification for past time
📋 Total pending notifications: 0
```

---

## Advanced Debugging 🔍

### 1. **Check Pending Notifications**
   - Use "Check Pending" button in test screen
   - Should show scheduled notifications
   - If empty when notifications scheduled = problem

### 2. **ADB Debugging** (for developers)
   ```bash
   # Check if notifications are enabled
   adb shell cmd notification allow_listener com.example.study_scheduler

   # Check notification channels
   adb shell dumpsys notification | grep study_scheduler
   ```

### 3. **Android Logs**
   ```bash
   # Filter for notification logs
   adb logcat | grep -i notification
   
   # Filter for our app
   adb logcat | grep study_scheduler
   ```

---

## When All Else Fails 🆘

### Last Resort Solutions:

1. **Complete Reset**:
   - Uninstall app completely
   - Restart phone
   - Reinstall app
   - Grant ALL permissions immediately

2. **Test on Different Device**:
   - Try on another Android device
   - Different manufacturer if possible

3. **Check Android Version**:
   - Android 12+ has stricter notification policies
   - Some features may not work on very old Android versions

4. **Logcat Analysis**:
   - Connect to computer with ADB
   - Monitor logs while testing notifications
   - Look for specific error messages

---

**Remember**: Android notification systems vary significantly between manufacturers and versions. Some devices are more aggressive about power management than others. The most common issue is battery optimization preventing scheduled notifications. 