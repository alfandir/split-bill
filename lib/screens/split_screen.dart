import 'package:flutter/material.dart';
import '../helpers/storage_helper.dart';
import '../models/friend.dart';
import '../models/menu_item.dart';
import '../models/extra_fee.dart';
import '../helpers/pdf_helper.dart';

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  List<Friend> friends = [];
  List<MenuItem> menu = [];
  List<ExtraFee> fees = [];

  Map<String, Map<String, int>> selections = {};
  final TextEditingController storeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    friends = StorageHelper.getFriends();
    menu = StorageHelper.getMenu();
    fees = StorageHelper.getFees();
    for (var f in friends) selections[f.id] = {};
  }

  double _calcSubtotal() {
    double s = 0;
    for (var fId in selections.keys) {
      final items = selections[fId]!;
      for (var mId in items.keys) {
        final qty = items[mId]!;
        final m = menu.firstWhere((e) => e.id == mId);
        s += m.price * qty;
      }
    }
    return s;
  }

  Map<String, dynamic> _computeResults() {
    final subtotal = _calcSubtotal();
    double extraTotal = 0;
    for (var fe in fees) {
      if (fe.isPercentage) {
        extraTotal += subtotal * fe.amount / 100.0;
      } else {
        extraTotal += fe.amount;
      }
    }
    final grand = subtotal + extraTotal;

    List<Map<String, dynamic>> rows = [];
    for (var f in friends) {
      final itemsMap = selections[f.id] ?? {};
      double order = 0;

      List<Map<String, dynamic>> items = itemsMap.entries.map((e) {
        final m = menu.firstWhere((mm) => mm.id == e.key,
            orElse: () => MenuItem(id: '', name: '', price: 0));
        final totalItem = m.price * e.value;
        order += totalItem;
        return {
          'name': m.name,
          'qty': e.value,
          'price': m.price,
          'total': totalItem,
        };
      }).toList();

      double proportionalExtra = 0;
      if (subtotal > 0) proportionalExtra = extraTotal * (order / subtotal);
      final total = order + proportionalExtra;

      rows.add({
        'id': f.id,
        'name': f.name,
        'order': order,
        'extra': proportionalExtra,
        'total': total,
        'items': items,
      });
    }

    return {
      'subtotal': subtotal,
      'extra': extraTotal,
      'grand': grand,
      'rows': rows,
    };
  }

  void _changeQty(String friendId, String menuId, int delta) {
    final map = selections[friendId]!;
    map[menuId] = (map[menuId] ?? 0) + delta;
    if (map[menuId]! <= 0) map.remove(menuId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final res = _computeResults();
    final rows = res['rows'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Split Bill Proporsional"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Input Store Name
            TextField(
              controller: storeController,
              decoration: InputDecoration(
                labelText: "Nama Toko / Resto",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.storefront),
              ),
            ),

            const SizedBox(height: 20),

            /// Section: Menu
            Text("Pilih Menu",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: menu.length,
                  itemBuilder: (context, i) {
                    final m = menu[i];
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return ListView(
                              children: friends
                                  .map((f) => ListTile(
                                        leading: const Icon(Icons.person),
                                        title: Text(f.name),
                                        onTap: () {
                                          final map = selections[f.id]!;
                                          map[m.id] = (map[m.id] ?? 0) + 1;
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                      ))
                                  .toList(),
                            );
                          },
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(m.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14)),
                          const SizedBox(height: 6),
                          Text("Rp ${m.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Section: Ringkasan
            Text("Ringkasan Per Orang",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ...rows.map((r) {
                    final items = selections[r['id']] as Map<String, int>;
                    return ExpansionTile(
                      leading: const Icon(Icons.person),
                      title: Text(r['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      subtitle: Text(
                          "Pesanan: Rp ${(r['order'] as double).toStringAsFixed(0)}\n"
                          "Tambahan: Rp ${(r['extra'] as double).toStringAsFixed(0)}"),
                      trailing: Text(
                        "Rp ${(r['total'] as double).toStringAsFixed(0)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      children: [
                        ...items.keys.map((mId) {
                          final m = menu.firstWhere((e) => e.id == mId,
                              orElse: () =>
                                  MenuItem(id: '', name: '', price: 0));
                          final qty = items[mId]!;
                          return ListTile(
                            dense: true,
                            title: Text('${m.name} x$qty'),
                            subtitle: Text(
                                'Rp ${(m.price * qty).toStringAsFixed(0)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      _changeQty(r['id'], mId, -1);
                                    }),
                                IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      _changeQty(r['id'], mId, 1);
                                    }),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                  const Divider(),
                  ListTile(
                    title: const Text("Subtotal"),
                    trailing: Text(
                      "Rp ${res['subtotal'].toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: const Text("Biaya Tambahan"),
                    trailing: Text(
                      "Rp ${res['extra'].toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: const Text("Total"),
                    trailing: Text(
                      "Rp ${res['grand'].toStringAsFixed(0)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Button Export
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF & Bagikan'),
                onPressed: () {
                  if (storeController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Isi nama toko dulu")),
                    );
                    return;
                  }

                  generateAndSharePdf(
                    storeName: storeController.text.trim(),
                    title: 'Split Bill',
                    subtotal: res['subtotal'],
                    extra: res['extra'],
                    total: res['grand'],
                    results: List<Map<String, dynamic>>.from(rows),
                    context: context,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
