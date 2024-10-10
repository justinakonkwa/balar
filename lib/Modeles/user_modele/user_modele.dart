class UserManager {
  String uid;
  String phoneNumber;
  String password;
  String? fcmToken; // Champ pour le token FCM (optionnel)
  String? name; // Champ pour le nom (optionnel)
  String? photo; // Champ pour la photo (optionnel)

  // Constructeur avec les champs obligatoires et optionnels
  UserManager({
    required this.uid,
    required this.phoneNumber,
    required this.password,
    this.fcmToken, // Token FCM optionnel
    this.name, // Nom optionnel
    this.photo, // Photo optionnelle
  });

  // Conversion de l'objet UserManager en Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'password': password,
      'fcmToken': fcmToken, // Ajout du fcmToken dans le Map, même s'il est null
      'name': name, // Ajout du nom dans le Map, même s'il est null
      'photo': photo, // Ajout de la photo dans le Map, même si elle est null
    };
  }

  // Construction d'un UserManager à partir d'une Map
  factory UserManager.fromMap(Map<String, dynamic> map) {
    return UserManager(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      password: map['password'] ?? '',
      fcmToken: map['fcmToken'], // Peut être null si non fourni dans la Map
      name: map['name'], // Peut être null si non fourni dans la Map
      photo: map['photo'], // Peut être null si non fourni dans la Map
    );
  }
}
