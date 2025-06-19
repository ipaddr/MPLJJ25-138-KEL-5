import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim().toLowerCase();
        final password = _passwordController.text.trim();

        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        final user = userCredential.user;
        if (user == null) throw Exception('User authentication failed');

        if (!user.emailVerified) {
          await user.sendEmailVerification();
          throw Exception('Please verify your email first. Verification email sent.');
        }

        UserData userData;
        try {
          userData = await _getUserData(user.uid, email);
        } catch (e) {
          await FirebaseAuth.instance.signOut();
          rethrow;
        }

        if (userData.status != 'active') {
          throw Exception('Account is not active');
        }

        if (!mounted) return;
        _navigateBasedOnRole(userData.role, user.uid, userData);

      } on FirebaseAuthException catch (e) {
        await Future.delayed(const Duration(seconds: 2));
        _showErrorSnackbar(_getAuthErrorMessage(e));
      } catch (e) {
        await Future.delayed(const Duration(seconds: 2));
        _showErrorSnackbar('Error: ${e.toString()}');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<UserData> _getUserData(String uid, String email) async {
    final uidSnapshot = await _databaseRef.child('users/$uid').once();
    if (uidSnapshot.snapshot.value != null) {
      return UserData.fromMap(Map<String, dynamic>.from(uidSnapshot.snapshot.value as dynamic));
    }

    final emailQuery = await _databaseRef.child('users')
        .orderByChild('email')
        .equalTo(email)
        .once();

    if (emailQuery.snapshot.value == null) {
      throw Exception('User data not found in database');
    }

    final usersData = emailQuery.snapshot.value as Map<dynamic, dynamic>;
    final userEntry = usersData.entries.first;
    return UserData.fromMap(Map<String, dynamic>.from(userEntry.value as dynamic));
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Incorrect email or password';
      case 'user-not-found':
        return 'Email not registered';
      case 'user-disabled':
        return 'Account disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return 'Login failed: ${e.message}';
    }
  }

  void _navigateBasedOnRole(String role, String userId, UserData userData) {
    final routeName = switch (role) {
      'admin' => '/admin-dashboard',
      'sekolah' => '/sekolah-dashboard',
      'distributor' => '/distributor-dashboard',
      _ => '/home',
    };

    Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: {
        'userId': userId,
        'userRole': role,
        'userName': userData.name,
        'userEmail': userData.email,
      },
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showErrorSnackbar('Please enter a valid email');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(_getAuthErrorMessage(e));
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3E4),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  const SizedBox(height: 16),
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 24),
                  _buildLoginButton(),
                  const SizedBox(height: 16),
                  _buildRegisterLink(),
                  const SizedBox(height: 12),
                  _buildForgotPasswordButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.email),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pushNamed(context, '/register'),
          child: Text(
            'Register here',
            style: TextStyle(
              color: Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: _isLoading ? null : _resetPassword,
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: Colors.orange[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class UserData {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] ?? '',
      name: map['nama'] ?? map['name'] ?? 'User',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      status: map['status'] ?? 'inactive',
    );
  }
}
