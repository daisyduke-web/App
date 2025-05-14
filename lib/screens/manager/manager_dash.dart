import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superapp/screens/item_search.dart';
import 'package:superapp/screens/item_history_search.dart';
import 'package:superapp/screens/manager/order_track.dart';
import 'package:superapp/screens/manager/stock_management.dart';

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
        builder: (BuildContext context) => AlertDialog(
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.account_circle_outlined, size: 30),
              ],
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _DashboardButton(
                  label: 'ITEM INQUIRY',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InventoryPage()),
                  ),
                ),
                _DashboardButton(
                  label: 'ITEM HISTORY',
                  onTap: () {},
                ),
                _DashboardButton(
                  label: 'TRACK ORDERS',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderTrackingPage()),
                  ),
                ),
                _DashboardButton(
                  label: 'REGISTER EMPLOYEE',
                  onTap: () => _generateInviteLink(context),
                ),
                _DashboardButton(
                  label: 'MANAGE STOCK',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StockManagementPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DashboardButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.indigoAccent),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
