import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/storage_helper.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dwndafuezsgdepouubpq.supabase.co', // <- ganti
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3bmRhZnVlenNnZGVwb3V1YnBxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1MDQ2NTAsImV4cCI6MjA3MzA4MDY1MH0.bmUiv30eZoZmojhC6edme_EANFNSXLn9LX15dYxTXuE', // <- ganti
  );
  await StorageHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FToastBuilder(),
      title: 'Split Bill Proporsional',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomeScreen(),
    );
  }
}
