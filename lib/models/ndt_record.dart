class NDTRecord {
  final String? id;
  final String ekip;
  final String bolge;
  final String contaNo;
  final String weldId;
  final String kaynakci1;
  final String kaynakci2;
  final double boruCap;
  final double malzemeKalinlik;
  final String malzemeKalite;
  final String degerlendirmeSeviyesi;
  final double positionStart;
  final double lengthMm;
  final double db;
  final double depthStart;
  final String sonuc; // "OK" veya "KES"
  final String hataBolgesi;
  final DateTime testTarihi;
  final String testEdenKullanici;

  NDTRecord({
    this.id,
    required this.ekip,
    required this.bolge,
    required this.contaNo,
    required this.weldId,
    required this.kaynakci1,
    required this.kaynakci2,
    required this.boruCap,
    required this.malzemeKalinlik,
    required this.malzemeKalite,
    required this.degerlendirmeSeviyesi,
    required this.positionStart,
    required this.lengthMm,
    required this.db,
    required this.depthStart,
    required this.sonuc,
    required this.hataBolgesi,
    required this.testTarihi,
    required this.testEdenKullanici,
  });

  // Firestore'a kaydetmek için Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'ekip': ekip,
      'bolge': bolge,
      'contaNo': contaNo,
      'weldId': weldId,
      'kaynakci1': kaynakci1,
      'kaynakci2': kaynakci2,
      'boruCap': boruCap,
      'malzemeKalinlik': malzemeKalinlik,
      'malzemeKalite': malzemeKalite,
      'degerlendirmeSeviyesi': degerlendirmeSeviyesi,
      'positionStart': positionStart,
      'lengthMm': lengthMm,
      'db': db,
      'depthStart': depthStart,
      'sonuc': sonuc,
      'hataBolgesi': hataBolgesi,
      'testTarihi': testTarihi,
      'testEdenKullanici': testEdenKullanici,
    };
  }

  // Firestore'dan Map'i objeye çevir
  factory NDTRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return NDTRecord(
      id: documentId,
      ekip: map['ekip'] ?? '',
      bolge: map['bolge'] ?? '',
      contaNo: map['contaNo'] ?? '',
      weldId: map['weldId'] ?? '',
      kaynakci1: map['kaynakci1'] ?? '',
      kaynakci2: map['kaynakci2'] ?? '',
      boruCap: (map['boruCap'] ?? 0).toDouble(),
      malzemeKalinlik: (map['malzemeKalinlik'] ?? 0).toDouble(),
      malzemeKalite: map['malzemeKalite'] ?? '',
      degerlendirmeSeviyesi: map['degerlendirmeSeviyesi'] ?? '',
      positionStart: (map['positionStart'] ?? 0).toDouble(),
      lengthMm: (map['lengthMm'] ?? 0).toDouble(),
      db: (map['db'] ?? 0).toDouble(),
      depthStart: (map['depthStart'] ?? 0).toDouble(),
      sonuc: map['sonuc'] ?? '',
      hataBolgesi: map['hataBolgesi'] ?? '',
      testTarihi: map['testTarihi']?.toDate() ?? DateTime.now(),
      testEdenKullanici: map['testEdenKullanici'] ?? '',
    );
  }

  // Test sonucunu hesaplamak için kopyalama fonksiyonu
  NDTRecord copyWith({
    String? id,
    String? ekip,
    String? bolge,
    String? contaNo,
    String? weldId,
    String? kaynakci1,
    String? kaynakci2,
    double? boruCap,
    double? malzemeKalinlik,
    String? malzemeKalite,
    String? degerlendirmeSeviyesi,
    double? positionStart,
    double? lengthMm,
    double? db,
    double? depthStart,
    String? sonuc,
    String? hataBolgesi,
    DateTime? testTarihi,
    String? testEdenKullanici,
  }) {
    return NDTRecord(
      id: id ?? this.id,
      ekip: ekip ?? this.ekip,
      bolge: bolge ?? this.bolge,
      contaNo: contaNo ?? this.contaNo,
      weldId: weldId ?? this.weldId,
      kaynakci1: kaynakci1 ?? this.kaynakci1,
      kaynakci2: kaynakci2 ?? this.kaynakci2,
      boruCap: boruCap ?? this.boruCap,
      malzemeKalinlik: malzemeKalinlik ?? this.malzemeKalinlik,
      malzemeKalite: malzemeKalite ?? this.malzemeKalite,
      degerlendirmeSeviyesi: degerlendirmeSeviyesi ?? this.degerlendirmeSeviyesi,
      positionStart: positionStart ?? this.positionStart,
      lengthMm: lengthMm ?? this.lengthMm,
      db: db ?? this.db,
      depthStart: depthStart ?? this.depthStart,
      sonuc: sonuc ?? this.sonuc,
      hataBolgesi: hataBolgesi ?? this.hataBolgesi,
      testTarihi: testTarihi ?? this.testTarihi,
      testEdenKullanici: testEdenKullanici ?? this.testEdenKullanici,
    );
  }
}