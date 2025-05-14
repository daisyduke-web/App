import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockAlertsPage extends StatelessWidget {
  const StockAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Stock Alerts',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('inventory') // Changed from 'items'
                        .orderBy('stock_level') // Changed from 'stock'
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No items found.'));
                      }

                      final items = snapshot.data!.docs;

                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final name = item['item_name']?.toString() ?? 'Unnamed'; // Changed from 'name'
                          final stock = item['stock_level'] ?? 0; // Changed from 'stock'

                          final isLowStock = stock <= 5;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: isLowStock
                                  ? Colors.red.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isLowStock
                                    ? Colors.red.shade400
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isLowStock
                                        ? Colors.red.shade700
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Stock: $stock',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isLowStock
                                        ? Colors.red.shade700
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
