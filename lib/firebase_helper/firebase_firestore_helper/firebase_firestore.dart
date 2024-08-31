// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conexion/constants/constants.dart';
import 'package:conexion/models/order_model/order_model.dart';
import 'package:conexion/models/product_model/product_model.dart';
import 'package:conexion/models/category_model/category_model.dart';
import 'package:conexion/models/user_model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import '../../models/create_product_model/create_producto_model.dart';

class FirebaseFirestoreHelper {
  static FirebaseFirestoreHelper instance = FirebaseFirestoreHelper();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;


  //Funcion obtener categorias de productos
  Future<List<CategoryModel>> getCategories() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection("userProducts")
          .doc(userId)
          .collection("categories")
          .get();
      List<CategoryModel> categoriesList = querySnapshot.docs
          .map((e) => CategoryModel.fromJson(e.data()))
          .toList();
      return categoriesList;
    } catch (e) {
      showMessage(e.toString());
      return [];
    }
  }
  Future<CategoryModel?> getCategory(String categoryId) async {
    try {

      DocumentSnapshot<Map<String, dynamic>> categorySnapshot =
      await FirebaseFirestore.instance.collection("categories").doc(categoryId).get();
      if (categorySnapshot.exists) {
        return CategoryModel.fromJson(categorySnapshot.data()!);
      } else {
        return null;
      }
    } catch (e) {
      showMessage(e.toString());
      return null;
    }
  }


//Funcion Creacion producto
  Future<bool> createProductFirebase(CreateProductModel product,  BuildContext context, String categoryId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      showLoaderDialog(context);

      // Obtener la referencia de la categoría
      CategoryModel? category = await getCategory(categoryId);

      if (category != null) {
        // Obtener la referencia de la colección "categories" dentro de "userProducts" para el usuario actual
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection("userProducts")
            .doc(userId)
            .collection("categories")
            .doc(categoryId);

        documentReference.set({
          "id": category.id,
          "image": category.image,
          "name": category.name,
        });
        CollectionReference productsCollection = documentReference.collection("products");

        DocumentReference productDocRef = await documentReference.collection("products").add({

          "image": product.image,
          "id": "",
          "name": product.name,
          "price": product.price,
          "description": product.description,
          "qty": product.qty,
        });
        // Obtener el ID generado automáticamente por Firestore
        String productId = productDocRef.id;

        // Actualizar el valor del campo "id" con el ID generado automáticamente
        await productDocRef.update({"id": productId});



        print("Producto creado en la categoría ${category.name} para el usuario $userId");

        return true;
      } else {
        print("La categoría no existe: $categoryId");
        return false;
      }
    } catch (e) {
      print("Error creating product: $e");
      return false;
    }
  }

//Funcion obtencion de productos favoritos
  Future<List<ProductModel>> getBestProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firebaseFirestore.collectionGroup("products").get();
      List<ProductModel> productModelList = querySnapshot.docs
          .map((e) => ProductModel.fromJson(e.data()))
          .toList();
      return productModelList;
    } catch (e) {
      showMessage(e.toString());
      return [];
    }
  }
//Funcion obtencion productos de usuario empresarial
  Future<List<ProductModel>> getUserProducts() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection("userProducts")
          .doc(userId)
          .collection("categories")
          .get();
      List<ProductModel> userProductsList = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
        QuerySnapshot<Map<String, dynamic>> productsSnapshot =
        await doc.reference.collection("products").get();
        List<ProductModel> products = productsSnapshot.docs
            .map((e) => ProductModel.fromJson(e.data()))
            .toList();
        userProductsList.addAll(products);
      }

      return userProductsList;
    } catch (e) {
      showMessage(e.toString());
      return [];
    }
  }


//funcion Obtener informacion de categorias y sus productos
  Future<List<ProductModel>> getCategoryViewProduct(String categoryId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firebaseFirestore
          .collection("userProducts")
          .doc(userId)
          .collection("categories")
          .doc(categoryId)
          .collection("products")
          .get();
      List<ProductModel> productModelList = querySnapshot.docs
          .map((e) => ProductModel.fromJson(e.data()))
          .toList();
      return productModelList;
    } catch (e) {
      showMessage(e.toString());
      return [];
    }
  }


//funcion obtener informacion del usuario empresarial
  Future<UserModel> getUserInformation() async {
    DocumentSnapshot<Map<String, dynamic>> querySnapshot =
    await _firebaseFirestore
        .collection("businessusers")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    return UserModel.fromJson(querySnapshot.data()!);
  }

