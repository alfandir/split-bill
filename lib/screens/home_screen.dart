import 'package:flutter/material.dart';
import 'friends_screen.dart';
import 'menu_screen.dart';
import 'fees_screen.dart';
import 'split_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split Bill Proporsional')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _Tile(title: 'Daftar Teman', subtitle: 'Kelola teman', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen()))),
            _Tile(title: 'Daftar Menu', subtitle: 'Kelola menu & harga', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuScreen()))),
            _Tile(title: 'Daftar Biaya Tambahan', subtitle: 'Service, Pajak, dll', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeesScreen()))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitScreen())),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Mulai Split Bill'),
            )
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _Tile({required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
