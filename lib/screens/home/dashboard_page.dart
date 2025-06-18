import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _authService.getUserData();
    setState(() {
      userData = data;
    });
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NDT Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kullanıcı Kartı
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue,
                            child: Text(
                              userData!['fullName'][0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hoş geldin, ${userData!['fullName']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Sicil: ${userData!['sicilNo']} | ${userData!['ekip']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // İstatistikler
                  const Text(
                    'Günlük İstatistikler',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Toplam', '12', 'Test', Icons.assignment, Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('OK', '10', 'Başarılı', Icons.check_circle, Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Hızlı İşlemler
                  const Text(
                    'Hızlı İşlemler',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildActionCard('Yeni Test', Icons.add_circle, Colors.green, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Yeni test sayfası yakında...')),
                          );
                        }),
                        _buildActionCard('Geçmiş', Icons.history, Colors.blue, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Geçmiş testler yakında...')),
                          );
                        }),
                        _buildActionCard('Raporlar', Icons.assessment, Colors.orange, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Raporlar yakında...')),
                          );
                        }),
                        _buildActionCard('Ayarlar', Icons.settings, Colors.grey, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ayarlar yakında...')),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 14)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}