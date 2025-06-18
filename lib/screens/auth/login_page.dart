import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_page.dart';
import '../home/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.engineering,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'NDT Quality Control',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 40),

                // Login Form
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Giriş Yap',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email gerekli';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword 
                                    ? Icons.visibility 
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre gerekli';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('GİRİŞ YAP'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hesabınız yok mu? '),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text('Kayıt Ol'),
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