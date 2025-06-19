class NDTRecord {
  final String? id;
  final String testStandard; // 'PAUT', 'VT', 'UT'
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
  
  // Standart bazlı test verileri
  final Map<String, dynamic> testData;
  
  final String sonuc; // "OK" veya "KES"
  final String hataBolgesi;
  final DateTime testTarihi;
  final String testEdenKullanici;

  NDTRecord({
    this.id,
    required this.testStandard,
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
    required this.testData,
    required this.sonuc,
    required this.hataBolgesi,
    required this.testTarihi,
    required this.testEdenKullanici,
  });

  // PAUT için özel getters
  double? get positionStart => testData['positionStart']?.toDouble();
  double? get lengthMm => testData['lengthMm']?.toDouble();
  double? get db => testData['db']?.toDouble();
  double? get depthStart => testData['depthStart']?.toDouble();

  // VT için özel getters
  String? get surfaceCondition => testData['surfaceCondition'];
  String? get defectType => testData['defectType'];
  double? get defectSize => testData['defectSize']?.toDouble();
  String? get location => testData['location'];

  // UT için özel getters
  double? get amplitude => testData['amplitude']?.toDouble();
  double? get depth => testData['depth']?.toDouble();

  // Firestore'a kaydetmek için Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'testStandard': testStandard,
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
      'testData': testData,
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
      testStandard: map['testStandard'] ?? 'PAUT',
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
      testData: Map<String, dynamic>.from(map['testData'] ?? {}),
      sonuc: map['sonuc'] ?? '',
      hataBolgesi: map['hataBolgesi'] ?? '',
      testTarihi: map['testTarihi']?.toDate() ?? DateTime.now(),
      testEdenKullanici: map['testEdenKullanici'] ?? '',
    );
  }

  // Test sonucunu hesaplamak için kopyalama fonksiyonu
  NDTRecord copyWith({
    String? id,
    String? testStandard,
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
    Map<String, dynamic>? testData,
    String? sonuc,
    String? hataBolgesi,
    DateTime? testTarihi,
    String? testEdenKullanici,
  }) {
    return NDTRecord(
      id: id ?? this.id,
      testStandard: testStandard ?? this.testStandard,
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
      testData: testData ?? this.testData,
      sonuc: sonuc ?? this.sonuc,
      hataBolgesi: hataBolgesi ?? this.hataBolgesi,
      testTarihi: testTarihi ?? this.testTarihi,
      testEdenKullanici: testEdenKullanici ?? this.testEdenKullanici,
    );
  }
}