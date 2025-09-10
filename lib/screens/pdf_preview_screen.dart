import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Future<Uint8List> Function() buildPdf;
  final String title;

  const PdfPreviewScreen({
    super.key,
    required this.buildPdf,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (format) => buildPdf(),
        canChangePageFormat: false,
        allowPrinting: false, // biar user cuma lihat
        allowSharing: false,
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.download),
            onPressed: (context, build, format) async {
              final pdf = await build(format);
              await Printing.sharePdf(bytes: pdf, filename: 'split_bill.pdf');
            },
          ),
        ],
      ),
    );
  }
}
