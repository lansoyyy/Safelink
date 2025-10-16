# Firebase Realtime Database Setup for IoT Alerts

## Overview
This document explains how the SafeLink app integrates with Firebase Realtime Database to receive real-time alerts from IoT devices.

## Database Structure

```
safelink-60c18 (Firebase Project)
└── alerts/
    ├── {alert_id_1}/
    │   ├── alertType: "Emergency" | "Warning"
    │   ├── isActive: true | false
    │   ├── location: "Block A, Street 5, Alsea Homes"
    │   ├── latitude: 14.5995
    │   ├── longitude: 120.9842
    │   ├── dateTime: "2024-10-16T10:30:45.000Z"
    │   ├── details: "Fire detected in residential area..."
    │   └── imageUrl: "" (empty string or URL)
    │
    ├── {alert_id_2}/
    │   └── ... (same structure)
    │
    └── {alert_id_3}/
        └── ... (same structure)
```

## Field Descriptions

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `alertType` | String | Type of alert | "Emergency" or "Warning" |
| `isActive` | Boolean | Whether alert is currently active | `true` or `false` |
| `location` | String | Human-readable location | "Block A, Street 5, Alsea Homes" |
| `latitude` | Double | GPS latitude coordinate | `14.5995` |
| `longitude` | Double | GPS longitude coordinate | `120.9842` |
| `dateTime` | String (ISO 8601) | When alert was triggered | "2024-10-16T10:30:45.000Z" |
| `details` | String | Detailed description | "Fire detected in residential area..." |
| `imageUrl` | String | URL to alert image (optional) | "" or "https://..." |

## How It Works

### 1. Real-time Listening
The app automatically listens to Firebase Realtime Database for new alerts:

```dart
// In dashboard_screen.dart
void _listenToAlerts() {
  _alertSubscription = _alertService.getActiveAlertsStream().listen((alerts) {
    // Updates UI automatically when new alerts arrive
  });
}
```

### 2. Alert Display
- **Active Alerts**: Shown immediately on dashboard with red (Emergency) or orange (Warning) styling
- **Alert Details**: Location, time, and description displayed
- **Map Integration**: Coordinates used to show alert location on map

### 3. Alert Clearing
When officer clears an alert:
1. Confirmation dialog appears
2. Upon confirmation, `isActive` is set to `false` in Firebase
3. Alert disappears from active alerts list
4. Alert is archived in history

## IoT Device Integration

### Trigger for Populating Data

**Option 1: IoT Device Direct Write**
Your IoT device (e.g., ESP32, Raspberry Pi) can write directly to Firebase Realtime Database:

```javascript
// Example: Node.js/JavaScript on IoT device
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccountKey),
  databaseURL: "https://safelink-60c18-default-rtdb.firebaseio.com"
});

// When sensor detects emergency
function triggerAlert() {
  const alertData = {
    alertType: "Emergency",
    isActive: true,
    location: "Block A, Street 5, Alsea Homes",
    latitude: 14.5995,
    longitude: 120.9842,
    dateTime: new Date().toISOString(),
    details: "Fire detected by smoke sensor #12",
    imageUrl: ""
  };

  // Push to Firebase
  admin.database().ref('alerts').push(alertData);
}
```

**Option 2: IoT Device via HTTP/REST API**
IoT device sends HTTP POST request to Firebase REST API:

```python
# Example: Python on Raspberry Pi
import requests
import json
from datetime import datetime

def send_alert_to_firebase():
    url = "https://safelink-60c18-default-rtdb.firebaseio.com/alerts.json"
    
    alert_data = {
        "alertType": "Emergency",
        "isActive": True,
        "location": "Block A, Street 5, Alsea Homes",
        "latitude": 14.5995,
        "longitude": 120.9842,
        "dateTime": datetime.utcnow().isoformat() + "Z",
        "details": "Motion detected in restricted area",
        "imageUrl": ""
    }
    
    response = requests.post(url, json=alert_data)
    return response.json()
```

