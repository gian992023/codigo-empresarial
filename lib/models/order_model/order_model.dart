import 'dart:convert';
import 'package:conexion/models/product_model/product_model.dart';

class RequestModel {
  RequestModel({
    required this.totalPrice,
    required this.idventa,
    required this.products,
    required this.status,
  });

  String idventa;
  String status;
  List<ProductModel> products;
  double totalPrice;

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> productMap = json["products"];
    return RequestModel(
      idventa: json["idventa"],
      totalPrice: json["totalPrice"],
      products: productMap.map((e) => ProductModel.fromJson(e)).toList(),
      status: json["status"],
    );
  }
}
