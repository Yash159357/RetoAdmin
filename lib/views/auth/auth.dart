import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AdminAuthScreen extends StatefulWidget {
  static const String id = 'AdminAuthScreen';

  const AdminAuthScreen({super.key});

  @override
  State<AdminAuthScreen> createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;

  // Theme colors to match existing screens
  final Color primaryThemeColor = const Color.fromARGB(255, 255, 246, 233);
  final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      if (_isLogin) {
        await _handleLogin();
      } else {
        _showSignUpNotAvailable();
      }
    }
  }

  Future<void> _handleLogin() async {
    try {
      EasyLoading.show(status: 'Verifying...');

      // Check if email exists in vendors collection AND isAdmin is true
      final vendorSnapshot =
          await _firestore
              .collection('vendors')
              .where('email', isEqualTo: _emailController.text.trim())
              .get();

      if (vendorSnapshot.docs.isEmpty) {
        EasyLoading.dismiss();
        _showErrorMessage('Not authorized. Only vendor accounts can login.');
        return;
      }

      // Check if the vendor has admin privileges
      final vendorData = vendorSnapshot.docs.first.data();
      if (vendorData['isAdmin'] != true) {
        EasyLoading.dismiss();
        _showErrorMessage('Not authorized. Admin privileges required.');
        return;
      }

      // If vendor exists and is admin, proceed with Firebase Auth
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        EasyLoading.dismiss();

        if (userCredential.user != null) {
          // Navigate to main screen or dashboard
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: accentThemeColor,
              content: Text('Login successful!'),
              duration: Duration(seconds: 2),
            ),
          );

          // Clear form fields
          _emailController.clear();
          _passwordController.clear();

          // Navigate to dashboard or home (you'll implement this)
          // Navigator.pushReplacementNamed(context, DashboardScreen.id);
        }
      } on FirebaseAuthException catch (e) {
        EasyLoading.dismiss();
        String errorMessage = 'Login failed';

        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password';
        }

        _showErrorMessage(errorMessage);
      }
    } catch (e) {
      EasyLoading.dismiss();
      _showErrorMessage('Error: ${e.toString()}');
    }
  }

  void _showSignUpNotAvailable() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: primaryThemeColor,
            title: Text('Sign Up Not Available'),
            content: Text(
              'Sign up functionality is not available. Please contact the administrator for a vendor account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: accentThemeColor),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or App Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: accentThemeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 32),

                // Title
                Text(
                  _isLogin ? 'Admin Login' : 'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 8),

                // Subtitle
                Text(
                  _isLogin
                      ? 'Login to manage your store'
                      : 'Sign up to create a vendor account',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),

                SizedBox(height: 32),

                // Form
                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: primaryThemeColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: accentThemeColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: accentThemeColor,
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: accentThemeColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: accentThemeColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (!_isLogin && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 24),

                        // Login/Signup Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentThemeColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              _isLogin ? 'Login' : 'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Switch between Login/Signup
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Need an account? Sign Up'
                                : 'Already have an account? Login',
                            style: TextStyle(
                              color: accentThemeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Forgot Password
                if (_isLogin)
                  TextButton(
                    onPressed: () {
                      // Implement forgot password functionality
                      // or show a message that it's not available
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please contact administrator for password reset',
                          ),
                          backgroundColor: Colors.grey.shade700,
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
