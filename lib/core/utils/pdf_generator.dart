import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/analysis_result.dart';

class PdfGenerator {
  static Future<void> generateReport(AnalysisResult result) async {
    final pdf = pw.Document();
    
    final fontBold = pw.Font.helveticaBold();
    final fontNormal = pw.Font.helvetica();

    pw.MemoryImage? image;
    try {
      if (await result.file.exists()) {
        final bytes = await result.file.readAsBytes();
        image = pw.MemoryImage(bytes);
      }
    } catch (e) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // --- FULL PAGE WATERMARK ---
              pw.Center(
                child: pw.Opacity(
                  opacity: 0.03,
                  child: pw.Transform.rotate(
                    angle: -0.6,
                    child: pw.Text(
                      'FORGERY DETECTION SYSTEM  ' * 20,
                      style: pw.TextStyle(fontSize: 40, font: fontBold),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ),
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // --- TOP HEADER ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('FORENSIC INTELLIGENCE REPORT', style: pw.TextStyle(fontSize: 20, font: fontBold, color: PdfColors.blueGrey900)),
                          pw.Text('Unit: Digital Evidence Authentication (DEAU #824)', style: pw.TextStyle(fontSize: 9, font: fontNormal, color: PdfColors.grey700)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('ID: ${result.id.toUpperCase()}', style: pw.TextStyle(fontSize: 10, font: fontBold)),
                          pw.Text('DATE: ${result.timestamp.toString().split(' ')[0]}', style: pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 2, color: PdfColors.blueGrey900),
                  pw.SizedBox(height: 15),

                  // --- VERDICT BANNER ---
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: result.isSuspicious ? PdfColors.red : PdfColors.green,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('FINAL VERDICT:', style: pw.TextStyle(fontSize: 8, font: fontBold, color: PdfColors.white)),
                            pw.Text(result.manipulationType.toUpperCase(), 
                              style: pw.TextStyle(fontSize: 14, font: fontBold, color: PdfColors.white)),
                          ],
                        ),
                        pw.Text('${(result.manipulationScore * 100).toStringAsFixed(1)}% CONFIDENCE', 
                          style: pw.TextStyle(fontSize: 12, font: fontBold, color: PdfColors.white)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // --- TWO COLUMN DATA ---
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Image & Basic Info
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (image != null) 
                              pw.Container(
                                height: 180,
                                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                                child: pw.Image(image, fit: pw.BoxFit.contain),
                              ),
                            pw.SizedBox(height: 10),
                            _buildDataSection('FILE FINGERPRINT', fontBold),
                            pw.Text('SHA-256: ${result.fileHash}', style: pw.TextStyle(fontSize: 7, font: fontNormal, fontStyle: pw.FontStyle.italic)),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      // Forensic Metrics
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildDataSection('TECHNICAL SPECS', fontBold),
                            _buildInfoRow('Engine', 'Neural Pro v3.0', fontNormal),
                            _buildInfoRow('Size', '${(result.file.lengthSync() / 1024).toStringAsFixed(2)} KB', fontNormal),
                            _buildInfoRow('Type', result.file.path.split('.').last.toUpperCase(), fontNormal),
                            
                            pw.SizedBox(height: 15),
                            _buildDataSection('ANALYSIS DETAILS', fontBold),
                            pw.Bullet(text: result.metadata['Forensic Detail'] ?? 'No visual anomalies found.', style: pw.TextStyle(fontSize: 8)),
                            if (result.metadata['hasGps'] == true) ...[
                              pw.SizedBox(height: 10),
                              _buildDataSection('GEOLOCATION', fontBold),
                              pw.Text('Lat: ${result.metadata['lat']}', style: const pw.TextStyle(fontSize: 8)),
                              pw.Text('Lng: ${result.metadata['lng']}', style: const pw.TextStyle(fontSize: 8)),
                              pw.Text('Map: https://maps.google.com/?q=${result.metadata['lat']},${result.metadata['lng']}', 
                                style: const pw.TextStyle(fontSize: 7, color: PdfColors.blue700)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 20),
                  _buildDataSection('EXTRACTED METADATA LOGS', fontBold),
                  pw.SizedBox(height: 5),
                  pw.GridView(
                    crossAxisCount: 2,
                    childAspectRatio: 0.15,
                    children: result.metadata.entries
                        .where((e) => e.value is String && e.key.length < 20)
                        .take(10)
                        .map((e) => pw.Padding(
                          padding: const pw.EdgeInsets.only(right: 10),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(e.key.toUpperCase(), style: pw.TextStyle(fontSize: 7, font: fontBold, color: PdfColors.blueGrey700)),
                              pw.Text(e.value.toString().length > 20 ? '${e.value.toString().substring(0, 17)}...' : e.value.toString(), 
                                style: pw.TextStyle(fontSize: 7, font: fontNormal)),
                            ],
                          ),
                        )).toList(),
                  ),

                  pw.Spacer(),
                  pw.Divider(thickness: 0.5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('CONFIDENTIAL DOCUMENT - FOR AUTHORIZED USE ONLY', style: pw.TextStyle(fontSize: 7, font: fontBold)),
                          pw.SizedBox(height: 2),
                          pw.Text('This report is generated by an automated forensic system. Results should be verified by a human expert.', 
                            style: pw.TextStyle(fontSize: 6, font: fontNormal, color: PdfColors.grey600)),
                        ],
                      ),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'Forensic System Verification: ${result.fileHash}',
                        width: 35, height: 35,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Forensic_Report_${result.id}.pdf',
    );
  }

  static pw.Widget _buildDataSection(String title, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 9, font: font, color: PdfColors.blueGrey800)),
        pw.SizedBox(height: 2),
        pw.Container(height: 1, width: 40, color: PdfColors.blueGrey200),
        pw.SizedBox(height: 5),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.Text('$label: ', style: pw.TextStyle(fontSize: 8, font: font, color: PdfColors.grey600)),
          pw.Text(value, style: pw.TextStyle(fontSize: 8, font: font)),
        ],
      ),
    );
  }
}
