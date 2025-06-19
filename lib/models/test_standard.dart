class TestStandard {
  final String code; // 'PAUT', 'VT', 'UT'
  final String name;
  final String description;
  final List<String> requiredFields;
  final Map<String, dynamic> parameters;

  TestStandard({
    required this.code,
    required this.name,
    required this.description,
    required this.requiredFields,
    required this.parameters,
  });
}

// Önceden tanımlı standartlar
class StandardTemplates {
  static final List<TestStandard> availableStandards = [
    // PAUT - Mevcut sistemimiz
    TestStandard(
      code: 'PAUT',
      name: 'Phased Array Ultrasonic Testing',
      description: 'Fazlı Dizi Ultrasonik Test - Gelişmiş UT yöntemi',
      requiredFields: ['positionStart', 'lengthMm', 'db', 'depthStart'],
      parameters: {
        'toleranceDb': 6.0,
        'toleranceDepth': 4.0,
        'toleranceLength': 10.0,
      },
    ),
    
    // VT - Visual Testing
    TestStandard(
      code: 'VT',
      name: 'Visual Testing',
      description: 'Görsel Muayene - Yüzey kusurlarının görsel tespiti',
      requiredFields: ['defectType', 'defectSize', 'location', 'severity'],
      parameters: {
        'maxDefectSize': 2.0,
        'acceptableDefects': ['Hafif çizik', 'Küçük leke'],
        'criticalDefects': ['Çatlak', 'Gözenek', 'Korozyon'],
      },
    ),
    
    // UT - Ultrasonic Testing
    TestStandard(
      code: 'UT',
      name: 'Ultrasonic Testing',
      description: 'Ultrasonik Test - Geleneksel ultrasonik muayene',
      requiredFields: ['amplitude', 'depth', 'position', 'angle'],
      parameters: {
        'maxAmplitude': 80.0,
        'maxDepth': 50.0,
        'standardAngles': [45, 60, 70],
        'frequency': 2.25,
      },
    ),
  ];
  
  // Standart koduna göre standart getir
  static TestStandard? getStandard(String code) {
    try {
      return availableStandards.firstWhere((s) => s.code == code);
    } catch (e) {
      return null;
    }
  }
}