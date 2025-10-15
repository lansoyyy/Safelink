import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyContactsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _contactsCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('emergency_contacts');
  }

  // Add a new emergency contact
  Future<String> addEmergencyContact(Map<String, dynamic> contactData) async {
    try {
      final docRef = await _contactsCollection.add(contactData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add emergency contact: $e');
    }
  }

  // Get all emergency contacts
  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    try {
      final snapshot = await _contactsCollection
          .orderBy('isPrimary', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get emergency contacts: $e');
    }
  }

  // Update an emergency contact
  Future<void> updateEmergencyContact(
      String contactId, Map<String, dynamic> contactData) async {
    try {
      await _contactsCollection.doc(contactId).update(contactData);
    } catch (e) {
      throw Exception('Failed to update emergency contact: $e');
    }
  }

  // Delete an emergency contact
  Future<void> deleteEmergencyContact(String contactId) async {
    try {
      await _contactsCollection.doc(contactId).delete();
    } catch (e) {
      throw Exception('Failed to delete emergency contact: $e');
    }
  }

  // Stream of emergency contacts for real-time updates
  Stream<List<Map<String, dynamic>>> getEmergencyContactsStream() {
    return _contactsCollection
        .orderBy('isPrimary', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList());
  }
}
