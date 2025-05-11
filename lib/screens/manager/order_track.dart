import 'package:flutter/material.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.home, size: 36),
                SizedBox(width: 12),
                Text(
                  "Order Tracking",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Order Status", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    SizedBox(height: 4),
                                    Text("Current Shipments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Icon(Icons.all_inbox_outlined),
                              ],
                            ),
                            const Divider(),
                            const ListTile(
                              leading: Icon(Icons.local_shipping_outlined),
                              title: Text("Shepard Avocados | 3"),
                              subtitle: Text("ON TIME - OUT FOR DELIVERY\nETA : 17:00 TODAY"),
                            ),
                            const ListTile(
                              leading: Icon(Icons.access_time),
                              title: Text("Calypso Mango | 5"),
                              subtitle: Text("DELAYED - IN TRANSIT | ADL\nETA : 1800 15/05/25"),
                            ),
                            const ListTile(
                              leading: Icon(Icons.check),
                              title: Text("Canberra Milk | 2"),
                              subtitle: Text("DELIVERED\nATA : 1500 12/05/25"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    width: 280,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color(0xF0ECE7F4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Delivery Alerts", style: TextStyle(fontWeight: FontWeight.w500)),
                            Icon(Icons.error_outline, size: 24),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text("Egg Shortages in NSW", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Shipments may be delayed", style: TextStyle(fontSize: 12)),
                        SizedBox(height: 12),
                        Text("Queensland Floods", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Mango shipments severely affected", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
