import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final String token;

  const RegisterPage({Key? key, required this.token}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isTokenValid = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _validateToken();
  }

  // Validates the token to check if it's valid and not used.
  Future<void> _validateToken() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('invites')
            .doc(widget.token)
            .get();

    if (!doc.exists || (doc.data()?['used'] ?? true)) {
      setState(() {
        _isTokenValid = false;
        _loading = false;
      });
      return;
    }

    setState(() {
      _isTokenValid = true;
      _loading = false;
    });
  }

  // Registers the user and assigns them an employee role.
  Future<void> _registerUser() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Register the user with Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save the user role in Firestore
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userCredential.user!.uid)
          .set({'email': email, 'role': 'employee'});

      // Mark the token as used
      await FirebaseFirestore.instance
          .collection('invites')
          .doc(widget.token)
          .update({'used': true, 'used_by': userCredential.user!.uid});

      // Navigate to the employee dashboard
      Navigator.pushReplacementNamed(context, '/employee_dash');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while the token is being validated
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If token is invalid, show an error message
    if (!_isTokenValid) {
      return const Scaffold(
        body: Center(child: Text('Invalid or expired invite link.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Register as Employee')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Email input field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            // Password input field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            // Register button
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
