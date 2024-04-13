class UserManager {
  String uid;
  String name;
  String phoneNumber;
  String password;
  String? fcmToken; // Nouveau champ pour le token FCM

  UserManager({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.password,
    this.fcmToken, // Ajout du champ fcmToken avec une valeur par défaut null
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'password': password,
      'fcmToken': fcmToken, // Ajout du champ fcmToken dans la méthode toMap()
    };
  }

  factory UserManager.fromMap(Map<String, dynamic> map) {
    return UserManager(
      uid: map['uid'] ?? '',
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      password: map['password'],
      fcmToken: map[
          'fcmToken'], // Ajout du champ fcmToken dans le constructeur factory
    );
  }
}
