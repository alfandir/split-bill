import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> uploadPdfToSupabase(Uint8List bytes, String filename) async {
  try {
    final supabase = Supabase.instance.client;
    final path = 'bills/$filename.pdf';

    await supabase.storage.from('splitbills').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('splitbills').getPublicUrl(path);
  } catch (e) {
    debugPrint("Upload error: $e");
    return null;
  }
}
