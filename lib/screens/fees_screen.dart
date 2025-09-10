import 'package:flutter/material.dart';
import '../helpers/storage_helper.dart';
import '../models/extra_fee.dart';
import 'package:uuid/uuid.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});
  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  List<ExtraFee> list = [];
  @override
  void initState() {
    super.initState();
    list = StorageHelper.getFees();
  }

  void _add() async {
    final nameCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    bool isPercent = true;
    await showDialog(context: context, builder: (_) {
      return StatefulBuilder(builder: (c, s) {
        return AlertDialog(
          title: const Text('Tambah Biaya'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: amtCtrl, decoration: const InputDecoration(labelText: 'Jumlah (angka)'), keyboardType: TextInputType.number),
            Row(children: [
              const Text('Persentase?'),
              Checkbox(value: isPercent, onChanged: (v) { s((){ isPercent = v ?? true; }); }),
            ])
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(onPressed: () {
              final id = const Uuid().v4();
              final amt = double.tryParse(amtCtrl.text) ?? 0;
              list.add(ExtraFee(id: id, name: nameCtrl.text, amount: amt, isPercentage: isPercent));
              StorageHelper.saveFees(list);
              setState((){});
              Navigator.pop(context);
            }, child: const Text('Tambah')),
          ],
        );
      });
    });
  }

  void _remove(String id) {
    list.removeWhere((e) => e.id == id);
    StorageHelper.saveFees(list);
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Biaya Tambahan')),
      body: ListView(
        children: list.map((f) => Card(
          child: ListTile(
            title: Text(f.name),
            subtitle: Text('${f.isPercentage ? f.amount.toStringAsFixed(0) + '%' : 'Rp ' + f.amount.toStringAsFixed(0)}'),
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
