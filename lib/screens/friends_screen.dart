import 'package:flutter/material.dart';
import '../helpers/storage_helper.dart';
import '../models/friend.dart';
import 'package:uuid/uuid.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Friend> list = [];
  @override
  void initState() {
    super.initState();
    list = StorageHelper.getFriends();
  }

  void _add() async {
    final nameCtrl = TextEditingController();
    await showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text('Tambah Teman'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: () {
            final id = const Uuid().v4();
            list.add(Friend(id: id, name: nameCtrl.text));
            StorageHelper.saveFriends(list);
            setState((){});
            Navigator.pop(context);
          }, child: const Text('Tambah')),
        ],
      );
    });
  }

  void _remove(String id) {
    list.removeWhere((e) => e.id == id);
    StorageHelper.saveFriends(list);
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Teman')),
      body: ListView(
        children: list.map((f) => Card(
          child: ListTile(
            title: Text(f.name),
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _remove(f.id)),
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
