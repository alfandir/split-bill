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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Split Bill Proporsional"),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
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
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: menu.length,
                  itemBuilder: (context, i) {
                    final m = menu[i];
                    return InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) {
                            return ListView(
                              padding: const EdgeInsets.all(8),
                              children: friends
                                  .map((f) => Card(
                                        child: ListTile(
                                          leading: const Icon(Icons.person),
                                          title: Text(f.name),
                                          onTap: () {
                                            final map = selections[f.id]!;
                                            map[m.id] = (map[m.id] ?? 0) + 1;
                                            setState(() {});
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ))
                                  .toList(),
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.indigo.shade50,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(m.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 6),
                            Text("Rp ${m.price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Section: Ringkasan
            if ((rows as List).any((r) => (r['order'] as double) > 0)) ...[
              Text("Ringkasan Per Orang",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...rows.where((r) => (r['order'] as double) > 0).map((r) {
                final items = selections[r['id']] as Map<String, int>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Nama + Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            r['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Rp ${(r['total'] as double).toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// Rincian Pesanan
                      ...items.keys.map((mId) {
                        final m = menu.firstWhere(
                          (e) => e.id == mId,
                          orElse: () => MenuItem(id: '', name: '', price: 0),
                        );
                        final qty = items[mId]!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${m.name} x$qty",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.red, size: 20),
                                  onPressed: () => _changeQty(r['id'], mId, -1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.green, size: 20),
                                  onPressed: () => _changeQty(r['id'], mId, 1),
                                ),
                              ],
                            ),
                            Text(
                              "Rp ${(m.price * qty).toStringAsFixed(0)}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 8),

                      /// Extra biaya
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Biaya tambahan",
                              style: TextStyle(fontSize: 13)),
                          Text(
                            "Rp ${(r['extra'] as double).toStringAsFixed(0)}",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              /// Ringkasan total
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _summaryRow("Subtotal", res['subtotal']),
                    _summaryRow("Biaya Tambahan", res['extra']),
                    const Divider(),
                    _summaryRow("Grand Total", res['grand'], isBold: true),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            /// Button Export
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  backgroundColor: Colors.indigo,
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

  Widget _summaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
          Text(
            "Rp ${value.toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
              color: isBold ? Colors.indigo : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
