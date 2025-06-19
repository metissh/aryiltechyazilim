import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/dashboard_page.dart';
import '../admin/admin_dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  final String defaultRole;

  const RegisterPage({super.key, this.defaultRole = 'user'});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _sicilNoController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedEkip = 'Ekip A';
  String _selectedRole = 'user';

  final List<String> _ekipList = [
    'Ekip A',
    'Ekip B',
    'Ekip C',
    'Vardiya 1',
    'Vardiya 2',
    'Vardiya 3',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.defaultRole;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _sicilNoController.dispose();
    super.dispose();
  }

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
        rol: _selectedRole == 'admin' ? 'admin' : 'operator',
      );

      if (mounted) {
        // Rol kontrolü yaparak yönlendirme
        if (_selectedRole == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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
        title: Text(
          '${_selectedRole == 'admin' ? 'Yönetici' : 'Kullanıcı'} Kayıt',
        ),
        backgroundColor: _selectedRole == 'admin' ? Colors.purple : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _selectedRole == 'admin' ? Colors.purple : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _selectedRole == 'admin'
                      ? Icons.admin_panel_settings
                      : Icons.person_add,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Yeni Hesap Oluştur',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _selectedRole == 'admin' ? Colors.purple : Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedRole == 'admin' ? 'Yönetici' : 'Operatör'} hesabı için kayıt olun',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Register Form
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Rol Göstergesi
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                (_selectedRole == 'admin'
                                        ? Colors.purple
                                        : Colors.blue)
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedRole == 'admin'
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                color: _selectedRole == 'admin'
                                    ? Colors.purple
                                    : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedRole == 'admin' ? 'Yönetici' : 'Kullanıcı'} Kaydı',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedRole == 'admin'
                                      ? Colors.purple
                                      : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Full Name
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Ad Soyad',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ad soyad gerekli';
                            }
                            if (value.length < 3) {
                              return 'Ad soyad en az 3 karakter olmalı';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Sicil No
                        TextFormField(
                          controller: _sicilNoController,
                          decoration: InputDecoration(
                            labelText: 'Sicil Numarası',
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                          decoration: InputDecoration(
                            labelText: 'Ekip',
                            prefixIcon: const Icon(Icons.group),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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

                        // Rol Seçimi (sadece admin kayıt için göster)
                        if (widget.defaultRole == 'admin')
                          Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: InputDecoration(
                                  labelText: 'Rol',
                                  prefixIcon: const Icon(
                                    Icons.admin_panel_settings,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'user',
                                    child: Text('Kullanıcı'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'admin',
                                    child: Text('Yönetici'),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedRole = newValue!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email adresi gerekli';
                            }
                            if (!value.contains('@')) {
                              return 'Geçerli bir email adresi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
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
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalı';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Şifre Tekrar',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre tekrarı gerekli';
                            }
                            if (value != _passwordController.text) {
                              return 'Şifreler eşleşmiyor';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedRole == 'admin'
                                ? Colors.purple
                                : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedRole == 'admin'
                                          ? Icons.admin_panel_settings
                                          : Icons.person_add,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedRole == 'admin' ? 'YÖNETİCİ' : 'KULLANICI'} KAYIT OL',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Giriş Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Zaten hesabınız var mı? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedRole == 'admin'
                            ? Colors.purple
                            : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