**Option 3: IoT Device via MQTT + Cloud Function**
1. IoT device publishes to MQTT broker
2. Cloud Function subscribes to MQTT topic
3. Cloud Function writes to Firebase Realtime Database

```javascript
// Cloud Function example
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.handleIoTAlert = functions.https.onRequest((req, res) => {
  const alertData = req.body;
  
  admin.database().ref('alerts').push(alertData)
    .then(() => res.status(200).send('Alert created'))
    .catch(err => res.status(500).send(err));
});
```

## Testing with Sample Data

### Method 1: Using the App (Easiest)
1. Open the SafeLink app
2. Navigate to Dashboard
3. Click the **"Add Sample Data"** floating action button
4. Sample alerts will be added to Firebase automatically
5. Dashboard will update in real-time

### Method 2: Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `safelink-60c18`
3. Navigate to **Realtime Database**
4. Click on the **+** icon next to the database root
5. Add a new child: `alerts`
6. Click **+** to add a new alert with a generated key
7. Add the following fields:
   ```
   alertType: "Emergency"
   isActive: true
   location: "Block A, Street 5, Alsea Homes"
   latitude: 14.5995
   longitude: 120.9842
   dateTime: "2024-10-16T10:30:45.000Z"
   details: "Test emergency alert"
   imageUrl: ""
   ```

### Method 3: REST API (Postman/cURL)
```bash
curl -X POST \
  'https://safelink-60c18-default-rtdb.firebaseio.com/alerts.json' \
  -H 'Content-Type: application/json' \
  -d '{
    "alertType": "Warning",
    "isActive": true,
    "location": "Block C, Street 12, Alsea Homes",
    "latitude": 14.6010,
    "longitude": 120.9855,
    "dateTime": "2024-10-16T11:00:00.000Z",
    "details": "Suspicious activity detected",
    "imageUrl": ""
  }'
```

## Firebase Realtime Database Rules

For security, configure your database rules:

```json
{
  "rules": {
    "alerts": {
      ".read": "auth != null",
      ".write": "auth != null",
      "$alertId": {
        ".validate": "newData.hasChildren(['alertType', 'isActive', 'location', 'latitude', 'longitude', 'dateTime', 'details', 'imageUrl'])"
      }
    }
  }
}
```

**For IoT Device Access (Service Account):**
```json
{
  "rules": {
    "alerts": {
      ".read": true,
      ".write": true
    }
  }
}
```
⚠️ **Warning**: Open rules are for development only. Use authentication in production.

## App Features

### Real-time Updates
- ✅ Automatic alert detection (no refresh needed)
- ✅ Live dashboard updates
- ✅ Instant notifications
- ✅ Real-time alert status changes

### Alert Management
- ✅ View active alerts
- ✅ Clear/acknowledge alerts
- ✅ View alert history
- ✅ Map visualization
- ✅ Alert details display

### Data Flow
```
IoT Device → Firebase Realtime Database → SafeLink App
     ↓                    ↓                      ↓
  Sensor Data      Real-time Sync        Live Dashboard
  Emergency        Alert Storage         Notifications
  Detection        Data Persistence      Officer Response
```

## Next Steps

1. **Run the app**: `flutter pub get` then `flutter run`
2. **Test with sample data**: Click "Add Sample Data" button in dashboard
3. **Configure Firebase Rules**: Set appropriate security rules
4. **Connect IoT Device**: Use one of the integration methods above
5. **Monitor Alerts**: Watch dashboard update in real-time

## Troubleshooting

### No alerts showing?
- Check Firebase Console to verify data exists
- Ensure `isActive` is set to `true`
- Verify Firebase Realtime Database URL in `firebase_options.dart`
- Check internet connection

### Alerts not updating?
- Verify stream subscription is active
- Check Firebase rules allow read access
- Ensure app has proper Firebase configuration

### IoT device can't write?
- Verify Firebase database URL
- Check authentication credentials
- Ensure database rules allow write access
- Test with Firebase Console first

## Support

For issues or questions:
- Check Firebase Console logs
- Review app debug output
- Verify database structure matches specification
- Test with sample data first before connecting IoT devices
