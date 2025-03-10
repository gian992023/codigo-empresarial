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

  @override
  void initState() {
    super.initState();
    getUserOrders();
  }

  Future<void> getUserOrders() async {
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
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

          // Obtener el método de pago desde userOrders
          String? paymentMethod;
          QuerySnapshot<Map<String, dynamic>> paymentQuerySnapshot = await _firebaseFirestore
              .collection("userOrders")
              .doc(clientId)
              .collection("orders")
              .where("idventa", isEqualTo: productData['idventa'])
              .get();

          if (paymentQuerySnapshot.docs.isNotEmpty) {
            paymentMethod = paymentQuerySnapshot.docs.first.data()['payment'] ?? 'Desconocido';
          }

          clientProductsMap[clientId]!.add({
            "productId": productDoc.id,
            "name": productData['product']['name'],
            "qty": productData['product']['qty'],
            "status": productData['status'],
            "idventa": productData['idventa'],
            "payment": paymentMethod,
          });
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print("Error al obtener pedidos: $e");
    }
  }

  void _updateOrderStatus(String clientId, String productId, String idVenta, String status) async {
    try {
      WriteBatch batch = _firebaseFirestore.batch();

      QuerySnapshot ventasSnapshot = await _firebaseFirestore
          .collection("ventas")
          .doc(userId)
          .collection("clientes")
          .doc(clientId)
          .collection("productos")
          .where("idventa", isEqualTo: idVenta)
          .get();

      for (var doc in ventasSnapshot.docs) {
        batch.update(doc.reference, {"status": status});
      }

      QuerySnapshot userOrdersSnapshot = await _firebaseFirestore
          .collection("userOrders")
          .doc(clientId)
          .collection("orders")
          .where("idventa", isEqualTo: idVenta)
          .get();

      for (var doc in userOrdersSnapshot.docs) {
        batch.update(doc.reference, {"status": status});
      }

      await batch.commit();
      await getUserOrders();

      print("Estado actualizado en ambas rutas correctamente.");
    } catch (e) {
      print("Error al actualizar el estado en ambas rutas: $e");
    }
  }

  void _deleteOrder(String clientId, String idVenta) async {
    try {
      WriteBatch batch = _firebaseFirestore.batch();

      QuerySnapshot ventasSnapshot = await _firebaseFirestore
          .collection("ventas")
          .doc(userId)
          .collection("clientes")
          .doc(clientId)
          .collection("productos")
          .where("idventa", isEqualTo: idVenta)
          .get();

      for (var doc in ventasSnapshot.docs) {
        batch.delete(doc.reference);
      }

      QuerySnapshot userOrdersSnapshot = await _firebaseFirestore
          .collection("userOrders")
          .doc(clientId)
          .collection("orders")
          .where("idventa", isEqualTo: idVenta)
          .get();

      for (var doc in userOrdersSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      await getUserOrders();

      print("Orden eliminada correctamente.");
    } catch (e) {
      print("Error al eliminar la orden: $e");
    }
  }

  void _showOrderDialog(BuildContext context, String clientId, String productId, String idVenta, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Actualizar pedido'),
          content: Text('¿Cuál es el nuevo estado del pedido?'),
          actions: [
            if (currentStatus == 'pendiente') ...[
              TextButton(
                onPressed: () {
                  _deleteOrder(clientId, idVenta);
                  Navigator.of(context).pop();
                },
                child: Text('Rechazar'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(clientId, productId, idVenta, 'aceptado');
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
            if (currentStatus == 'aceptado') ...[
              TextButton(
                onPressed: () {
                  _deleteOrder(clientId, idVenta);
                  Navigator.of(context).pop();
                },
                child: Text('Cancelado'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(clientId, productId, idVenta, 'entregado');
                  Navigator.of(context).pop();
                },
                child: Text('Entregado'),
              ),
            ],
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos de Clientes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: clientsList.length,
        itemBuilder: (context, index) {
          var client = clientsList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Colors.white,
            child: ExpansionTile(
              title: Text(
                'Cliente: ${client['name']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: clientProductsMap[client['clientId']]!.map((product) {
                return ListTile(
                  title: Text('${product['name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cantidad: ${product['qty']}'),
                      Text('Tipo de pago: ${product['payment'] ?? 'No especificado'}'),
                    ],
                  ),
                  trailing: Text(
                    '${product['status'].toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  onTap: () => _showOrderDialog(context, client['clientId'], product['productId'], product['idventa'], product['status']),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}