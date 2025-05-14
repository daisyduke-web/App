import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  Future<void> _generateInviteLink(BuildContext context) async {
    try {
      final token = const Uuid().v4();

      // Save the invite to Firestore
      await FirebaseFirestore.instance.collection('invites').doc(token).set({
        'token': token,
        'role': 'employee',
        'used': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Generate the invite link
      final link = 'https://superapp-101c1.web.app/register?token=$token';

      // Show the invite link in an alert dialog
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Invite Link"),
              content: SelectableText(link),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
      );
    } catch (e) {
      // Handle any errors during the process
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating link: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed:
              () => _generateInviteLink(context), // Pass context to the method
          child: const Text('Generate Employee Invite Link'),
        ),
      ),
    );
  }
}
