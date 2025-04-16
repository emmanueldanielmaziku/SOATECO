import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'leader_dashboard.dart';
import 'student_coming_soon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _admissionNumberController = TextEditingController();
  
  bool _isEmailLogin = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _admissionNumberController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    String? error;

    if (_isEmailLogin) {
      error = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      error = await authService.signInWithPhoneAndAdmissionNumber(
        _phoneController.text.trim(),
        _admissionNumberController.text.trim(),
      );
    }

    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
      return;
    }

    if (authService.isLeader) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LeaderDashboard()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StudentComingSoon()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and title
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'ATC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to SOATECO',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Arusha Technical College',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Login tabs
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isEmailLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _isEmailLogin 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Email Login',
                            style: TextStyle(
                              fontWeight: _isEmailLogin ? FontWeight.bold : FontWeight.normal,
                              color: _isEmailLogin 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isEmailLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: !_isEmailLogin 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Phone Login',
                            style: TextStyle(
                              fontWeight: !_isEmailLogin ? FontWeight.bold : FontWeight.normal,
                              color: !_isEmailLogin 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),
                
                // Login form
                Form(
                  key: _formKey,
                  child: _isEmailLogin ? _buildEmailForm() : _buildPhoneForm(),
                ),
                
                const SizedBox(height: 24),
                
                // Login button
                ElevatedButton(
                  onPressed: authService.isLoading ? null : _login,
                  child: authService.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      children: [
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _admissionNumberController,
          decoration: const InputDecoration(
            labelText: 'Admission Number',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your admission number';
            }
            return null;
          },
        ),
      ],
    );
  }
}
