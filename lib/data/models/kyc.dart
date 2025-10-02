class KycSubmission {
  final String id;
  final String legalName;
  final DateTime birthDate;
  final String address;
  final String documentType;
  final String status;
  final DateTime submittedAt;

  KycSubmission({
    required this.id,
    required this.legalName,
    required this.birthDate,
    required this.address,
    required this.documentType,
    required this.status,
    required this.submittedAt,
  });

  factory KycSubmission.fromJson(Map<String, dynamic> json) {
    return KycSubmission(
      id: json['id'],
      legalName: json['legalName'],
      birthDate: DateTime.parse(json['birthDate']),
      address: json['address'],
      documentType: json['documentType'],
      status: json['status'],
      submittedAt: DateTime.parse(json['submittedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'legalName': legalName,
    'birthDate': birthDate.toIso8601String(),
    'address': address,
    'documentType': documentType,
  };
}
