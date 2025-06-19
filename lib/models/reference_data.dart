class ReferenceData {
  final String id;
  final String boruTipi;
  final String paket;
  final double cap;
  final double kalinlik;
  final String malzemeKalite;
  final ASeviye aSeviye;
  final BSeviye bSeviye;
  final double maxDerinlik;

  ReferenceData({
    required this.id,
    required this.boruTipi,
    required this.paket,
    required this.cap,
    required this.kalinlik,
    required this.malzemeKalite,
    required this.aSeviye,
    required this.bSeviye,
    required this.maxDerinlik,
  });

  Map<String, dynamic> toMap() {
    return {
      'boruTipi': boruTipi,
      'paket': paket,
      'cap': cap,
      'kalinlik': kalinlik,
      'malzemeKalite': malzemeKalite,
      'aSeviye': aSeviye.toMap(),
      'bSeviye': bSeviye.toMap(),
      'maxDerinlik': maxDerinlik,
    };
  }

  factory ReferenceData.fromMap(Map<String, dynamic> map, String documentId) {
    return ReferenceData(
      id: documentId,
      boruTipi: map['boruTipi'] ?? '',
      paket: map['paket'] ?? '',
      cap: (map['cap'] ?? 0).toDouble(),
      kalinlik: (map['kalinlik'] ?? 0).toDouble(),
      malzemeKalite: map['malzemeKalite'] ?? '',
      aSeviye: ASeviye.fromMap(map['aSeviye'] ?? {}),
      bSeviye: BSeviye.fromMap(map['bSeviye'] ?? {}),
      maxDerinlik: (map['maxDerinlik'] ?? 0).toDouble(),
    );
  }
}

class ASeviye {
  final double uzunluk;
  final double yukseklikMin;
  final double yukseklikMax;

  ASeviye({
    required this.uzunluk,
    required this.yukseklikMin,
    required this.yukseklikMax,
  });

  Map<String, dynamic> toMap() {
    return {
      'uzunluk': uzunluk,
      'yukseklikMin': yukseklikMin,
      'yukseklikMax': yukseklikMax,
    };
  }

  factory ASeviye.fromMap(Map<String, dynamic> map) {
    return ASeviye(
      uzunluk: (map['uzunluk'] ?? 0).toDouble(),
      yukseklikMin: (map['yukseklikMin'] ?? 0).toDouble(),
      yukseklikMax: (map['yukseklikMax'] ?? 0).toDouble(),
    );
  }
}

class BSeviye {
  final double uzunluk;
  final double yukseklikMin;
  final double yukseklikMax;

  BSeviye({
    required this.uzunluk,
    required this.yukseklikMin,
    required this.yukseklikMax,
  });

  Map<String, dynamic> toMap() {
    return {
      'uzunluk': uzunluk,
      'yukseklikMin': yukseklikMin,
      'yukseklikMax': yukseklikMax,
    };
  }

  factory BSeviye.fromMap(Map<String, dynamic> map) {
    return BSeviye(
      uzunluk: (map['uzunluk'] ?? 0).toDouble(),
      yukseklikMin: (map['yukseklikMin'] ?? 0).toDouble(),
      yukseklikMax: (map['yukseklikMax'] ?? 0).toDouble(),
    );
  }
}
