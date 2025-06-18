import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _sicilNoController = TextEditingController();
  
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _selectedEkip = 'Ekip A';

  final List<String> _ekipList = [
    'Ekip A',
    'Ekip B', 
    'Ekip C',
    'Vardiya 1',
    'Vardiya 2',
  ];

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
        sicilNo: _sicilNoController.text,
        ekip: _selectedEkip,
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
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.person_add,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Yeni Hesap Oluştur',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),

              // Register Form
              Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Full Name
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Ad Soyad',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ad soyad gerekli';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Sicil No
                        TextFormField(
                          controller: _sicilNoController,
                          decoration: const InputDecoration(
                            labelText: 'Sicil Numarası',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Sicil numarası gerekli';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Ekip Seçimi
                        DropdownButtonFormField<String>(
                          value: _selectedEkip,
                          decoration: const InputDecoration(
                            labelText: 'Ekip',
                            prefixIcon: Icon(Icons.group),
                            border: OutlineInputBorder(),
                          ),
                          items: _ekipList.map((String ekip) {
                            return DropdownMenuItem<String>(
                              value: ekip,
                              child: Text(ekip),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedEkip = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email gerekli';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre gerekli';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalı';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('KAYIT OL'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}