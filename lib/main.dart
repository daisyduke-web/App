import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:superapp/screens/manager/manager_dash.dart';
import 'firebase_options.dart'; // Ensure this file exists
import 'screens/login_page.dart'; // Import LoginPage
import 'screens/employee_dash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuperApp',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: LoginPage(),
      routes: {
        '/employee_dash': (context) => const EmployeeDashboard(),
        '/manager_dash': (context) => const ManagerDashboard(),
      },
    );
  }
}
