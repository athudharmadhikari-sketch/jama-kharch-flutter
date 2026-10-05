class TransactionModel {
  final String id;
  final String regNo;
  final String name;
  final DateTime date;
  final String type;
  final double amount;
  final String status;
  final String transactionType;

  const TransactionModel({
    required this.id,
    required this.regNo,
    required this.name,
    required this.date,
    required this.type,
    required this.amount,
    required this.status,
    required this.transactionType,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory TransactionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionModel(
      id: json['_id']?.toString() ?? '',

      regNo:
          json['regNo']?.toString() ?? '',

      name:
          json['name']?.toString() ?? '',

      date:
          DateTime.tryParse(
                json['date']?.toString() ?? '',
              ) ??
              DateTime.now(),

      type:
          json['type']?.toString() ?? 'Cash',

      amount:
          (json['amount'] as num?)?.toDouble() ??
              0,

      status:
          json['status']?.toString() ??
              'Pending',

      transactionType:
          json['transactionType']
                  ?.toString() ??
              'jama',
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'regNo': regNo,
      'name': name,
      'date': date.toIso8601String(),
      'type': type,
      'amount': amount,
      'status': status,
      'transactionType':
          transactionType,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  TransactionModel copyWith({
    String? id,
    String? regNo,
    String? name,
    DateTime? date,
    String? type,
    double? amount,
    String? status,
    String? transactionType,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      regNo: regNo ?? this.regNo,
      name: name ?? this.name,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      transactionType:
          transactionType ??
              this.transactionType,
    );
  }
}