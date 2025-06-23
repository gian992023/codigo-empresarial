import 'dart:convert';

CreateServiceModel serviceModelFromJson(String str) =>
    CreateServiceModel.fromJson(json.decode(str));

String createServiceModelToJson(CreateServiceModel data) => json.encode(data.toJson());

class CreateServiceModel {
  CreateServiceModel({
    required this.image,
    required this.name,
    required this.price,
    required this.description,
    this.available = true,
  });

  String name;
  String image;
  String description;
  double price;
  bool available;

  factory CreateServiceModel.fromJson(Map<String, dynamic> json) =>
      CreateServiceModel(
        name: json["name"],
        image: json["image"],
        description: json["description"],
        price: double.parse(json["price"].toString()),
        available: json["available"] ?? true,
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "image": image,
    "description": description,
    "price": price,
    "available": available,
  };

  CreateServiceModel copyWith({
    bool? available,
  }) =>
      CreateServiceModel(
        image: image,
        name: name,
        price: price,
        description: description,
        available: available ?? this.available,
      );
}
