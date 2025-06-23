import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

// Clase modelo de información de usuario empresarial
class UserModel {
  UserModel({
    this.image,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  String id;
  String name;
  String email;
  String phone;
  String? image;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "image": image,
  };

  UserModel copyWith({
    String? name,
    String? image,
    String? phone,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        image: image ?? this.image,
      );
}
