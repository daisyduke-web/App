import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//kurtis
class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CollectionReference inventory = FirebaseFirestore.instance.collection('inventory');

    return Scaffold(
      appBar: AppBar(title: Text('Inventory')),
      body: StreamBuilder<QuerySnapshot>(
        stream: inventory.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text(item['item_name'] ?? 'No name'),
                subtitle: Text('Aisle ${item['aisle']} • ${item['stock_level']} in stock'),
                trailing: Text(item['price'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