// funcion subir orden de usuarios
  Future<bool> uploadOrderedProductFirebase(List<ProductModel> list,
      BuildContext context, String payment) async {
    try {
      showLoaderDialog(context);
      double totalPrice = 0.0;
      for (var element in list) {
        totalPrice += element.price * element.qty!;
      }
      DocumentReference documentReference = _firebaseFirestore
          .collection("userOrders")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("orders")
          .doc();
      DocumentReference admin = _firebaseFirestore.collection("orders").doc();

      admin.set({
        "products": list.map((e) => e.toJson()),
        "status": "Pending",
        "totalPrice": totalPrice,
        "payment": payment,
        "orderId": admin.id,
      });

      documentReference.set({
        "products": list.map((e) => e.toJson()),
        "status": "Pending",
        "totalPrice": totalPrice,
        "payment": payment,
        "orderId": documentReference.id,
      });
      Navigator.of(context, rootNavigator: true).pop();
      showMessage("Orden exitosa");
      return true;
    } catch (e) {
      showMessage(e.toString());
      Navigator.of(context, rootNavigator: true).pop();
      return false;
    }
  }

  //funcion obtener orden usuario
  Future<List<RequestModel>> getUserOrder() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print("User ID is null");
        return [];
      }

      List<RequestModel> orderList = [];

      print("User ID: $userId");

      // Obtener el documento específico de la colección "ventas"
      DocumentSnapshot<Map<String, dynamic>> ventasDoc;
      try {
        ventasDoc = await _firebaseFirestore
            .collection("ventas")
            .doc(userId)
            .get();
      } catch (e) {
        print("Error fetching ventasDoc: $e");
        return [];
      }

      print("Ventas doc snapshot: ${ventasDoc.data()}");

      if (ventasDoc.exists) {
        print("Ventas doc existe");

        // Obtener las subcolecciones de clientes
        QuerySnapshot<Map<String, dynamic>> clientSnapshot;
        try {
          clientSnapshot = await ventasDoc.reference
              .collection("zRkPQZUV4ma5aubw5K0ovDBkWNI3")
              .get();
        } catch (e) {
          print("Error fetching clientSnapshot: $e");
          return [];
        }

        for (var clientDoc in clientSnapshot.docs) {
          print("Cliente doc ID: ${clientDoc.id}");

          // Obtener el documento específico del pedido
          DocumentSnapshot<Map<String, dynamic>> orderDoc;
          try {
            orderDoc = await clientDoc.reference
                .collection("zRkPQZUV4ma5aubw5K0ovDBkWNI3") // Navegar a la subcolección
                .doc("9NxNbRQzFP3fI2IM1TMW") // Especificar el documento
                .get();
          } catch (e) {
            print("Error fetching orderDoc: $e");
            continue;
          }

          if (orderDoc.exists) {
            print("Pedido encontrado: ${orderDoc.id}");
            orderList.add(RequestModel.fromJson(orderDoc.data()!));
          } else {
            print("Pedido no encontrado: 9NxNbRQzFP3fI2IM1TMW");
          }
        }
      } else {
        print("Ventas doc no existe");
      }

      return orderList;
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }



//funcion actualizar token de usuario empresarial
  void updateTokenFromFirebase() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _firebaseFirestore
          .collection("businessusers")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        "notificationToken": token,
      });
    }
  }
// Función para actualizar un producto en Firestore
  Future<void> updateProduct(
      String productId,
      String name,
      String description,
      int qty,
      double price,
      ) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection("userProducts")
          .doc(userId)
          .collection("categories")
          .get();

      bool productFound = false;
      String? categorieId;

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        String currentCategorieId = documentSnapshot.id;
        QuerySnapshot productsQuerySnapshot = await _firebaseFirestore
            .collection("userProducts")
            .doc(userId)
            .collection("categories")
            .doc(currentCategorieId)
            .collection("products")
            .where('id', isEqualTo: productId)
            .get();

        if (productsQuerySnapshot.docs.isNotEmpty) {
          productFound = true;
          categorieId = currentCategorieId;
          break;
        }
      }

      if (productFound) {
        await _firebaseFirestore
            .collection("userProducts")
            .doc(userId)
            .collection("categories")
            .doc(categorieId)
            .collection("products")
            .doc(productId)
            .update({
          'name': name,
          'description': description,
          'qty': qty,
          'price': price,
        });
      } else {
        print('No se encontró el producto con el id: $productId');
        throw Exception('No se encontró el producto con el id: $productId');
      }
    } catch (e) {
      // Manejar errores
      print('Error al actualizar el producto: $e');
      throw e; // Puedes manejar el error de otra manera si lo deseas
    }
  }

  // Función para eliminar un producto de Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection("userProducts")
          .doc(userId)
          .collection("categories")
          .get();

      bool productFound = false;
      String? categorieId;

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        String tempCategorieId = documentSnapshot.id;
        QuerySnapshot productsQuerySnapshot = await _firebaseFirestore
            .collection("userProducts")
            .doc(userId)
            .collection("categories")
            .doc(tempCategorieId)
            .collection("products")
            .where('id', isEqualTo: productId)
            .get();

        if (productsQuerySnapshot.docs.isNotEmpty) {
          productFound = true;
          categorieId = tempCategorieId;
          break;
        }
      }

      if (productFound) {
        await _firebaseFirestore
            .collection("userProducts")
            .doc(userId)
            .collection("categories")
            .doc(categorieId!)
            .collection('products')
            .doc(productId)
            .delete();
      } else {
        print('No se encontró el producto con el id: $productId');
        throw Exception('No se encontró el producto con el id: $productId');
      }
    } catch (e) {
      // Manejar errores
      print('Error al eliminar el producto: $e');
      throw e; // Puedes manejar el error de otra manera si lo deseas
    }
  }
}
