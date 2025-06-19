import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ndt_record.dart';
import '../home/dashboard_page.dart';
import 'new_test_page.dart';
import '../../models/test_standard.dart';

class TestResultPage extends StatelessWidget {
  final NDTRecord record;

  const TestResultPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final bool isOK = record.sonuc == 'OK';
    final Color resultColor = isOK ? Colors.green : Colors.red;
    final IconData resultIcon = isOK ? Icons.check_circle : Icons.cancel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonucu'),
        automaticallyImplyLeading: false,
        backgroundColor: _getStandardColor(record.testStandard),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ana Sonuç Kartı
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: isOK 
                        ? [Colors.green[400]!, Colors.green[600]!]
                        : [Colors.red[400]!, Colors.red[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      resultIcon,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      record.sonuc,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOK ? 'Test Başarılı' : 'Test Başarısız',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat('dd.MM.yyyy - HH:mm').format(record.testTarihi),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test Standardı Bilgisi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStandardColor(record.testStandard).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getStandardIcon(record.testStandard),
                        color: _getStandardColor(record.testStandard),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.testStandard,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStandardColor(record.testStandard),
                            ),
                          ),
                          Text(
                            _getStandardName(record.testStandard),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Bilgileri
            _buildDetailCard('Test Bilgileri', [
              _buildDetailRow('Ekip', record.ekip),
              _buildDetailRow('Bölge', record.bolge),
              _buildDetailRow('Conta No', record.contaNo),
              _buildDetailRow('Weld ID', record.weldId),
              _buildDetailRow('Kaynakçı 1', record.kaynakci1),
              if (record.kaynakci2.isNotEmpty)
                _buildDetailRow('Kaynakçı 2', record.kaynakci2),
            ]),

            const SizedBox(height: 16),

            // Boru Bilgileri
            _buildDetailCard('Boru Bilgileri', [
              _buildDetailRow('Çap', '${record.boruCap} mm'),
              _buildDetailRow('Kalınlık', '${record.malzemeKalinlik} mm'),
              _buildDetailRow('Malzeme Kalite', record.malzemeKalite),
              _buildDetailRow('Değerlendirme Seviyesi', record.degerlendirmeSeviyesi),
            ]),

            const SizedBox(height: 16),

            // Ölçüm Değerleri - Standart bazlı
            _buildDetailCard('${record.testStandard} Ölçüm Değerleri', 
              _buildMeasurementRows(record)),

            const SizedBox(height: 24),

            // Alt Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final standard = StandardTemplates.getStandard(record.testStandard);
                      if (standard != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewTestPage(selectedStandard: standard),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Yeni Test'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: _getStandardColor(record.testStandard)),
                      foregroundColor: _getStandardColor(record.testStandard),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardPage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getStandardColor(record.testStandard),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Paylaş Butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _shareResult(context);
                },
                icon: const Icon(Icons.share),
                label: const Text('Sonucu Paylaş'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.grey),
                  foregroundColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMeasurementRows(NDTRecord record) {
    List<Widget> rows = [];
    
    if (record.testStandard == 'PAUT') {
      rows.addAll([
        _buildDetailRow('Position Start', record.positionStart?.toString() ?? '-'),
        _buildDetailRow('Length (mm)', record.lengthMm?.toString() ?? '-'),
        _buildDetailRow('DB', record.db?.toString() ?? '-'),
        _buildDetailRow('Depth Start', record.depthStart?.toString() ?? '-'),
      ]);
    } else if (record.testStandard == 'VT') {
      rows.addAll([
        _buildDetailRow('Yüzey Durumu', record.surfaceCondition ?? '-'),
        _buildDetailRow('Kusur Tipi', record.defectType ?? '-'),
        _buildDetailRow('Kusur Boyutu', record.defectSize?.toString() ?? '-'),
        _buildDetailRow('Konum', record.location ?? '-'),
      ]);
    } else if (record.testStandard == 'UT') {
      rows.addAll([
        _buildDetailRow('Position Start', record.positionStart?.toString() ?? '-'),
        _buildDetailRow('Length (mm)', record.lengthMm?.toString() ?? '-'),
        _buildDetailRow('Amplitude', record.amplitude?.toString() ?? '-'),
        _buildDetailRow('Depth', record.depth?.toString() ?? '-'),
      ]);
    }
    
    // Hata bölgesi her standart için
    rows.add(
      _buildDetailRow('Hata Bölgesi', record.hataBolgesi, 
          color: record.hataBolgesi == 'YOK' ? Colors.green : Colors.orange),
    );
    
    return rows;
  }

  Color _getStandardColor(String code) {
    switch (code) {
      case 'PAUT':
        return Colors.purple;
      case 'VT':
        return Colors.green;
      case 'UT':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getStandardIcon(String code) {
    switch (code) {
      case 'PAUT':
        return Icons.radar;
      case 'VT':
        return Icons.visibility;
      case 'UT':
        return Icons.graphic_eq;
      default:
        return Icons.science;
    }
  }

  String _getStandardName(String code) {
    switch (code) {
      case 'PAUT':
        return 'Phased Array Ultrasonic Testing';
      case 'VT':
        return 'Visual Testing';
      case 'UT':
        return 'Ultrasonic Testing';
      default:
        return 'NDT Testing';
    }
  }

  void _shareResult(BuildContext context) {
    final String shareText = '''
${record.testStandard} Test Sonucu: ${record.sonuc}

📋 Test Bilgileri:
• Ekip: ${record.ekip}
• Bölge: ${record.bolge}
• Conta No: ${record.contaNo}
• Tarih: ${DateFormat('dd.MM.yyyy - HH:mm').format(record.testTarihi)}

🔧 Boru Bilgileri:
• Çap: ${record.boruCap} mm
• Kalınlık: ${record.malzemeKalinlik} mm
• Malzeme: ${record.malzemeKalite}

${record.sonuc == 'OK' ? '✅' : '❌'} Sonuç: ${record.sonuc}
Hata Bölgesi: ${record.hataBolgesi}

NDT Quality Control App
    ''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Paylaşım özelliği yakında aktif olacak.'),
        backgroundColor: _getStandardColor(record.testStandard),
        action: SnackBarAction(
          label: 'Kopyala',
          textColor: Colors.white,
          onPressed: () {
            // Gelecekte clipboard'a kopyalama
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Metin kopyalandı!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}