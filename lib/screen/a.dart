// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFView extends StatelessWidget {
  const PDFView({Key? key, required this.info,required this.name}) : super(key: key);

  final Map info;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PdfPreview(
        build: (format) => _createPdf(
          format,
        ),
      ),
    );
  }

  Future<Uint8List> _createPdf(
    PdfPageFormat format,
  ) async {
    final fontData =
        await rootBundle.load('assets/fonts/ShipporiMincho-Regular.ttf');
    final font = pw.Font.ttf(fontData);

    final pdf = pw.Document(
      version: PdfVersion.pdf_1_4,
      compress: true,
    );
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(base: font),
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.portrait,
        ),

        // pageFormat: PdfPageFormat((80 * (72.0 / 25.4)), 600,
        //     marginAll: 5 * (72.0 / 25.4)),
        //pageFormat: format,
        build: (context) {
          return pw.SizedBox(
            width: double.infinity,
            child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
              pw.Text("5月の給与情報",
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 35,
                      fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text("$nameさん",
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 50),
              tableRowBuild('合計出勤時間', 'totalWork'),
              tableRowBuild('合計休憩時間', 'totalBreak'),
              tableRowBuild('まかない合計金額', 'totalMeal'),
              tableRowBuild('時給', 'hourlyWage'),
              tableRowBuild('出勤-休憩 時間', 'zissitsu'),
              tableRowBuild('給料-まかない　(15分単位で切り捨て)', 'salary'),
                  tableRowBuild('給料(15分単位で切り捨て)', 'salary1'),

                ]),
          );
        },
      ),
    );
    return pdf.save();
  }

  tableRowBuild(String title, String key) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 20)),
   pw.Spacer(),
      pw.Text(info[key], style: pw.TextStyle(fontSize: 20)),
    ]);
  }
}
