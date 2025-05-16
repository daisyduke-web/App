import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ItemHistoryPage extends StatefulWidget {
  const ItemHistoryPage({super.key});

  @override
  State<ItemHistoryPage> createState() => _ItemHistoryPageState();
}

class _ItemHistoryPageState extends State<ItemHistoryPage> {
  final TextEditingController _rfidController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchFilteredHistory(); // Load all history initially
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _fetchFilteredHistory() async {
    try {
      final rfid = _rfidController.text.trim();

      Query query = FirebaseFirestore.instance.collection('item_history');

      if (rfid.isNotEmpty && _fromDate == null && _toDate == null) {
        // RFID only
        query = query.where('rfid', isEqualTo: rfid);
      } else {
        query = query.orderBy('timestamp', descending: true);

        if (rfid.isNotEmpty) {
          query = query.where('rfid', isEqualTo: rfid);
        }
        if (_fromDate != null) {
          query = query.where(
              'timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(_fromDate!));
        }
        if (_toDate != null) {
          final endOfDay = DateTime(
              _toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59);
          query = query.where(
              'timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
        }
      }

      final snapshot = await query.get();

      setState(() {
        _history =
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error fetching filtered history: $e');
    }
  }

  String _formatDate(Timestamp timestamp) {
    return DateFormat('dd-MM-yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.home),
        title: const Text('Item History'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.account_circle),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _rfidController,
                    decoration: const InputDecoration(
                      labelText: 'RFID',
                      hintText: 'Unique RFID',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'From',
                          hintText: 'Start date',
                          suffixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        controller: TextEditingController(
                          text: _fromDate != null
                              ? DateFormat('dd-MM-yyyy').format(_fromDate!)
                              : '',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'To',
                          hintText: 'End date',
                          suffixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        controller: TextEditingController(
                          text: _toDate != null
                              ? DateFormat('dd-MM-yyyy').format(_toDate!)
                              : '',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchFilteredHistory,
                  child: const Text('Search'),
                )
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text("No data to display."))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('RFID')),
                          DataColumn(label: Text('ITEM NAME')),
                          DataColumn(label: Text('DATE')),
                          DataColumn(label: Text('DIFFERENCE')),
                          DataColumn(label: Text('REASON')),
                          DataColumn(label: Text('OLD STOCK')),
                          DataColumn(label: Text('NEW STOCK')),
                        ],
                        rows: _history.map((entry) {
                          return DataRow(cells: [
                            DataCell(Text(entry['rfid'] ?? '')),
                            DataCell(Text(entry['item_name'] ?? '')),
                            DataCell(Text(_formatDate(entry['timestamp']))),
                            DataCell(Text(entry['stock_difference']?.toString() ?? '')),
                            DataCell(Text(entry['reason'] ?? '')),
                            DataCell(Text(entry['old_stock']?.toString() ?? '')),
                            DataCell(Text(entry['new_stock']?.toString() ?? '')),
                          ]);
                        }).toList(),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
