import 'dart:convert';

ServiceModel serviceModelFromJson(String str) =>
    ServiceModel.fromJson(json.decode(str));

String serviceModelToJson(ServiceModel data) => json.encode(data.toJson());

class ServiceModel {
  ServiceModel({
    required this.image,
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.available,
    this.isOnPromotion = false, // Nuevo campo
    this.discountedPrice = 0.0, // Nuevo campo
  });

  String id;
  String name;
  String image;
  String description;
  double price;
  bool available; // Indica si el servicio está disponible
  bool isOnPromotion; // Nuevo campo
  double discountedPrice; // Nuevo campo

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    description: json["description"],
    available: json["available"] ?? true,
    price: double.parse(json["price"].toString()),
    isOnPromotion: json["isOnPromotion"] ?? false, // Nuevo campo
    discountedPrice: json["discountedPrice"] ?? 0.0, // Nuevo campo
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "description": description,
    "price": price,
    "available": available,
    "isOnPromotion": isOnPromotion, // Nuevo campo
    "discountedPrice": discountedPrice, // Nuevo campo
  };

  ServiceModel copyWith({
    bool? available,
    bool? isOnPromotion,
    double? discountedPrice,
  }) =>
      ServiceModel(
        image: image,
        id: id,
        name: name,
        price: price,
        description: description,
        available: available ?? this.available,
        isOnPromotion: isOnPromotion ?? this.isOnPromotion, // Nuevo campo
        discountedPrice: discountedPrice ?? this.discountedPrice, // Nuevo campo
      );
}
