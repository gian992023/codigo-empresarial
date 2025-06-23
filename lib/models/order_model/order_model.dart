import 'dart:convert';
import 'package:conexion/models/product_model/product_model.dart';
import 'package:conexion/models/service_model/service_model.dart';

class RequestModel {
  RequestModel({
    required this.totalPrice,
    required this.idventa,
    required this.products,
    required this.services,
    required this.status,
  });

  String idventa;
  String status;
  List<ProductModel> products;
  List<ServiceModel> services;
  double totalPrice;

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> productMap = json["products"] ?? [];
    List<dynamic> serviceMap = json["services"] ?? [];

    return RequestModel(
      // Si es nulo, asignamos un string vacío
      idventa: json["idventa"] ?? '',
      // Si es nulo, asignamos 0.0 y luego convertimos a double
      totalPrice: (json["totalPrice"] ?? 0).toDouble(),
      products: productMap.map((e) => ProductModel.fromJson(e)).toList(),
      services: serviceMap.map((e) => ServiceModel.fromJson(e)).toList(),
      // Si es nulo, asignamos un string vacío
      status: json["status"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "idventa": idventa,
    "totalPrice": totalPrice,
    "products": products.map((e) => e.toJson()).toList(),
    "services": services.map((e) => e.toJson()).toList(),
    "status": status,
  };
}
