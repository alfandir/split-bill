class Friend {
  String id;
  String name;
  Friend({required this.id, required this.name});

  factory Friend.fromJson(Map<String, dynamic> j) => Friend(
    id: j['id'],
    name: j['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
