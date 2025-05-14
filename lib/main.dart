import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/employee_dash.dart';
import 'screens/manager/manager_dash.dart';
import 'screens/register_page.dart'; // Correctly import RegisterPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Extract token from URL (only works on web)
  final uri = Uri.base;
  final token = uri.queryParameters['token'];

  runApp(MyApp(initialToken: token));
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  const MyApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuperApp',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: initialToken != null ? '/register' : '/',
      routes: {
        '/': (context) => LoginPage(),
        '/employee_dash': (context) => const EmployeeDashboard(),
        '/manager_dash': (context) => const ManagerDashboard(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/register' && initialToken != null) {
          return MaterialPageRoute(
            builder: (context) => RegisterPage(token: initialToken!),
          );
        }
        return null;
      },
    );
  }
}
