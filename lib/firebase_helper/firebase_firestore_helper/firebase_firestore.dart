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
import '../../models/create_service_model/create_service_model.dart';
import '../../models/service_model/service_model.dart';

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
  Future<bool> createProductFirebase(
      CreateProductModel product,
      BuildContext context,
      String categoryId) async {
    try {
      // 1) Obtener el UID del usuario autenticado (businessUser)
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // 2) Recuperar el "name" desde businessusers/{userId}
      final bizSnap = await FirebaseFirestore.instance
          .collection("businessusers")
          .doc(userId)
          .get();

      String businessName = "Negocio Desconocido";
      if (bizSnap.exists) {
        final data = bizSnap.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey("name")) {
          businessName = data["name"] as String;
        }
      }

      // 3) Asegurarnos de que el documento userProducts/{userId} contenga el campo "name"
      //    Con merge: true no borramos otros posibles campos, solo añadimos/actualizamos "name".
      final parentUserProductsRef =
      FirebaseFirestore.instance.collection("userProducts").doc(userId);

      await parentUserProductsRef.set(
        {
          "name": businessName,
        },
        SetOptions(merge: true),
      );

      // 4) Recuperar la categoría en la que vamos a insertar el producto
      CategoryModel? category = await getCategory(categoryId);

      if (category != null) {
        // 5) Crear (o actualizar) el documento de categoría en:
        //    userProducts/{userId}/categories/{categoryId}
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection("userProducts")
            .doc(userId)
            .collection("categories")
            .doc(categoryId);

        // Guardamos la información básica de la categoría (id, name, image)
        await documentReference.set({
          "id": category.id,
          "image": category.image,
          "name": category.name,
        });

        // 6) Ahora agregamos el producto dentro de la subcolección "products"
        CollectionReference productsCollection = documentReference.collection("products");

        DocumentReference productDocRef = await productsCollection.add({
          "image": product.image,
          "id": "", // Luego actualizamos con el ID generado
          "name": product.name,
          "price": product.price,
          "description": product.description,
          "qty": product.qty,
        });

        // 7) Obtenemos el ID generado automáticamente y lo dejamos dentro del campo "id"
        String productId = productDocRef.id;
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
  Future<bool> createServiceFirebase(
      CreateServiceModel service,
      BuildContext context,
      String categoryId) async {
    try {
      // 1) UID del usuario empresarial
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // 2) Recuperar el "name" desde businessusers/{userId}
      final bizSnap = await FirebaseFirestore.instance
          .collection("businessusers")
          .doc(userId)
          .get();

      String businessName = "Negocio Desconocido";
      if (bizSnap.exists) {
        final data = bizSnap.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey("name")) {
          businessName = data["name"] as String;
        }
      }

      // 3) Guardar o actualizar userServices/{userId}.name = businessName
      final parentUserServicesRef =
      FirebaseFirestore.instance.collection("userServices").doc(userId);

      await parentUserServicesRef.set(
        {
          "name": businessName,
        },
        SetOptions(merge: true),
      );

      // 4) Obtener la categoría correspondiente
      CategoryModel? category = await getCategory(categoryId);

      if (category != null) {
        // 5) Crear (o actualizar) el documento de la categoría:
        //    userServices/{userId}/categories/{categoryId}
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection("userServices")
            .doc(userId)
            .collection("categories")
            .doc(categoryId);

        // Guardamos la info de la categoría (id, name, image)
        await documentReference.set({
          "id": category.id,
          "image": category.image,
          "name": category.name,
        });

        // 6) Ahora creamos el servicio dentro de subcolección:
        //    userServices/{userId}/categories/{categoryId}/services
        CollectionReference servicesCollection = documentReference.collection("services");

        DocumentReference serviceDocRef = await servicesCollection.add({
          "image": service.image,
          "id": "", // Luego actualizaremos
          "name": service.name,
          "price": service.price,
          "description": service.description,
          "available": service.available ?? false,
        });

        // 7) Obtenemos el ID generado automáticamente y actualizamos el campo "id"
        String serviceId = serviceDocRef.id;
        await serviceDocRef.update({"id": serviceId});

        print("Servicio creado en la categoría ${category.name} "
            "para el usuario $userId con ID: $serviceId");

        return true;
      } else {
        print("La categoría no existe: $categoryId");
        return false;
      }
    } catch (e) {
      print("Error creando servicio: ${e.toString()}");
      return false;
    }
  }
// Función para obtener los mejores servicios
  Future<List<ServiceModel>> getBestServices() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firebaseFirestore.collectionGroup("services").get();
      List<ServiceModel> serviceModelList = querySnapshot.docs
          .map((e) => ServiceModel.fromJson(e.data()))
          .toList();
      return serviceModelList;
    } catch (e) {
      showMessage(e.toString());
      return [];
    }
  }

