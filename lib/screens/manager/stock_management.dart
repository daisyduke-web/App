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
    final stockLevelController = TextEditingController(
      text: doc?.get('stock_level')?.toString() ?? '',
    );
    final Map<String, dynamic> formData = {
      'aisle': doc?.get('aisle')?.toString() ?? '',
      'item_name': doc?.get('item_name')?.toString() ?? '',
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
                  final data = {
                    ...formData,
                    'price': double.tryParse(formData['price']) ?? 0.0,
                    'stock_level': stockLevel,
                    'last_updated': FieldValue.serverTimestamp(),
                  };

                  if (isEditing && doc != null) {
                    await _firestore.collection('inventory').doc(doc.id).update(data);
                  } else {
                    await _firestore.collection('inventory').add(data);
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

  void _deleteItem(DocumentSnapshot doc) async {
    try {
      await _firestore.collection('recently_deleted').add({
        ...doc.data() as Map<String, dynamic>,
        'deleted_at': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('inventory').doc(doc.id).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  void _navigateToRecentlyDeleted() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecentlyDeletedPage()),
    );
  }

  String _formatTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final dt = ts.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
             '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _navigateToRecentlyDeleted,
            tooltip: 'Recently Deleted',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddItemDialog,
            tooltip: 'Add Inventory',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('inventory').orderBy('last_updated', descending: true).snapshots(),
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
              final timestamp = data['last_updated'];
              return ListTile(
                title: Text(data['item_name']?.toString() ?? 'Unnamed Item'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aisle: ${data['aisle'] ?? 'N/A'} | Section: ${data['section'] ?? 'N/A'} | Price: \$${data['price'] ?? '0.0'} | Stock: ${data['stock_level'] ?? '0'}',
                    ),
                    if (timestamp != null)
                      Text(
                        'Last Updated: ${_formatTimestamp(timestamp)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
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
                      onPressed: () => _deleteItem(doc),
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

class RecentlyDeletedPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final dt = ts.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
             '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recently Deleted')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('recently_deleted').orderBy('deleted_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final deletedAt = data['deleted_at'];

              return ListTile(
                title: Text(data['item_name'] ?? 'Unnamed Item'),
                subtitle: Text(
                  'Deleted at: ${_formatTimestamp(deletedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.restore, color: Colors.green),
                  onPressed: () async {
                    try {
                      final restoredData = Map<String, dynamic>.from(data);
                      restoredData.remove('deleted_at');
                      restoredData['last_updated'] = FieldValue.serverTimestamp();

                      await _firestore.collection('inventory').add(restoredData);
                      await _firestore.collection('recently_deleted').doc(doc.id).delete();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Restore failed: $e')),
                      );
                    }
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
