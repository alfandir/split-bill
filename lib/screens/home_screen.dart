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
      appBar: AppBar(
        title: const Text('Split Bill Proporsional'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _FeatureTile(
              title: 'Daftar Teman',
              subtitle: 'Kelola teman',
              icon: Icons.person,
              color: Colors.blue.shade100,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FriendsScreen())),
            ),
            _FeatureTile(
              title: 'Daftar Menu',
              subtitle: 'Kelola menu & harga',
              icon: Icons.restaurant_menu,
              color: Colors.orange.shade100,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MenuScreen())),
            ),
            _FeatureTile(
              title: 'Daftar Biaya Tambahan',
              subtitle: 'Service, Pajak, dll',
              icon: Icons.receipt,
              color: Colors.green.shade100,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FeesScreen())),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SplitScreen())),
                icon: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                ),
                label: const Text(
                  'Mulai Split Bill',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
