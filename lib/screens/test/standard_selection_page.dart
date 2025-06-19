import 'package:flutter/material.dart';
import '../../models/test_standard.dart';
import 'new_test_page.dart';

class StandardSelectionPage extends StatefulWidget {
  const StandardSelectionPage({super.key});

  @override
  State<StandardSelectionPage> createState() => _StandardSelectionPageState();
}

class _StandardSelectionPageState extends State<StandardSelectionPage> {
  String? selectedStandardCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Standardı Seçin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Kartı
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.science,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NDT Test Standardı',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kullanmak istediğiniz test yöntemini seçin',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Mevcut Standartlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Standart Listesi
            Expanded(
              child: ListView.builder(
                itemCount: StandardTemplates.availableStandards.length,
                itemBuilder: (context, index) {
                  final standard = StandardTemplates.availableStandards[index];
                  final isSelected = selectedStandardCode == standard.code;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 8 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? _getStandardColor(standard.code) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedStandardCode = standard.code;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Standard Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getStandardColor(standard.code).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getStandardIcon(standard.code),
                                color: _getStandardColor(standard.code),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Standard Bilgileri
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        standard.code,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _getStandardColor(standard.code),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (standard.code == 'PAUT')
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'GELİŞMİŞ',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    standard.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    standard.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Gerekli alanlar preview
                                  Wrap(
                                    spacing: 4,
                                    children: standard.requiredFields.take(3).map((field) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _getFieldDisplayName(field),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Seçim Göstergesi
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? _getStandardColor(standard.code) : Colors.grey,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // Alt Navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: selectedStandardCode != null ? _proceedWithStandard : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedStandardCode != null 
                ? _getStandardColor(selectedStandardCode!) 
                : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_forward),
              const SizedBox(width: 8),
              Text(
                selectedStandardCode != null 
                    ? '$selectedStandardCode ile Devam Et' 
                    : 'Standart Seçin',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
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

  String _getFieldDisplayName(String field) {
    const fieldNames = {
      'positionStart': 'Pozisyon',
      'lengthMm': 'Uzunluk',
      'db': 'DB',
      'depthStart': 'Derinlik',
      'defectType': 'Kusur Tipi',
      'defectSize': 'Kusur Boyutu',
      'location': 'Konum',
      'severity': 'Şiddet',
      'amplitude': 'Genlik',
      'depth': 'Derinlik',
      'position': 'Pozisyon',
      'angle': 'Açı',
    };
    return fieldNames[field] ?? field;
  }

  void _proceedWithStandard() {
    if (selectedStandardCode != null) {
      final standard = StandardTemplates.getStandard(selectedStandardCode!);
      if (standard != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewTestPage(selectedStandard: standard),
          ),
        );
      }
    }
  }
}