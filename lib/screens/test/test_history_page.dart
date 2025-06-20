import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ndt_record.dart';
import '../../services/ndt_service.dart';
import '../../services/auth_service.dart';
import '../../services/excel_service.dart';

class TestHistoryPage extends StatefulWidget {
  const TestHistoryPage({super.key});

  @override
  State<TestHistoryPage> createState() => _TestHistoryPageState();
}

class _TestHistoryPageState extends State<TestHistoryPage> {
  final NDTService _ndtService = NDTService();
  final AuthService _authService = AuthService();
  
  List<NDTRecord> _tests = [];
  bool _isLoading = true;
  bool _isExporting = false;
  String _selectedFilter = 'Tümü';
  
  final List<String> _filters = ['Tümü', 'OK', 'KES', 'PAUT', 'VT', 'UT'];

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    setState(() => _isLoading = true);
    
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final tests = await _ndtService.getUserTests(currentUser.uid, limit: 50);
        setState(() {
          _tests = tests;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<NDTRecord> get _filteredTests {
    if (_selectedFilter == 'Tümü') return _tests;
    if (_selectedFilter == 'OK' || _selectedFilter == 'KES') {
      return _tests.where((test) => test.sonuc == _selectedFilter).toList();
    }
    return _tests.where((test) => test.testStandard == _selectedFilter).toList();
  }

  Future<void> _exportAllToExcel() async {
    if (_filteredTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export edilecek test bulunamadı.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);
    
    try {
      await ExcelService.exportMultipleTestsToExcel(_filteredTests);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('${_filteredTests.length} test Excel\'e aktarıldı!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Geçmişi'),
        backgroundColor: Colors.blue,
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
            onPressed: _isExporting ? null : _exportAllToExcel,
            tooltip: 'Tümünü Excel\'e Aktar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre ve Export Bölümü
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtrele:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_filteredTests.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportAllToExcel,
                        icon: _isExporting 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.table_chart, size: 16),
                        label: Text(_isExporting ? 'Aktarılıyor...' : 'Excel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: Colors.blue.withOpacity(0.3),
                      checkmarkColor: Colors.blue,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // İstatistik Kartı
          Container(
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedFilter == 'Tümü' 
                              ? 'Tüm Testler'
                              : '$_selectedFilter Filtresinde',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        if (_filteredTests.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_filteredTests.length} test',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatChip('Toplam', _tests.length, Colors.blue),
                        _buildStatChip('OK', _tests.where((t) => t.sonuc == 'OK').length, Colors.green),
                        _buildStatChip('KES', _tests.where((t) => t.sonuc == 'KES').length, Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Test Listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTests.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTests,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTests.length,
                          itemBuilder: (context, index) {
                            final test = _filteredTests[index];
                            return _buildTestCard(test);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTestCard(NDTRecord test) {
    final isOK = test.sonuc == 'OK';
    final resultColor = isOK ? Colors.green : Colors.red;
    final standardColor = _getStandardColor(test.testStandard);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: standardColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showTestDetails(test),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır: Standart + Sonuç + Excel butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: standardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getStandardIcon(test.testStandard),
                          color: standardColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.testStandard,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: standardColor,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            test.bolge,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Excel export mini butonu
                      InkWell(
                        onTap: () => _exportSingleTest(test),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.table_chart,
                            color: Colors.green,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: resultColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: resultColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOK ? Icons.check_circle : Icons.cancel,
                              color: resultColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              test.sonuc,
                              style: TextStyle(
                                color: resultColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Test bilgileri
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(Icons.location_on, 'Conta', test.contaNo),
                  ),
                  Expanded(
                    child: _buildInfoRow(Icons.group, 'Ekip', test.ekip),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(Icons.person, 'Kaynakçı', test.kaynakci1),
                  ),
                  Expanded(
                    child: _buildInfoRow(Icons.access_time, 'Tarih', 
                        DateFormat('dd.MM.yy HH:mm').format(test.testTarihi)),
                  ),
                ],
              ),

              // Hata bölgesi (eğer KES ise)
              if (!isOK) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Hata: ${test.hataBolgesi}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportSingleTest(NDTRecord test) async {
    try {
      await ExcelService.exportSingleTestToExcel(test);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('${test.testStandard} testi Excel\'e aktarıldı!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'Tümü' 
                ? 'Henüz test kaydınız yok'
                : '$_selectedFilter filtresi için test bulunamadı',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bir test yapmak için ana sayfaya dönün',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Test'),
          ),
        ],
      ),
    );
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

  void _showTestDetails(NDTRecord test) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStandardColor(test.testStandard).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStandardIcon(test.testStandard),
                        color: _getStandardColor(test.testStandard),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${test.testStandard} Test Detayı',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy - HH:mm').format(test.testTarihi),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Excel export butonu
                    IconButton(
                      icon: const Icon(Icons.table_chart),
                      color: Colors.green,
                      onPressed: () {
                        Navigator.pop(context);
                        _exportSingleTest(test);
                      },
                      tooltip: 'Excel\'e Aktar',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (test.sonuc == 'OK' ? Colors.green : Colors.red).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        test.sonuc,
                        style: TextStyle(
                          color: test.sonuc == 'OK' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Detaylar
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Test Bilgileri', [
                          _buildDetailRow('Ekip', test.ekip),
                          _buildDetailRow('Bölge', test.bolge),
                          _buildDetailRow('Conta No', test.contaNo),
                          _buildDetailRow('Weld ID', test.weldId),
                          _buildDetailRow('Kaynakçı 1', test.kaynakci1),
                          if (test.kaynakci2.isNotEmpty)
                            _buildDetailRow('Kaynakçı 2', test.kaynakci2),
                        ]),
                        
                        _buildDetailSection('Boru Bilgileri', [
                          _buildDetailRow('Çap', '${test.boruCap} mm'),
                          _buildDetailRow('Kalınlık', '${test.malzemeKalinlik} mm'),
                          _buildDetailRow('Malzeme', test.malzemeKalite),
                          _buildDetailRow('Seviye', test.degerlendirmeSeviyesi),
                        ]),
                        
                        _buildDetailSection('Test Verileri', 
                          _buildTestDataRows(test)),
                          
                        _buildDetailSection('Sonuç', [
                          _buildDetailRow('Durum', test.sonuc),
                          _buildDetailRow('Hata Bölgesi', test.hataBolgesi),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTestDataRows(NDTRecord test) {
    List<Widget> rows = [];
    
    if (test.testStandard == 'PAUT') {
      rows.addAll([
        _buildDetailRow('Position Start', test.positionStart?.toString() ?? '-'),
        _buildDetailRow('Length (mm)', test.lengthMm?.toString() ?? '-'),
        _buildDetailRow('DB', test.db?.toString() ?? '-'),
        _buildDetailRow('Depth Start', test.depthStart?.toString() ?? '-'),
      ]);
    } else if (test.testStandard == 'VT') {
      rows.addAll([
        _buildDetailRow('Yüzey Durumu', test.surfaceCondition ?? '-'),
        _buildDetailRow('Kusur Tipi', test.defectType ?? '-'),
        _buildDetailRow('Kusur Boyutu', test.defectSize?.toString() ?? '-'),
        _buildDetailRow('Konum', test.location ?? '-'),
      ]);
    } else if (test.testStandard == 'UT') {
      rows.addAll([
        _buildDetailRow('Position Start', test.positionStart?.toString() ?? '-'),
        _buildDetailRow('Length (mm)', test.lengthMm?.toString() ?? '-'),
        _buildDetailRow('Amplitude', test.amplitude?.toString() ?? '-'),
        _buildDetailRow('Depth', test.depth?.toString() ?? '-'),
      ]);
    }
    
    return rows;
  }
}