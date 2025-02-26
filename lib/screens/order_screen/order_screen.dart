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
          clientProductsMap[clientId]!.add({
            "productId": productDoc.id,
            "name": productData['product']['name'],
            "qty": productData['product']['qty'],
            "status": productData['status']
          });
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _updateOrderStatus(String clientId, String productId, String status) async {
    try {
      await _firebaseFirestore
          .collection("ventas")
          .doc(userId)
          .collection("clientes")
          .doc(clientId)
          .collection("productos")
          .doc(productId)
          .update({"status": status});

      await getUserOrders();
    } catch (e) {
      print("Error updating order status: $e");
    }
  }

  void _deleteOrder(String clientId, String productId) async {
    try {
      await _firebaseFirestore
          .collection("ventas")
          .doc(userId)
          .collection("clientes")
          .doc(clientId)
          .collection("productos")
          .doc(productId)
          .delete();

      await getUserOrders();
    } catch (e) {
      print("Error deleting order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedidos de Clientes',style: TextStyle(
        fontSize: 24, // Tamaño más grande
        fontWeight: FontWeight.bold, // Negrita para más impacto
        color: Colors.black, // Color oscuro
      ),)),
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
                  subtitle: Text('Cantidad: ${product['qty']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${product['status'].toUpperCase()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: product['status'] == 'entregado' ? Colors.blue :
                          product['status'] == 'aceptado' ? Colors.green : Colors.orange,
                        ),
                      ),
                      if (product['status'] == 'pendiente' || product['status'] == 'aceptado')
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showOrderDialog(
                              context, client['clientId'], product['productId'], product['status']),
                        ),
                      if (product['status'] == 'entregado' || product['status'] == 'calificado')
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteOrder(client['clientId'], product['productId']),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
          title: Text('Actualizar pedido'),
          content: Text('¿Cuál es el nuevo estado del pedido?'),
          actions: [
            if (currentStatus != 'aceptado')
              TextButton(
                onPressed: () {
                  _updateOrderStatus(clientId, productId, 'rechazado');
                  Navigator.of(context).pop();
                },
                child: Text('Rechazar'),
              ),
            if (currentStatus != 'entregado')
              ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(clientId, productId, 'aceptado');
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            if (currentStatus == 'aceptado')
              ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(clientId, productId, 'entregado');
                  Navigator.of(context).pop();
                },
                child: Text('Entregado'),
              ),
          ],
        );
      },
    );
  }
}
