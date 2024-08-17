class User{
  int idU;
  final String firstname;
  final String lastname;
  final String libelle;
  final String email;
  final String addresse;



  User({required this.idU, required this.firstname,required this.lastname,required this.libelle,required this.email,required this.addresse});


  factory User.fromJson(Map<String, dynamic> json) {

    if(json['libelle'] != null){
      return User(
        idU: json['idU'],
        firstname: "",
        lastname: "",
        libelle: json['libelle'],
        email: json['email'],
        addresse: json['addresse'],

      );
    }
    else{
      if(json['addresse'] != null){
        return User(
          idU: json['idU'],
          firstname: json['firstname'],
          lastname: json['lastname'],
          libelle: "",
          email: json['email'],
          addresse: json['addresse'],

        );
      }
      else{
        return User(
          idU: json['idU'],
          firstname: json['firstname'],
          lastname: json['lastname'],
          libelle: "",
          email: json['email'],
          addresse: '',

        );
      }

    }



  }

  // Method to convert a User object to a JSON map
  Map<String, dynamic> toJson() {

    return {
      'idU': idU,
      'firstname':firstname,
      'lastname': lastname,
      'libelle':libelle,
      'email': email,
      'addresse': addresse
    };
  }

}