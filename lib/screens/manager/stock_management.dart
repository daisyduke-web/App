import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockManagementPage extends StatefulWidget {
  @override
  _StockManagementPageState createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddItemDialog() {
    _showItemDialog(isEditing: false);
  }

  void _showEditItemDialog(DocumentSnapshot doc) {
    _showItemDialog(isEditing: true, doc: doc);
  }

  void _showItemDialog({bool isEditing = false, DocumentSnapshot? doc}) {
    final _formKey = GlobalKey<FormState>();
    // Initialize controllers for fields that need special handling
    final stockLevelController = TextEditingController(
      text: doc?.get('stock_level')?.toString() ?? '',
    );
    // Use a map to hold string values for other fields
    final Map<String, dynamic> formData = {
      'aisle': doc?.get('aisle')?.toString() ?? '',
      'item_name': doc?.get('item_name')?.toString() ?? '',
      'last_updated': doc?.get('last_updated')?.toString() ?? '',
      'price': doc?.get('price')?.toString() ?? '',
      'section': doc?.get('section')?.toString() ?? '',
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Text fields for string-based fields
                ...formData.entries.map((entry) {
                  return TextFormField(
                    initialValue: entry.value,
                    decoration: InputDecoration(labelText: entry.key),
                    onChanged: (value) => formData[entry.key] = value,
                    validator: (value) {
                      if (entry.key == 'price') {
                        if (value == null || double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                      }
                      return null;
                    },
                  );
                }).toList(),
                // Separate TextFormField for stock_level to handle int
                TextFormField(
                  controller: stockLevelController,
                  decoration: InputDecoration(labelText: 'stock_level'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return 'Please enter a valid integer';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final stockLevel = int.tryParse(stockLevelController.text) ?? 0;
                  if (isEditing && doc != null) {
                    await _firestore.collection('inventory').doc(doc.id).update({
                      ...formData,
                      'price': double.tryParse(formData['price']) ?? 0.0,
                      'stock_level': stockLevel,
                    });
                  } else {
                    await _firestore.collection('inventory').add({
                      ...formData,
                      'price': double.tryParse(formData['price']) ?? 0.0,
                      'stock_level': stockLevel,
                    });
                  }
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save: $e')),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(String docId) async {
    try {
      await _firestore.collection('inventory').doc(docId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddItemDialog,
            tooltip: 'Add Inventory',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('inventory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['item_name']?.toString() ?? 'Unnamed Item'),
                subtitle: Text(
                  'Aisle: ${data['aisle']?.toString() ?? 'N/A'} | Section: ${data['section']?.toString() ?? 'N/A'} | Price: \$${data['price']?.toString() ?? '0.0'} | Stock: ${data['stock_level']?.toString() ?? '0'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditItemDialog(doc),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(doc.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
