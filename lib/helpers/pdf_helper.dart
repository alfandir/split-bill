import 'dart:html' as html; // for web download
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

Future<Uint8List> _buildStyledPdfBytes({
  required String storeName,
  required String title,
  required double subtotal,
  required double extra,
  required double total,
  required List<Map<String, dynamic>> results,
}) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      build: (context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(storeName,
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text("Tanggal: ${DateTime.now()}",
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Title + Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(title,
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Rp ${total.toStringAsFixed(0)}",
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(),

              // Items
              pw.Column(
                children: results.map((e) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(e['name'],
                              style: const pw.TextStyle(fontSize: 12)),
                        ),
                        pw.Text(
                          "Rp ${(e['total'] as double).toStringAsFixed(0)}",
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              pw.Divider(),

              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Subtotal"),
                  pw.Text("Rp ${subtotal.toStringAsFixed(0)}"),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Biaya tambahan"),
                  pw.Text("Rp ${extra.toStringAsFixed(0)}"),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Grand Total",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text("Rp ${total.toStringAsFixed(0)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),

              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Text("THANK YOU!",
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    ),
  );

  return doc.save();
}

Future<void> generateAndSharePdf({
  required String title,
  required double subtotal,
  required double extra,
  required double total,
  required List<Map<String, dynamic>> results,
  BuildContext? context,
}) async {
  final bytes = await _buildStyledPdfBytes(
      title: title,
      subtotal: subtotal,
      extra: extra,
      total: total,
      results: results,
      storeName: "-");

  if (kIsWeb) {
    // trigger browser download
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement;
    anchor.href = url;
    anchor.download = 'split_bill.pdf';
    anchor.style.display = 'none';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  } else {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/split_bill.pdf');
    await file.writeAsBytes(bytes);
    // share
    await Share.shareXFiles([XFile(file.path)], text: title);
  }
}
