class ExtraFee {
  String id;
  String name;
  double amount;
  bool isPercentage; // if true, amount is percentage (e.g., tax 10%)
  ExtraFee({required this.id, required this.name, required this.amount, this.isPercentage = false});

  factory ExtraFee.fromJson(Map<String, dynamic> j) => ExtraFee(
    id: j['id'],
    name: j['name'],
    amount: (j['amount'] as num).toDouble(),
    isPercentage: j['isPercentage'] ?? false,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'amount': amount, 'isPercentage': isPercentage};
}
