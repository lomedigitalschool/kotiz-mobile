class Transaction {
  final String id;
  final String title;
  final String type;
  final int amount;
  final String currency;
  final DateTime dateTime;
  final String paymentMethod;
  final String status;
  final String reference;

  Transaction({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.currency,
    required this.dateTime,
    required this.paymentMethod,
    required this.status,
    required this.reference,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      amount: json['amount'],
      currency: json['currency'] ?? 'Fr CFA',
      dateTime: DateTime.parse(json['dateTime']),
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      reference: json['reference'],
    );
  }
}