// Función para obtener los servicios de un usuario empresarial
  Future<List<ServiceModel>> getUserServices() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection("userServices")
          .doc(userId)
          .collection("categories")
          .get();
      List<ServiceModel> userServicesList = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
        QuerySnapshot<Map<String, dynamic>> servicesSnapshot =
        await doc.reference.collection("services").get();
        List<ServiceModel> services = servicesSnapshot.docs
            .map((e) => ServiceModel.fromJson(e.data()))
            .toList();
        userServicesList.addAll(services);
      }

      return userServicesList;
    } catch (e) {
      showMessage(e.toString());
      return [];
    }
  }

// Función para obtener información de una categoría y sus servicios
  Future<List<ServiceModel>> getCategoryViewService(String categoryId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firebaseFirestore
          .collection("userServices")
          .doc(userId)
          .collection("categories")
          .doc(categoryId)
          .collection("services")
          .get();
      List<ServiceModel> serviceModelList = querySnapshot.docs
          .map((e) => ServiceModel.fromJson(e.data()))
          .toList();
      return serviceModelList;
    } catch (e) {
      showMessage(e.toString());
      return [];
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
//funcion obtener informacion del usuario empresarial
  Future<UserModel> getUserInformation() async {
    DocumentSnapshot<Map<String, dynamic>> querySnapshot =
    await _firebaseFirestore
        .collection("businessusers")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    return UserModel.fromJson(querySnapshot.data()!);
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
      double price, {
        bool isOnPromotion = false, // Nuevo parámetro opcional
        double discountedPrice = 0.0, // Nuevo parámetro opcional
      }) async {
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
          'isOnPromotion': isOnPromotion, // Nuevo campo
          'discountedPrice': discountedPrice, // Nuevo campo
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
  Future<void> updateService(
      String serviceId,
      String name,
      String description,
      double price, {
        bool isOnPromotion = false, // Nuevo parámetro opcional
        double discountedPrice = 0.0, // Nuevo parámetro opcional
      }) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection("userServices")
          .doc(userId)
          .collection("categories")
          .get();
      bool serviceFound = false;
      String? categorieId;

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        String currentCategorieId = documentSnapshot.id;
        QuerySnapshot servicesQuerySnapshot = await _firebaseFirestore
            .collection("userServices")
            .doc(userId)
            .collection("categories")
            .doc(currentCategorieId)
            .collection("services")
            .where('id', isEqualTo: serviceId)
            .get();

        if (servicesQuerySnapshot.docs.isNotEmpty) {
          serviceFound = true;
          categorieId = currentCategorieId;
          break;
        }
      }

      if (serviceFound) {
        await _firebaseFirestore
            .collection("userServices")
            .doc(userId)
            .collection("categories")
            .doc(categorieId)
            .collection("services")
            .doc(serviceId)
            .update({
          'name': name,
          'description': description,

          'price': price,
          'isOnPromotion': isOnPromotion, // Nuevo campo
          'discountedPrice': discountedPrice, // Nuevo campo
        });
      } else {
        print('No se encontró el servicio con el id: $serviceId');
        throw Exception('No se encontró el servicio con el id: $serviceId');
      }
    } catch (e) {
      // Manejar errores
      print('Error al actualizar el servicio: $e');
      throw e; // Puedes manejar el error de otra manera si lo deseas
    }
  }

  // Función para eliminar un servicio de Firestore
  Future<void> deleteService(String serviceId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection("userServices")
          .doc(userId)
          .collection("categories")
          .get();

      bool serviceFound = false;
      String? categorieId;

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        String tempCategorieId = documentSnapshot.id;
        QuerySnapshot servicesQuerySnapshot = await _firebaseFirestore
            .collection("userServices")
            .doc(userId)
            .collection("categories")
            .doc(tempCategorieId)
            .collection("services")
            .where('id', isEqualTo: serviceId)
            .get();

        if (servicesQuerySnapshot.docs.isNotEmpty) {
          serviceFound = true;
          categorieId = tempCategorieId;
          break;
        }
      }

      if (serviceFound) {
        await _firebaseFirestore
            .collection("userServices")
            .doc(userId)
            .collection("categories")
            .doc(categorieId!)
            .collection('services')
            .doc(serviceId)
            .delete();
      } else {
        print('No se encontró el servicio con el id: $serviceId');
        throw Exception('No se encontró el servicio con el id: $serviceId');
      }
    } catch (e) {
      // Manejar errores
      print('Error al eliminar el servicio: $e');
      throw e; // Puedes manejar el error de otra manera si lo deseas
    }
  }

}
