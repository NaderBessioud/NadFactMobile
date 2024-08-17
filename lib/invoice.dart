class Invoice {
  final int idF;
  final int number;
  final double totalttc;
  final DateTime dateemission;
   String status;
  final String type;


  Invoice({
    required this.idF,
    required this.number,
    required this.totalttc,
    required this.dateemission,
    required this.status,
    required this.type,

  });

  factory Invoice.fromJson(Map<String, dynamic> json) {

    return Invoice(
      idF: json['idF'] is String ? int.parse(json['idF']) : json['idF'],
      number: json['number'] is String ? int.parse(json['number']) : json['number'],
      totalttc: json['totalttc'] is String ? double.parse(json['totalttc']) : json['totalttc'],
      dateemission: DateTime.parse(json['dateemission']),
      status: json['status'],
      type: json['type'],

    );
  }
}
