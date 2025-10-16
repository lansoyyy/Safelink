import 'package:firebase_database/firebase_database.dart';
import 'package:safelink/models/alert_model.dart';

class AlertService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Reference to alerts node
  DatabaseReference get alertsRef => _database.child('alerts');

  // Stream of all active alerts
  Stream<List<AlertModel>> getActiveAlertsStream() {
    return alertsRef.onValue.map((event) {
      final List<AlertModel> alerts = [];
      
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          if (value is Map) {
            final alert = AlertModel.fromMap(key, value);
            if (alert.isActive) {
              alerts.add(alert);
            }
          }
        });
        
        // Sort by date (newest first)
        alerts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      }
      
      return alerts;
    });
  }

  // Stream of all alerts (including inactive)
  Stream<List<AlertModel>> getAllAlertsStream() {
    return alertsRef.onValue.map((event) {
      final List<AlertModel> alerts = [];
      
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          if (value is Map) {
            alerts.add(AlertModel.fromMap(key, value));
          }
        });
        
        // Sort by date (newest first)
        alerts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      }
      
      return alerts;
    });
  }

  // Get a single alert by ID
  Future<AlertModel?> getAlertById(String alertId) async {
    try {
      final snapshot = await alertsRef.child(alertId).get();
      
      if (snapshot.exists && snapshot.value != null) {
        return AlertModel.fromMap(
          alertId,
          snapshot.value as Map<dynamic, dynamic>,
        );
      }
      return null;
    } catch (e) {
      print('Error getting alert: $e');
      return null;
    }
  }

  // Create a new alert (for testing/IoT device simulation)
  Future<String?> createAlert(AlertModel alert) async {
    try {
      final newAlertRef = alertsRef.push();
      await newAlertRef.set(alert.toMap());
      return newAlertRef.key;
    } catch (e) {
      print('Error creating alert: $e');
      return null;
    }
  }

  // Update alert status (mark as inactive/resolved)
  Future<bool> updateAlertStatus(String alertId, bool isActive) async {
    try {
      await alertsRef.child(alertId).update({
        'isActive': isActive,
      });
      return true;
    } catch (e) {
      print('Error updating alert status: $e');
      return false;
    }
  }

  // Clear/resolve an alert
  Future<bool> clearAlert(String alertId) async {
    return await updateAlertStatus(alertId, false);
  }

  // Delete an alert
  Future<bool> deleteAlert(String alertId) async {
    try {
      await alertsRef.child(alertId).remove();
      return true;
    } catch (e) {
      print('Error deleting alert: $e');
      return false;
    }
  }

  // Add sample data for testing
  Future<void> addSampleAlerts() async {
    try {
      // Sample Emergency Alert
      final emergencyAlert = AlertModel(
        id: '',
        alertType: 'Emergency',
        isActive: true,
        location: 'Block A, Street 5, Alsea Homes',
        latitude: 14.5995,
        longitude: 120.9842,
        dateTime: DateTime.now().subtract(const Duration(minutes: 15)),
        details: 'Fire detected in residential area. Immediate evacuation required.',
        imageUrl: '',
      );

      // Sample Warning Alert
      final warningAlert = AlertModel(
        id: '',
        alertType: 'Warning',
        isActive: true,
        location: 'Block C, Street 12, Alsea Homes',
        latitude: 14.6010,
        longitude: 120.9855,
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        details: 'Suspicious activity reported near the playground area.',
        imageUrl: '',
      );

      // Sample Resolved Alert
      final resolvedAlert = AlertModel(
        id: '',
        alertType: 'Warning',
        isActive: false,
        location: 'Block B, Street 8, Alsea Homes',
        latitude: 14.6005,
        longitude: 120.9850,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        details: 'Power outage reported. Issue has been resolved.',
        imageUrl: '',
      );

      await createAlert(emergencyAlert);
      await createAlert(warningAlert);
      await createAlert(resolvedAlert);

      print('Sample alerts added successfully!');
    } catch (e) {
      print('Error adding sample alerts: $e');
    }
  }

  // Listen to a specific alert
  Stream<AlertModel?> listenToAlert(String alertId) {
    return alertsRef.child(alertId).onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        return AlertModel.fromMap(
          alertId,
          event.snapshot.value as Map<dynamic, dynamic>,
        );
      }
      return null;
    });
  }

  // Get count of active alerts
  Future<int> getActiveAlertCount() async {
    try {
      final snapshot = await alertsRef.get();
      
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int count = 0;
        
        data.forEach((key, value) {
          if (value is Map && value['isActive'] == true) {
            count++;
          }
        });
        
        return count;
      }
      return 0;
    } catch (e) {
      print('Error getting active alert count: $e');
      return 0;
    }
  }
}
