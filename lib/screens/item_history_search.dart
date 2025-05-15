import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemHistoryPage extends StatefulWidget {
  const ItemHistoryPage({Key? key}) : super(key: key);

  @override
  State<ItemHistoryPage> createState() => _ItemHistoryPageState();
}

class _ItemHistoryPageState extends State<ItemHistoryPage> {

  @override
  Widget build(BuildContext context) {
    // Removed date formatting

    return Scaffold(
      appBar: AppBar(title: const Text('Item History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('item_history')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final logs = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('RFID')),
                DataColumn(label: Text('ITEM NAME')),
                DataColumn(label: Text('EVENT TYPE')),
                DataColumn(label: Text('STOCK LEVEL')),
                DataColumn(label: Text('TIMESTAMP')),
              ],
              rows: logs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = data['time'] is Timestamp
                    ? '${(data['time'] as Timestamp).toDate().toLocal().day.toString().padLeft(2, '0')}/'
                      '${(data['time'] as Timestamp).toDate().toLocal().month.toString().padLeft(2, '0')}/'
                      '${(data['time'] as Timestamp).toDate().toLocal().year} '
                      '${(data['time'] as Timestamp).toDate().toLocal().hour == 0 || (data['time'] as Timestamp).toDate().toLocal().hour == 12 ? 12 : ((data['time'] as Timestamp).toDate().toLocal().hour % 12).toString().padLeft(2, '0')}:'
                      '${(data['time'] as Timestamp).toDate().toLocal().minute.toString().padLeft(2, '0')} '
                      '${(data['time'] as Timestamp).toDate().toLocal().hour < 12 ? 'AM' : 'PM'}'
                    : data['time']?.toString() ?? '';
                return DataRow(cells: [
                  DataCell(Text(doc.id)),
                  DataCell(Text(data['item_name'] ?? '')),
                  DataCell(Text((data['event_type'] as List?)?.join(', ') ?? '')),
                  DataCell(Text(data['stock_level']?.toString() ?? '')),
                  DataCell(Text(timestamp)),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
