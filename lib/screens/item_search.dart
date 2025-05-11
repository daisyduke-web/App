import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final CollectionReference inventory = FirebaseFirestore.instance.collection('inventory');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by item name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: inventory.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final items = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['item_name']?.toLowerCase() ?? '';
                  return name.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index].data() as Map<String, dynamic>;
                    final name = item['item_name'] ?? 'No name';
                    final aisle = item['aisle']?.toString() ?? 'Unknown';
                    final stock = item['stock_level']?.toString() ?? 'N/A';
                    final price = item['price']?.toString() ?? '';

                    return ListTile(
                      title: Text(name),
                      subtitle: Text('Aisle $aisle • $stock in stock'),
                      trailing: Text(price),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
