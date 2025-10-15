import 'package:flutter/material.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/button_widget.dart';
import 'package:safelink/widgets/text_widget.dart';
import 'package:safelink/widgets/textfield_widget.dart';
import 'package:safelink/services/emergency_contacts_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final EmergencyContactsService _contactsService = EmergencyContactsService();
  List<Map<String, dynamic>> _emergencyContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  void _loadEmergencyContacts() async {
    try {
      final contacts = await _contactsService.getEmergencyContacts();
      setState(() {
        _emergencyContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading contacts: $e')),
      );
    }
  }

  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => _AddContactDialog(
        onAdd: (contact) async {
          try {
            await _contactsService.addEmergencyContact(contact);
            _loadEmergencyContacts(); // Refresh the list
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contact added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding contact: $e')),
            );
          }
        },
      ),
    );
  }

  void _editContact(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (context) => _AddContactDialog(
        contact: contact,
        onAdd: (updatedContact) async {
          try {
            await _contactsService.updateEmergencyContact(
                contact['id'], updatedContact);
            _loadEmergencyContacts(); // Refresh the list
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contact updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating contact: $e')),
            );
          }
        },
      ),
    );
  }

  void _deleteContact(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Delete Contact',
          fontSize: 18,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Are you sure you want to delete this emergency contact?',
          fontSize: 14,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              fontFamily: 'Medium',
              color: Colors.grey[600],
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _contactsService.deleteEmergencyContact(contact['id']);
                Navigator.pop(context);
                _loadEmergencyContacts(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting contact: $e')),
                );
              }
            },
            child: TextWidget(
              text: 'Delete',
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _callContact(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone dialer for $phone')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making call: $e')),
      );
    }
  }

  void _notifyAllContacts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.red, size: 30),
            const SizedBox(width: 10),
            TextWidget(
              text: 'Notify All Contacts',
              fontSize: 18,
              fontFamily: 'Bold',
            ),
          ],
        ),
        content: TextWidget(
          text:
              'This will send an emergency notification to all saved contacts. Continue?',
          fontSize: 14,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              fontFamily: 'Medium',
              color: Colors.grey[600],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Call all primary contacts
              final primaryContacts = _emergencyContacts
                  .where((contact) => contact['isPrimary'] == true)
                  .toList();

              if (primaryContacts.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No primary contacts found'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Call the first primary contact
              _callContact(primaryContacts.first['phone']);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Emergency alert initiated. Calling ${primaryContacts.first['name']}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: TextWidget(
              text: 'Send Alert',
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryLight,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextWidget(
          text: 'Emergency Contacts',
          fontSize: 20,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _addContact,
            tooltip: 'Add Contact',
          ),
        ],
      ),
      body: Column(
        children: [
          // Emergency Alert Button
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.red, Color(0xFFFF1744)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.emergency, color: Colors.white, size: 50),
                const SizedBox(height: 10),
                TextWidget(
                  text: 'Emergency Alert',
                  fontSize: 20,
                  fontFamily: 'Bold',
                  color: Colors.white,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 5),
                TextWidget(
                  text: 'Notify all emergency contacts immediately',
                  fontSize: 12,
                  fontFamily: 'Regular',
                  color: Colors.white70,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _notifyAllContacts,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Send Emergency Alert'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contacts List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: 'Saved Contacts (${_emergencyContacts.length})',
                  fontSize: 16,
                  fontFamily: 'Bold',
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Contacts List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _emergencyContacts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _emergencyContacts.length,
                        itemBuilder: (context, index) {
                          return _buildContactCard(_emergencyContacts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contact_phone,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          TextWidget(
            text: 'No Emergency Contacts',
            fontSize: 20,
            fontFamily: 'Bold',
            color: Colors.grey[600],
          ),
          const SizedBox(height: 10),
          TextWidget(
            text: 'Add contacts to notify in case of emergency',
            fontSize: 14,
            fontFamily: 'Regular',
            color: Colors.grey[500],
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: contact['isPrimary'] == true
            ? Border.all(color: primary.withOpacity(0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            contact['isPrimary'] == true ? Icons.emergency_share : Icons.person,
            color: primary,
            size: 25,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: TextWidget(
                text: contact['name'],
                fontSize: 16,
                fontFamily: 'Bold',
                color: Colors.black,
              ),
            ),
            if (contact['isPrimary'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextWidget(
                  text: 'PRIMARY',
                  fontSize: 10,
                  fontFamily: 'Bold',
                  color: primary,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                TextWidget(
                  text: contact['phone'],
                  fontSize: 14,
                  fontFamily: 'Medium',
                  color: Colors.grey[700],
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.label, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                TextWidget(
                  text: contact['relationship'],
                  fontSize: 12,
                  fontFamily: 'Regular',
                  color: Colors.grey[600],
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.call, size: 20, color: Colors.green),
                  const SizedBox(width: 10),
                  TextWidget(
                    text: 'Call',
                    fontSize: 14,
                    fontFamily: 'Medium',
                  ),
                ],
              ),
              onTap: () => _callContact(contact['phone']),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 20, color: Colors.blue),
                  const SizedBox(width: 10),
                  TextWidget(
                    text: 'Edit',
                    fontSize: 14,
                    fontFamily: 'Medium',
                  ),
                ],
              ),
              onTap: () {
                Future.delayed(
                  const Duration(milliseconds: 100),
                  () => _editContact(contact),
                );
              },
            ),
            if (contact['isPrimary'] != true)
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 10),
                    TextWidget(
                      text: 'Delete',
                      fontSize: 14,
                      fontFamily: 'Medium',
                      color: Colors.red,
                    ),
                  ],
                ),
                onTap: () {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    () => _deleteContact(contact),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AddContactDialog extends StatefulWidget {
  final Map<String, dynamic>? contact;
  final Function(Map<String, dynamic>) onAdd;

  const _AddContactDialog({
    this.contact,
    required this.onAdd,
  });

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationshipController;
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.contact?['name'] ?? '');
    _phoneController =
        TextEditingController(text: widget.contact?['phone'] ?? '');
    _relationshipController =
        TextEditingController(text: widget.contact?['relationship'] ?? '');
    _isPrimary = widget.contact?['isPrimary'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'relationship': _relationshipController.text,
        'isPrimary': _isPrimary,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.contact == null
                ? 'Contact added successfully'
                : 'Contact updated successfully',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: widget.contact == null ? 'Add Contact' : 'Edit Contact',
                  fontSize: 22,
                  fontFamily: 'Bold',
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  label: 'Name',
                  hint: 'Enter contact name',
                  controller: _nameController,
                  borderColor: primary,
                  prefix: const Icon(Icons.person, size: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  label: 'Phone Number',
                  hint: 'Enter phone number',
                  controller: _phoneController,
                  inputType: TextInputType.phone,
                  borderColor: primary,
                  prefix: const Icon(Icons.phone, size: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  label: 'Relationship',
                  hint: 'e.g., Family, Friend, Doctor',
                  controller: _relationshipController,
                  borderColor: primary,
                  prefix: const Icon(Icons.label, size: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter relationship';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                SwitchListTile(
                  title: TextWidget(
                    text: 'Primary Contact',
                    fontSize: 14,
                    fontFamily: 'Medium',
                  ),
                  subtitle: TextWidget(
                    text: 'Notify first in emergencies',
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: Colors.grey[600],
                  ),
                  value: _isPrimary,
                  activeColor: primary,
                  onChanged: (value) => setState(() => _isPrimary = value),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: TextWidget(
                        text: 'Cancel',
                        fontSize: 14,
                        fontFamily: 'Medium',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ButtonWidget(
                      label: 'Save',
                      onPressed: _saveContact,
                      width: 120,
                      height: 45,
                      fontSize: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
