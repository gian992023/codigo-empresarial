// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conexion/constants/constants.dart';
import 'package:conexion/firebase_helper/firebase_firestore_helper/firebase_firestore.dart';
import 'package:conexion/firebase_helper/firebase_storage_helper/firebase_storage_helper.dart';
import 'package:conexion/models/product_model/product_model.dart';
import 'package:conexion/models/user_model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:conexion/models/service_model/service_model.dart';
//Clase proveedor de informacion entre firestore y vista app
class AppProvider with ChangeNotifier {
  //CARTA DE CARRITO//
  final List<ProductModel> _cartProductList = [];
  final List<ProductModel> _buyProductList = [];
  final List<ServiceModel> _cartServiceList = [];
  final List<ServiceModel> _buyServiceList = [];
  UserModel? _userModel;

  UserModel get getUserInformation => _userModel!;

  void addCartProduct(ProductModel productModel) {
    _cartProductList.add(productModel);
    notifyListeners();
  }

  void removeCartProduct(ProductModel productModel) {
    _cartProductList.remove(productModel);
    notifyListeners();
  }

  List<ProductModel> get getCartProductList => _cartProductList;
  // Gestión de servicios en el carrito
  void addCartService(ServiceModel serviceModel) {
    _cartServiceList.add(serviceModel);
    notifyListeners();
  }

  void removeCartService(ServiceModel serviceModel) {
    _cartServiceList.remove(serviceModel);
    notifyListeners();
  }

  List<ServiceModel> get getCartServiceList => _cartServiceList;

  //// Favorito////

  final List<ProductModel> _favouriteProductList = [];
  final List<ServiceModel> _favouriteServiceList = [];

  void addFavouriteProduct(ProductModel productModel) {
    _favouriteProductList.add(productModel);
    notifyListeners();
  }

  void removeFavouriteProduct(ProductModel productModel) {
    _favouriteProductList.remove(productModel);
    notifyListeners();
  }

  List<ProductModel> get getFavouriteProductList => _favouriteProductList;

  void addFavouriteService(ServiceModel serviceModel) {
    _favouriteServiceList.add(serviceModel);
    notifyListeners();
  }

  void removeFavouriteService(ServiceModel serviceModel) {
    _favouriteServiceList.remove(serviceModel);
    notifyListeners();
  }

  List<ServiceModel> get getFavouriteServiceList => _favouriteServiceList;


  ////// INFORMACION DE USUARIO /////
  void getUserInfoFirebase() async {
    _userModel = await FirebaseFirestoreHelper.instance.getUserInformation();
    notifyListeners();
  }

  void updateUserInfoFirebase(
      BuildContext context, UserModel userModel, File? file) async {

    if (file == null) {
      showLoaderDialog(context);
      _userModel = userModel;
      await FirebaseFirestore.instance
          .collection("businessusers")
          .doc(userModel!.id)
          .set(userModel!.toJson());
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
    } else {
      showLoaderDialog(context);
      String imageUrl =
          await FirebaseStorageHelper.instance.uploadUserImage(file);
      _userModel = userModel.copyWith(image: imageUrl);
      await FirebaseFirestore.instance
          .collection("businessusers")
          .doc(_userModel!.id)
          .set(_userModel!.toJson());

      Navigator.of(context, rootNavigator: true).pop();

      Navigator.of(context).pop();
    }
    showMessage("Perfil actualizado exitosamente");
    notifyListeners();
  }

////TOTALL////
  double totalPrice() {
    double totalPrice = 0.0;
    for (var element in _cartProductList) {
      totalPrice += element.price * element.qty!;
    }
    return totalPrice;
  }
  double totalPriceBuyProductList() {
    double totalPrice = 0.0;
    for (var element in _buyProductList) {
      totalPrice += element.price * element.qty!;
    }
    return totalPrice;
  }

  void updateQty(ProductModel productModel, int qty) {
    int index = _cartProductList.indexOf(productModel);
    _cartProductList[index].qty = qty;
    notifyListeners();
  }

////Gestion de compraas

  void addBuyProduct(ProductModel model) {
    _buyProductList.add(model);
    notifyListeners();
  }
  void addBuyService(ServiceModel model) {
    _buyServiceList.add(model);
    notifyListeners();
  }

  void addBuyProductCartList() {
    _buyProductList.addAll(_cartProductList);
    notifyListeners();
  }

  void clearCart() {
    _cartProductList.clear();
    notifyListeners();
  }

  void clearBuyProduct() {
    _buyProductList.clear();
    notifyListeners();
  }

  List<ProductModel> get getBuyProductList => _buyProductList;
  List<ServiceModel> get getBuyServiceList => _buyServiceList;
}
