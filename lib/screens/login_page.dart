import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forgot_password.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SuperApp Log In',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Username Field
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Type your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final email = usernameController.text.trim();
                        final password = passwordController.text.trim();

                        final userCredential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                        final uid = userCredential.user!.uid;
                        String role;

                        // Try to fetch by UID
                        final userDoc =
                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(uid)
                                .get();

                        if (!userDoc.exists ||
                            !userDoc.data()!.containsKey('role')) {
                          throw FirebaseAuthException(
                            code: 'no-role',
                            message: 'User role not defined.',
                          );
                        }

                        role = userDoc.data()!['role'];

                        if (role == 'manager') {
                          Navigator.pushReplacementNamed(
                            context,
                            '/manager_dash',
                          );
                        } else if (role == 'employee') {
                          Navigator.pushReplacementNamed(
                            context,
                            '/employee_dash',
                          );
                        } else {
                          throw FirebaseAuthException(
                            code: 'unknown-role',
                            message: 'Unknown user role.',
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        print('Login error: ${e.code}');
                        String message = 'Login failed :( )';
                        if (e.code == 'user-not-found' ||
                            e.code == 'wrong-password') {
                          message =
                              'Email or password is incorrect!! Did you type something wrong?';
                        } else if (e.code == 'no-role' ||
                            e.code == 'unknown-role') {
                          message =
                              e.message ??
                              'An error occurred while determining user role.';
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      }
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
