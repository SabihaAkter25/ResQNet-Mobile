import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/database/app_database.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  List<Map<String, Object?>> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final result = await AppDatabase.getEmergencyContacts();

    if (!mounted) return;

    setState(() {
      contacts = result;
      isLoading = false;
    });
  }

  Future<void> showContactDialog({
    Map<String, Object?>? contact,
  }) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _ContactFormDialog(contact: contact),
    );

    if (!mounted || result == null) return;

    if (contact != null) {
      await AppDatabase.updateEmergencyContact(
        id: contact['id'] as String,
        name: result['name']!,
        phone: result['phone']!,
        relationship: result['relationship']!.isEmpty
            ? null
            : result['relationship'],
      );
    } else {
      await AppDatabase.saveEmergencyContact(
        name: result['name']!,
        phone: result['phone']!,
        relationship: result['relationship']!.isEmpty
            ? null
            : result['relationship'],
      );
    }

    await loadContacts();
  }

  Future<void> callContact(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open phone dialer'),
        ),
      );
    }
  }

  Future<void> deleteContact(String id) async {
    await AppDatabase.deleteEmergencyContact(id);
    await loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showContactDialog(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Contact'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.contacts_outlined,
                        size: 65,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No emergency contacts yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text('Add trusted people for emergencies'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];

                    final name = contact['name'] as String;
                    final phone = contact['phone'] as String;
                    final relationship =
                        contact['relationship'] as String? ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          relationship.isEmpty
                              ? phone
                              : '$relationship • $phone',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              showContactDialog(contact: contact);
                            } else if (value == 'delete') {
                              deleteContact(
                                contact['id'] as String,
                              );
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                        onTap: () => callContact(phone),
                      ),
                    );
                  },
                ),
    );
  }
}

class _ContactFormDialog extends StatefulWidget {
  final Map<String, Object?>? contact;

  const _ContactFormDialog({this.contact});

  @override
  State<_ContactFormDialog> createState() =>
      _ContactFormDialogState();
}

class _ContactFormDialogState extends State<_ContactFormDialog> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController relationshipController;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.contact?['name'] as String? ?? '',
    );

    phoneController = TextEditingController(
      text: widget.contact?['phone'] as String? ?? '',
    );

    relationshipController = TextEditingController(
      text: widget.contact?['relationship'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    relationshipController.dispose();
    super.dispose();
  }

  void saveContact() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      setState(() {
        errorMessage = 'Name and phone are required';
      });
      return;
    }

    Navigator.pop(context, {
      'name': name,
      'phone': phone,
      'relationship': relationshipController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Contact' : 'Add Emergency Contact'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship (Optional)',
                prefixIcon: Icon(Icons.people_outline),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: saveContact,
          child: Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}
