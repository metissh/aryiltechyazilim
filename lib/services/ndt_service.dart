import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ndt_record.dart';
import '../models/reference_data.dart';

class NDTService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constructor - hiç parametre almıyor
  NDTService();

  // NDT test kaydı ekle
  Future<String> addNDTRecord(NDTRecord record) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('ndt_records')
          .add(record.toMap());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Test kaydı eklenirken hata: $e');
    }
  }

  // Referans veri getir (boru özelliklerine göre)
  Future<ReferenceData?> getReferenceData({
    required double cap,
    required double kalinlik,
    required String malzemeKalite,
  }) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('reference_data')
          .where('cap', isEqualTo: cap)
          .where('kalinlik', isEqualTo: kalinlik)
          .where('malzemeKalite', isEqualTo: malzemeKalite)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return ReferenceData.fromMap(
          query.docs.first.data() as Map<String, dynamic>,
          query.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Referans veri alınırken hata: $e');
      return null;
    }
  }

  // Kullanıcının son testlerini getir
  Future<List<NDTRecord>> getUserTests(String userId, {int limit = 10}) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('ndt_records')
          .where('testEdenKullanici', isEqualTo: userId)
          .orderBy('testTarihi', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => NDTRecord.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      print('Kullanıcı testleri alınırken hata: $e');
      return [];
    }
  }

  // Günlük test istatistikleri
  Future<Map<String, int>> getDailyStats(String userId) async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot query = await _firestore
          .collection('ndt_records')
          .where('testEdenKullanici', isEqualTo: userId)
          .where('testTarihi', isGreaterThanOrEqualTo: startOfDay)
          .where('testTarihi', isLessThan: endOfDay)
          .get();

      int totalTests = query.docs.length;
      int okTests = query.docs.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['sonuc'] == 'OK';
      }).length;
      int kesTests = totalTests - okTests;

      return {
        'total': totalTests,
        'ok': okTests,
        'kes': kesTests,
      };
    } catch (e) {
      print('Günlük istatistikler alınırken hata: $e');
      return {'total': 0, 'ok': 0, 'kes': 0};
    }
  }

  // Test sonucunu hesapla (standart bazlı)
  static String calculateTestResult({
    required String testStandard,
    required Map<String, dynamic> testData,
    ReferenceData? referenceData,
  }) {
    switch (testStandard) {
      case 'PAUT':
        return _calculatePAUTResult(testData, referenceData);
      case 'VT':
        return _calculateVTResult(testData);
      case 'UT':
        return _calculateUTResult(testData, referenceData);
      default:
        return 'OK';
    }
  }

  // PAUT hesaplama
  static String _calculatePAUTResult(Map<String, dynamic> data, ReferenceData? ref) {
    double db = data['db']?.toDouble() ?? 0;
    double depth = data['depthStart']?.toDouble() ?? 0;
    double length = data['lengthMm']?.toDouble() ?? 0;
    
    if (db > 6.0) return 'KES';
    if (depth > 4.0) return 'KES';
    if (length > 10.0) return 'KES';
    
    return 'OK';
  }

  // VT hesaplama
  static String _calculateVTResult(Map<String, dynamic> data) {
    double? defectSize = data['defectSize']?.toDouble();
    if (defectSize != null && defectSize > 2.0) return 'KES';
    return 'OK';
  }

  // UT hesaplama
  static String _calculateUTResult(Map<String, dynamic> data, ReferenceData? ref) {
    double amplitude = data['amplitude']?.toDouble() ?? 0;
    double depth = data['depth']?.toDouble() ?? 0;
    
    if (amplitude > 20.0) return 'KES';
    if (depth > 4.0) return 'KES';
    
    return 'OK';
  }

  // Hata bölgesini belirle
  static String determineErrorRegion({
    required String sonuc,
    required String degerlendirmeSeviyesi,
  }) {
    if (sonuc == 'OK') {
      return 'YOK';
    } else {
      return degerlendirmeSeviyesi; // KÖK, DOLGU vs.
    }
  }
}