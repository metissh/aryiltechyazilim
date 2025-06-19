import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/ndt_record.dart';
import '../../services/ndt_service.dart';
import 'test_result_page.dart';

class NewTestPage extends StatefulWidget {
  const NewTestPage({super.key});

  @override
  State<NewTestPage> createState() => _NewTestPageState();
}

class _NewTestPageState extends State<NewTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  // Form controllers
  final _bolgeController = TextEditingController();
  final _contaNoController = TextEditingController();
  final _weldIdController = TextEditingController();
  final _kaynakci1Controller = TextEditingController();
  final _kaynakci2Controller = TextEditingController();
  final _boruCapController = TextEditingController();
  final _malzemeKalinlikController = TextEditingController();
  final _positionStartController = TextEditingController();
  final _lengthController = TextEditingController();
  final _dbController = TextEditingController();
  final _depthStartController = TextEditingController();
  
  // Dropdown değerleri
  String _selectedEkip = 'Ekip A';
  String _selectedMalzemeKalite = '16Mo3';
  String _selectedDegerlendirmeSeviyesi = 'KÖK';
  
  int _currentPage = 0;
  bool _isLoading = false;

  final List<String> _ekipList = ['Ekip A', 'Ekip B', 'Ekip C', 'Vardiya 1', 'Vardiya 2'];
  final List<String> _malzemeKaliteList = ['16Mo3', '13CrMo4-5', 'P235GH', 'P265GH'];
  final List<String> _degerlendirmeSeviyesiList = ['KÖK', 'DOLGU', 'KAPATMA'];

  @override
  void dispose() {
    _bolgeController.dispose();
    _contaNoController.dispose();
    _weldIdController.dispose();
    _kaynakci1Controller.dispose();
    _kaynakci2Controller.dispose();
    _boruCapController.dispose();
    _malzemeKalinlikController.dispose();
    _positionStartController.dispose();
    _lengthController.dispose();
    _dbController.dispose();
    _depthStartController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitTest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Değerleri parse et
      double boruCap = double.parse(_boruCapController.text);
      double malzemeKalinlik = double.parse(_malzemeKalinlikController.text);
      double positionStart = double.parse(_positionStartController.text);
      double lengthMm = double.parse(_lengthController.text);
      double db = double.parse(_dbController.text);
      double depthStart = double.parse(_depthStartController.text);

      // Test sonucunu hesapla
      String sonuc = NDTService.calculateTestResult(
        positionStart: positionStart,
        lengthMm: lengthMm,
        db: db,
        depthStart: depthStart,
      );

      // Hata bölgesini belirle
      String hataBolgesi = NDTService.determineErrorRegion(
        sonuc: sonuc,
        degerlendirmeSeviyesi: _selectedDegerlendirmeSeviyesi,
      );

      // NDT kaydı oluştur
      NDTRecord record = NDTRecord(
        ekip: _selectedEkip,
        bolge: _bolgeController.text,
        contaNo: _contaNoController.text,
        weldId: _weldIdController.text,
        kaynakci1: _kaynakci1Controller.text,
        kaynakci2: _kaynakci2Controller.text,
        boruCap: boruCap,
        malzemeKalinlik: malzemeKalinlik,
        malzemeKalite: _selectedMalzemeKalite,
        degerlendirmeSeviyesi: _selectedDegerlendirmeSeviyesi,
        positionStart: positionStart,
        lengthMm: lengthMm,
        db: db,
        depthStart: depthStart,
        sonuc: sonuc,
        hataBolgesi: hataBolgesi,
        testTarihi: DateTime.now(),
        testEdenKullanici: FirebaseAuth.instance.currentUser!.uid,
      );

      // Firestore'a kaydet
      await NDTService().addNDTRecord(record);

      if (mounted) {
        // Sonuç sayfasına git
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TestResultPage(record: record),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni NDT Testi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            backgroundColor: Colors.blue[100],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _buildTestInfoPage(),
            _buildBoruBilgileriPage(),
            _buildOlcumDegerleriPage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildTestInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. Test Bilgileri',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Ekip Seçimi
          DropdownButtonFormField<String>(
            value: _selectedEkip,
            decoration: const InputDecoration(
              labelText: 'Ekip',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.group),
            ),
            items: _ekipList.map((ekip) => DropdownMenuItem(
              value: ekip,
              child: Text(ekip),
            )).toList(),
            onChanged: (value) => setState(() => _selectedEkip = value!),
          ),
          const SizedBox(height: 16),

          // Bölge
          TextFormField(
            controller: _bolgeController,
            decoration: const InputDecoration(
              labelText: 'Bölge',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
              hintText: 'Örn: 57KOLLEKTÖR',
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Bölge gerekli' : null,
          ),
          const SizedBox(height: 16),

          // Conta No
          TextFormField(
            controller: _contaNoController,
            decoration: const InputDecoration(
              labelText: 'Conta No',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
              hintText: 'Örn: BK1-154-2',
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Conta No gerekli' : null,
          ),
          const SizedBox(height: 16),

          // Weld ID
          TextFormField(
            controller: _weldIdController,
            decoration: const InputDecoration(
              labelText: 'Weld ID',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.settings),
              hintText: 'Otomatik oluşturulacak',
            ),
          ),
          const SizedBox(height: 16),

          // Kaynakçı 1
          TextFormField(
            controller: _kaynakci1Controller,
            decoration: const InputDecoration(
              labelText: 'Kaynakçı No 1',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Kaynakçı No 1 gerekli' : null,
          ),
          const SizedBox(height: 16),

          // Kaynakçı 2
          TextFormField(
            controller: _kaynakci2Controller,
            decoration: const InputDecoration(
              labelText: 'Kaynakçı No 2 (Opsiyonel)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoruBilgileriPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. Boru Bilgileri',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Boru Çap
          TextFormField(
            controller: _boruCapController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Boru Çap (mm)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.radio_button_unchecked),
              hintText: 'Örn: 26.9',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Boru çap gerekli';
              if (double.tryParse(value!) == null) return 'Geçerli sayı girin';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Malzeme Kalınlık
          TextFormField(
            controller: _malzemeKalinlikController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Malzeme Kalınlık (mm)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.line_weight),
              hintText: 'Örn: 5.6',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Kalınlık gerekli';
              if (double.tryParse(value!) == null) return 'Geçerli sayı girin';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Malzeme Kalite
          DropdownButtonFormField<String>(
            value: _selectedMalzemeKalite,
            decoration: const InputDecoration(
              labelText: 'Malzeme Kalite',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: _malzemeKaliteList.map((kalite) => DropdownMenuItem(
              value: kalite,
              child: Text(kalite),
            )).toList(),
            onChanged: (value) => setState(() => _selectedMalzemeKalite = value!),
          ),
          const SizedBox(height: 16),

          // Değerlendirme Seviyesi
          DropdownButtonFormField<String>(
            value: _selectedDegerlendirmeSeviyesi,
            decoration: const InputDecoration(
              labelText: 'Değerlendirme Seviyesi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.layers),
            ),
            items: _degerlendirmeSeviyesiList.map((seviye) => DropdownMenuItem(
              value: seviye,
              child: Text(seviye),
            )).toList(),
            onChanged: (value) => setState(() => _selectedDegerlendirmeSeviyesi = value!),
          ),
          const SizedBox(height: 20),

          // Bilgi kartı
          Card(
            color: Colors.blue[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bu bilgiler referans verilerle eşleştirilecek ve otomatik hesaplama yapılacaktır.',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOlcumDegerleriPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3. Ölçüm Değerleri',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Position Start
          TextFormField(
            controller: _positionStartController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Position Start',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.start),
              hintText: 'Örn: 32.4',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Position Start gerekli';
              if (double.tryParse(value!) == null) return 'Geçerli sayı girin';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Length (mm)
          TextFormField(
            controller: _lengthController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Length (mm)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.straighten),
              hintText: 'Örn: 5.4',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Length gerekli';
              if (double.tryParse(value!) == null) return 'Geçerli sayı girin';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // DB
          TextFormField(
            controller: _dbController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'DB',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.height),
              hintText: 'Örn: 6.0',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'DB gerekli';
              if (double.tryParse(value!) == null) return 'Geçerli sayı girin';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Depth Start
          TextFormField(
            controller: _depthStartController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Depth Start',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.vertical_align_bottom),
              hintText: 'Örn: 3.9',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Depth Start gerekli';
              if (double.tryParse(value!) == null) return 'Geçerli sayı girin';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Gerçek zamanlı hesaplama kartı
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calculate, color: Colors.orange),
                      SizedBox(width: 12),
                      Text(
                        'Gerçek Zamanlı Hesaplama',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPreviewResult(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getPreviewResult().contains('OK') ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPreviewResult() {
    try {
      if (_positionStartController.text.isNotEmpty &&
          _lengthController.text.isNotEmpty &&
          _dbController.text.isNotEmpty &&
          _depthStartController.text.isNotEmpty) {
        
        double position = double.parse(_positionStartController.text);
        double length = double.parse(_lengthController.text);
        double db = double.parse(_dbController.text);
        double depth = double.parse(_depthStartController.text);
        
        String result = NDTService.calculateTestResult(
          positionStart: position,
          lengthMm: length,
          db: db,
          depthStart: depth,
        );
        
        return result == 'OK' ? '✅ Ön Sonuç: OK' : '❌ Ön Sonuç: KES';
      }
    } catch (e) {
      // Geçersiz değerler
    }
    return 'Değerleri girin...';
  }

  Widget _buildBottomNavigation() {
    return Container(
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
      child: Row(
        children: [
          // Geri butonu
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Geri'),
              ),
            ),
          
          if (_currentPage > 0) const SizedBox(width: 16),
          
          // İleri/Bitir butonu
          Expanded(
            flex: _currentPage == 0 ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : (_currentPage == 2 ? _submitTest : _nextPage),
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(_currentPage == 2 ? Icons.check : Icons.arrow_forward),
              label: Text(_currentPage == 2 ? 'Testi Tamamla' : 'İleri'),
            ),
          ),
        ],
      ),
    );
  }
}