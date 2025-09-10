class MenuItem {
  String id;
  String name;
  double price;
  MenuItem({required this.id, required this.name, required this.price});

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
    id: j['id'],
    name: j['name'],
    price: (j['price'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
}
