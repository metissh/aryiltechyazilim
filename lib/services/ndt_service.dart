import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ndt_record.dart';
import '../models/reference_data.dart';

class NDTService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Test sonucunu hesapla (basit versiyon)
  static String calculateTestResult({
    required double positionStart,
    required double lengthMm,
    required double db,
    required double depthStart,
    ReferenceData? referenceData,
  }) {
    // Basit hesaplama mantığı - Excel'deki detaylı hesaplamalar sonra eklenecek
    
    // Eğer referans veri yoksa, basit kurallara göre karar ver
    if (referenceData == null) {
      return _basicCalculation(positionStart, lengthMm, db, depthStart);
    }

    // Referans veriye göre hesaplama
    return _advancedCalculation(
      positionStart, lengthMm, db, depthStart, referenceData);
  }

  // Basit hesaplama (referans veri yokken)
  static String _basicCalculation(double position, double length, double db, double depth) {
    // Basit tolerans değerleri
    if (db > 6.0) return 'KES'; // DB değeri çok yüksek
    if (depth > 4.0) return 'KES'; // Derinlik çok fazla
    if (length > 10.0) return 'KES'; // Uzunluk çok fazla
    
    return 'OK';
  }

  // Gelişmiş hesaplama (referans veri ile)
  static String _advancedCalculation(
    double position, double length, double db, double depth, ReferenceData ref) {
    
    // A Seviye kontrolü
    if (length <= ref.aSeviye.uzunluk) {
      if (db >= ref.aSeviye.yukseklikMin && db <= ref.aSeviye.yukseklikMax) {
        if (depth <= ref.maxDerinlik) {
          return 'OK';
        }
      }
    }
    
    // B Seviye kontrolü
    if (length <= ref.bSeviye.uzunluk) {
      if (db >= ref.bSeviye.yukseklikMin && db <= ref.bSeviye.yukseklikMax) {
        if (depth <= ref.maxDerinlik) {
          return 'OK';
        }
      }
    }
    
    return 'KES';
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