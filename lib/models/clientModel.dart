
class Client{
  int idU;
  final String libelle;

  final String email;
  final String addresse;



  Client({required this.idU, required this.libelle,required this.email,required this.addresse});


  factory Client.fromJson(Map<String, dynamic> json) {


    return Client(
      idU: json['idU'],
      libelle: json['libelle'],

      email: json['email'],
      addresse: json['addresse'],

    );


  }

  // Method to convert a User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'idU': idU,
      'libelle':libelle,
      'email': email,
      'addresse': addresse
    };
  }

}