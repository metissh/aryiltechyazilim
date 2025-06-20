import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/ndt_record.dart';

class ExcelService {
  static Future<void> exportSingleTestToExcel(NDTRecord record) async {
    try {
      // Excel dosyası oluştur
      var excel = Excel.createExcel();
      
      // Default sheet'i sil ve yeni sheet ekle
      excel.delete('Sheet1');
      Sheet sheet = excel['NDT Test Raporu'];

      // Title
      var titleCell = sheet.cell(CellIndex.indexByString('A1'));
      titleCell.value = TextCellValue('NDT TEST RAPORU');
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
      );
      sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('F1'));

      int currentRow = 3;

      // Test Bilgileri Bölümü
      _addSectionHeader(sheet, 'A$currentRow', 'TEST BİLGİLERİ');
      currentRow += 2;

      final testInfo = [
        ['Test Standardı:', record.testStandard],
        ['Test Tarihi:', DateFormat('dd.MM.yyyy HH:mm').format(record.testTarihi)],
        ['Ekip:', record.ekip],
        ['Bölge:', record.bolge],
        ['Conta No:', record.contaNo],
        ['Weld ID:', record.weldId],
        ['Kaynakçı 1:', record.kaynakci1],
        ['Kaynakçı 2:', record.kaynakci2.isEmpty ? '-' : record.kaynakci2],
      ];

      for (var info in testInfo) {
        sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue(info[0]);
        sheet.cell(CellIndex.indexByString('B$currentRow')).value = TextCellValue(info[1]);
        currentRow++;
      }

      currentRow += 2;

      // Boru Bilgileri Bölümü
      _addSectionHeader(sheet, 'A$currentRow', 'BORU BİLGİLERİ');
      currentRow += 2;

      final boruInfo = [
        ['Boru Çap (mm):', record.boruCap.toString()],
        ['Malzeme Kalınlık (mm):', record.malzemeKalinlik.toString()],
        ['Malzeme Kalite:', record.malzemeKalite],
        ['Değerlendirme Seviyesi:', record.degerlendirmeSeviyesi],
      ];

      for (var info in boruInfo) {
        sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue(info[0]);
        sheet.cell(CellIndex.indexByString('B$currentRow')).value = TextCellValue(info[1]);
        currentRow++;
      }

      currentRow += 2;

      // Test Verileri Bölümü
      _addSectionHeader(sheet, 'A$currentRow', '${record.testStandard} ÖLÇÜM DEĞERLERİ');
      currentRow += 2;

      // Standart bazlı test verileri
      List<List<String>> testData = [];
      
      if (record.testStandard == 'PAUT') {
        testData = [
          ['Position Start:', record.positionStart?.toString() ?? '-'],
          ['Length (mm):', record.lengthMm?.toString() ?? '-'],
          ['DB:', record.db?.toString() ?? '-'],
          ['Depth Start:', record.depthStart?.toString() ?? '-'],
        ];
      } else if (record.testStandard == 'VT') {
        testData = [
          ['Yüzey Durumu:', record.surfaceCondition ?? '-'],
          ['Kusur Tipi:', record.defectType ?? '-'],
          ['Kusur Boyutu (mm):', record.defectSize?.toString() ?? '-'],
          ['Konum:', record.location ?? '-'],
        ];
      } else if (record.testStandard == 'UT') {
        testData = [
          ['Position Start:', record.positionStart?.toString() ?? '-'],
          ['Length (mm):', record.lengthMm?.toString() ?? '-'],
          ['Amplitude:', record.amplitude?.toString() ?? '-'],
          ['Depth:', record.depth?.toString() ?? '-'],
        ];
      }

      for (var data in testData) {
        sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue(data[0]);
        sheet.cell(CellIndex.indexByString('B$currentRow')).value = TextCellValue(data[1]);
        currentRow++;
      }

      currentRow += 2;

      // Sonuç Bölümü
      _addSectionHeader(sheet, 'A$currentRow', 'TEST SONUCU');
      currentRow += 2;

      sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue('SONUÇ:');
      var resultCell = sheet.cell(CellIndex.indexByString('B$currentRow'));
      resultCell.value = TextCellValue(record.sonuc);
      resultCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
      );
      currentRow++;

      sheet.cell(CellIndex.indexByString('A$currentRow')).value = TextCellValue('Hata Bölgesi:');
      sheet.cell(CellIndex.indexByString('B$currentRow')).value = TextCellValue(record.hataBolgesi);

      // Dosyayı kaydet ve paylaş
      await _saveAndShareExcel(excel, 'NDT_Test_${record.testStandard}_${DateFormat('yyyyMMdd_HHmm').format(record.testTarihi)}.xlsx');

    } catch (e) {
      throw Exception('Excel dosyası oluşturulurken hata: $e');
    }
  }

  static Future<void> exportMultipleTestsToExcel(List<NDTRecord> records) async {
    try {
      var excel = Excel.createExcel();
      
      // Default sheet'i sil ve yeni sheet ekle
      excel.delete('Sheet1');
      Sheet sheet = excel['NDT Test Listesi'];

      // Headers
      final headers = [
        'Test Tarihi',
        'Standart',
        'Ekip',
        'Bölge',
        'Conta No',
        'Weld ID',
        'Kaynakçı',
        'Çap (mm)',
        'Kalınlık (mm)',
        'Malzeme',
        'Sonuç',
        'Hata Bölgesi'
      ];

      // Header satırını oluştur
      for (int i = 0; i < headers.length; i++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          fontSize: 11,
        );
      }

      // Veri satırlarını ekle
      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        final rowData = [
          DateFormat('dd.MM.yyyy HH:mm').format(record.testTarihi),
          record.testStandard,
          record.ekip,
          record.bolge,
          record.contaNo,
          record.weldId,
          record.kaynakci1,
          record.boruCap.toString(),
          record.malzemeKalinlik.toString(),
          record.malzemeKalite,
          record.sonuc,
          record.hataBolgesi,
        ];

        for (int j = 0; j < rowData.length; j++) {
          var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1));
          cell.value = TextCellValue(rowData[j]);
          
          // Sonuç sütunu için özel stil
          if (j == 10) { // Sonuç sütunu
            cell.cellStyle = CellStyle(
              bold: record.sonuc != 'OK',
            );
          }
        }
      }

      await _saveAndShareExcel(excel, 'NDT_Test_Listesi_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx');

    } catch (e) {
      throw Exception('Excel dosyası oluşturulurken hata: $e');
    }
  }

  static void _addSectionHeader(Sheet sheet, String cellAddress, String title) {
    var cell = sheet.cell(CellIndex.indexByString(cellAddress));
    cell.value = TextCellValue(title);
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 12,
    );
  }

  static Future<void> _saveAndShareExcel(Excel excel, String fileName) async {
    try {
      // Dosyayı temporary dizine kaydet
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      final bytes = excel.encode();
      
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        
        // SharePlus.instance.shareXFiles kullan
        final result = await Share.shareXFiles(
          [XFile(filePath)],
          text: 'NDT Test Raporu',
          subject: 'NDT Quality Control Raporu',
        );
        
        print('Share result: $result');
      } else {
        throw Exception('Excel dosyası encode edilemedi');
      }
    } catch (e) {
      throw Exception('Dosya kaydetme/paylaşma hatası: $e');
    }
  }
}