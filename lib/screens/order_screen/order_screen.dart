import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  List<Map<String, dynamic>> clientsList = [];
  Map<String, List<Map<String, dynamic>>> clientProductsMap = {};
  String? selectedClientId;

  @override
  void initState() {
    super.initState();
    getUserOrders();
  }

  Future<void> getUserOrders() async {
    if (userId == null) {
      print("User ID is null");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Obtener la colección de clientes dentro de ventas
      QuerySnapshot<Map<String, dynamic>> clientsQuerySnapshot = await _firebaseFirestore
          .collection("ventas")
          .doc(userId)
          .collection("clientes")
          .get();

      clientsList.clear();
      clientProductsMap.clear();

      for (var clientDoc in clientsQuerySnapshot.docs) {
        String clientId = clientDoc.id;
        clientsList.add({
          "clientId": clientId,
          "name": clientDoc.data()['name'] ?? 'Sin nombre',
        });

        // Obtener la subcolección de productos para cada cliente
        QuerySnapshot<Map<String, dynamic>> productsQuerySnapshot = await _firebaseFirestore
            .collection("ventas")
            .doc(userId)
            .collection("clientes")
            .doc(clientId)
            .collection("productos")
            .get();

        clientProductsMap[clientId] = [];

        for (var productDoc in productsQuerySnapshot.docs) {
          Map<String, dynamic> productData = productDoc.data();
          clientProductsMap[clientId]!.add({
            "productId": productDoc.id,
            "name": productData['product']['name'],
            "qty": productData['product']['qty'],
            "status": productData['status']
          });
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error retrieving orders: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateOrderStatus(String clientId, String productId, String status) async {
    try {
      if (status == 'rechazado') {
        await _firebaseFirestore
            .collection("ventas")
            .doc(userId)
            .collection("clientes")
            .doc(clientId)
            .collection("productos")
            .doc(productId)
            .delete();
      } else {
        // Actualiza el estatus en la colección "ventas"
        await _firebaseFirestore
            .collection("ventas")
            .doc(userId)
            .collection("clientes")
            .doc(clientId)
            .collection("productos")
            .doc(productId)
            .update({"status": status});

        // Obtener el idventa para buscar en las colecciones "orders" y "userOrders"
        DocumentSnapshot<Map<String, dynamic>> productDoc = await _firebaseFirestore
            .collection("ventas")
            .doc(userId)
            .collection("clientes")
            .doc(clientId)
            .collection("productos")
            .doc(productId)
            .get();

        String idventa = productDoc.data()?["idventa"];

        if (idventa != null && idventa.isNotEmpty) {
          // Actualiza el estatus en la colección "orders"
          QuerySnapshot<Map<String, dynamic>> ordersQuerySnapshot = await _firebaseFirestore
              .collection("orders")
              .where("idventa", isEqualTo: idventa)
              .get();

          for (var orderDoc in ordersQuerySnapshot.docs) {
            await orderDoc.reference.update({"status": status});
          }

          // Actualiza el estatus en la colección "userOrders"
          QuerySnapshot<Map<String, dynamic>> userOrdersQuerySnapshot = await _firebaseFirestore
              .collection("userOrders")
              .doc(clientId)
              .collection("orders")
              .where("idventa", isEqualTo: idventa)
              .get();

          for (var userOrderDoc in userOrdersQuerySnapshot.docs) {
            await userOrderDoc.reference.update({"status": status});
          }
        }
      }

      // Refrescar la lista de productos después de la actualización
      await getUserOrders();
    } catch (e) {
      print("Error updating order status: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos de Clientes'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: clientsList.length,
        itemBuilder: (context, index) {
          var client = clientsList[index];
          return ExpansionTile(
            title: Text('Cliente: ${client['name']}'),
            onExpansionChanged: (expanded) {
              setState(() {
                selectedClientId = expanded ? client['clientId'] : null;
              });
            },
            children: selectedClientId == client['clientId']
                ? clientProductsMap[client['clientId']]!.map((product) {
              return Card(
                child: ListTile(
                  title: Text('Producto: ${product['name']}'),
                  subtitle: Text('Cantidad: ${product['qty']}'),
                  trailing: Text('Estado: ${product['status']}'),
                  onTap: product['status'] == 'aceptado'
                      ? null
                      : () {
                    _showOrderDialog(context, client['clientId'],
                        product['productId'], product['status']);
                  },
                ),
              );
            }).toList()
                : [],
          );
        },
      ),
    );
  }

  void _showOrderDialog(BuildContext context, String clientId, String productId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pedido de $productId'),
          content: Text('¿Acepta este pedido?'),
          actions: [
            if (currentStatus != 'aceptado') ...[
              TextButton(
                onPressed: () {
                  _updateOrderStatus(clientId, productId, 'rechazado');
                  Navigator.of(context).pop();
                },
                child: Text('Rechazar'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(clientId, productId, 'aceptado');
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ]
          ],
        );
      },
    );
  }
}
