import 'dart:convert';

CreateProductModel userModelFromJson(String str) =>
    CreateProductModel.fromJson(json.decode(str));

String CreateProductModelToJson(CreateProductModel data) => json.encode(data.toJson());

class CreateProductModel {
  CreateProductModel({required this.image,

    required this.name,
    required this.price,
    required this.description,


    this.qty});


  String name;
  String image;
  String description;


  double price;
  int? qty;

  factory CreateProductModel.fromJson(Map<String, dynamic> json) =>
      CreateProductModel(

        name: json["name"],
        image: json["image"],
        description: json["description"],




        qty: json["qty"],
        price: double.parse(json["price"].toString()),
      );

  Map<String, dynamic> toJson() =>
      {

        "name": name,
        "image": image,
        "description": description,
        "price": price,



        "qty": qty,
      };


  CreateProductModel copyWith({

    int? qty,
  }) =>
      CreateProductModel(image: image,

        name: name,
        price: price,
        description: description,


        qty: qty??this.qty,

      );
}
