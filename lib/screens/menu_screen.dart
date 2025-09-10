import 'package:flutter/material.dart';
import '../helpers/storage_helper.dart';
import '../models/menu_item.dart';
import 'package:uuid/uuid.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> list = [];
  @override
  void initState() {
    super.initState();
    list = StorageHelper.getMenu();
  }

  void _add() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    await showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text('Tambah Menu'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
          TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: () {
            final id = const Uuid().v4();
            final price = double.tryParse(priceCtrl.text) ?? 0;
            list.add(MenuItem(id: id, name: nameCtrl.text, price: price));
            StorageHelper.saveMenu(list);
            setState((){});
            Navigator.pop(context);
          }, child: const Text('Tambah')),
        ],
      );
    });
  }

  void _remove(String id) {
    list.removeWhere((e) => e.id == id);
    StorageHelper.saveMenu(list);
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Menu')),
      body: ListView(
        children: list.map((m) => Card(
          child: ListTile(
            title: Text(m.name),
            subtitle: Text('Rp ${m.price.toStringAsFixed(0)}'),
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _remove(m.id)),
          ),
        )).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}
