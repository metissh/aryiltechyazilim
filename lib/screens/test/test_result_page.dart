import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/ndt_record.dart';
import '../../services/excel_service.dart';
import '../home/dashboard_page.dart';
import 'new_test_page.dart';
import '../../models/test_standard.dart';

class TestResultPage extends StatefulWidget {
  final NDTRecord record;

  const TestResultPage({super.key, required this.record});

  @override
  State<TestResultPage> createState() => _TestResultPageState();
}

class _TestResultPageState extends State<TestResultPage> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final bool isOK = widget.record.sonuc == 'OK';
    final Color resultColor = isOK ? Colors.green : Colors.red;
    final IconData resultIcon = isOK ? Icons.check_circle : Icons.cancel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonucu'),
        automaticallyImplyLeading: false,
        backgroundColor: _getStandardColor(widget.record.testStandard),
        foregroundColor: Colors.white,
        actions: [
          // Excel Export butonu
          IconButton(
            icon: _isExporting 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.file_download),
            onPressed: _isExporting ? null : _exportToExcel,
            tooltip: 'Excel\'e Aktar',
          ),
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
                      widget.record.sonuc,
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
                        DateFormat('dd.MM.yyyy - HH:mm').format(widget.record.testTarihi),
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
                        color: _getStandardColor(widget.record.testStandard).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getStandardIcon(widget.record.testStandard),
                        color: _getStandardColor(widget.record.testStandard),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.record.testStandard,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStandardColor(widget.record.testStandard),
                            ),
                          ),
                          Text(
                            _getStandardName(widget.record.testStandard),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Excel export mini butonu
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.table_chart, color: Colors.green),
                        onPressed: _exportToExcel,
                        tooltip: 'Excel Raporu',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Bilgileri
            _buildDetailCard('Test Bilgileri', [
              _buildDetailRow('Ekip', widget.record.ekip),
              _buildDetailRow('Bölge', widget.record.bolge),
              _buildDetailRow('Conta No', widget.record.contaNo),
              _buildDetailRow('Weld ID', widget.record.weldId),
              _buildDetailRow('Kaynakçı 1', widget.record.kaynakci1),
              if (widget.record.kaynakci2.isNotEmpty)
                _buildDetailRow('Kaynakçı 2', widget.record.kaynakci2),
            ]),

            const SizedBox(height: 16),

            // Boru Bilgileri
            _buildDetailCard('Boru Bilgileri', [
              _buildDetailRow('Çap', '${widget.record.boruCap} mm'),
              _buildDetailRow('Kalınlık', '${widget.record.malzemeKalinlik} mm'),
              _buildDetailRow('Malzeme Kalite', widget.record.malzemeKalite),
              _buildDetailRow('Değerlendirme Seviyesi', widget.record.degerlendirmeSeviyesi),
            ]),

            const SizedBox(height: 16),

            // Ölçüm Değerleri - Standart bazlı
            _buildDetailCard('${widget.record.testStandard} Ölçüm Değerleri', 
              _buildMeasurementRows(widget.record)),

            const SizedBox(height: 24),

            // Export Seçenekleri Kartı
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.file_download, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Rapor Seçenekleri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isExporting ? null : _exportToExcel,
                            icon: _isExporting 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.table_chart),
                            label: Text(_isExporting ? 'Oluşturuluyor...' : 'Excel Raporu'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _shareResult(context),
                            icon: const Icon(Icons.share),
                            label: const Text('Metin Paylaş'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Alt Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final standard = StandardTemplates.getStandard(widget.record.testStandard);
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
                      side: BorderSide(color: _getStandardColor(widget.record.testStandard)),
                      foregroundColor: _getStandardColor(widget.record.testStandard),
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
                      backgroundColor: _getStandardColor(widget.record.testStandard),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);
    
    try {
      await ExcelService.exportSingleTestToExcel(widget.record);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Excel raporu başarıyla oluşturuldu ve paylaşıldı!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Excel oluştururken hata: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
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
${widget.record.testStandard} Test Sonucu: ${widget.record.sonuc}

📋 Test Bilgileri:
• Ekip: ${widget.record.ekip}
• Bölge: ${widget.record.bolge}
• Conta No: ${widget.record.contaNo}
• Tarih: ${DateFormat('dd.MM.yyyy - HH:mm').format(widget.record.testTarihi)}

🔧 Boru Bilgileri:
• Çap: ${widget.record.boruCap} mm
• Kalınlık: ${widget.record.malzemeKalinlik} mm
• Malzeme: ${widget.record.malzemeKalite}

${widget.record.sonuc == 'OK' ? '✅' : '❌'} Sonuç: ${widget.record.sonuc}
Hata Bölgesi: ${widget.record.hataBolgesi}

NDT Quality Control App
    ''';

    // Share plus ile metin paylaşımı
    Share.share(
      shareText,
      subject: 'NDT Test Raporu - ${widget.record.testStandard}',
    );
  }
}