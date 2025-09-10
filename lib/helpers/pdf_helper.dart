import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:split_bill_app/helpers/supabase_helper.dart';

// Formatter Rupiah
final _currencyFormatter = NumberFormat("#,##0", "id_ID");
String formatRupiah(num value) => "Rp ${_currencyFormatter.format(value)}";

Future<Uint8List> _buildStyledPdfBytes({
  required String storeName,
  required String title,
  required double subtotal,
  required double extra,
  required double total,
  required List<Map<String, dynamic>> results,
}) async {
  final doc = pw.Document();

  final regular = await PdfGoogleFonts.robotoMonoRegular();
  final bold = await PdfGoogleFonts.robotoMonoBold();

  doc.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(16),
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.DefaultTextStyle(
          style: pw.TextStyle(font: regular, fontSize: 11),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header toko
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(storeName.toUpperCase(),
                        style: pw.TextStyle(font: bold, fontSize: 18)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "Tanggal: ${DateTime.now().toLocal().toString().split('.')[0]}",
                      style: pw.TextStyle(font: regular, fontSize: 9),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(title,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: bold, fontSize: 14)),
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),

              // Daftar orang
              ...results.map((r) {
                final items = r['items'] as List<Map<String, dynamic>>?;
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 6),
                    pw.Text(r['name'],
                        style: pw.TextStyle(font: bold, fontSize: 12)),
                    if (items != null && items.isNotEmpty)
                      pw.Column(
                        children: items.map((i) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 1),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    "${i['name']} x${i['qty']}",
                                    style: pw.TextStyle(
                                        font: regular, fontSize: 10),
                                  ),
                                ),
                                pw.Text(
                                  formatRupiah(i['price'] * i['qty']),
                                  style:
                                      pw.TextStyle(font: regular, fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    pw.SizedBox(height: 2),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Subtotal:",
                            style: pw.TextStyle(font: bold, fontSize: 10)),
                        pw.Text(formatRupiah(r['order']),
                            style: pw.TextStyle(font: regular, fontSize: 10)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Biaya Tambahan:",
                            style: pw.TextStyle(font: bold, fontSize: 10)),
                        pw.Text(formatRupiah(r['extra']),
                            style: pw.TextStyle(font: regular, fontSize: 10)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Total:",
                            style: pw.TextStyle(font: bold, fontSize: 11)),
                        pw.Text(formatRupiah(r['total']),
                            style: pw.TextStyle(font: bold, fontSize: 11)),
                      ],
                    ),
                    pw.Divider(),
                  ],
                );
              }).toList(),

              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),

              // Ringkasan akhir
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Subtotal", style: pw.TextStyle(font: bold)),
                  pw.Text(formatRupiah(subtotal),
                      style: pw.TextStyle(font: regular)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Biaya Tambahan", style: pw.TextStyle(font: bold)),
                  pw.Text(formatRupiah(extra),
                      style: pw.TextStyle(font: regular)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("GRAND TOTAL",
                      style: pw.TextStyle(font: bold, fontSize: 13)),
                  pw.Text(formatRupiah(total),
                      style: pw.TextStyle(font: bold, fontSize: 13)),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text("*** TERIMA KASIH ***",
                    style: pw.TextStyle(font: bold, fontSize: 12)),
              ),
            ],
          ),
        );
      },
    ),
  );

  return doc.save();
}

// Fungsi generate & share link
Future<String?> generateAndSharePdf({
  required String title,
  required double subtotal,
  required double extra,
  required double total,
  required List<Map<String, dynamic>> results,
  BuildContext? context,
  String storeName = "-",
}) async {
  final bytes = await _buildStyledPdfBytes(
    title: title,
    subtotal: subtotal,
    extra: extra,
    total: total,
    results: results,
    storeName: storeName,
  );

  final filename =
      "SplitBill_${storeName}_${DateTime.now().toLocal().toIso8601String()}";
  final url = await uploadPdfToSupabase(bytes, filename);

  if (url != null) {
    return url;
  } else {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal upload ke Supabase")),
      );
    }
    return null;
  }
}
