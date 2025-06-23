// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  List<Map<String, dynamic>> clientsList = [];
  Map<String, List<Map<String, dynamic>>> clientOrdersMap = {};

  // Paleta de colores
  static const Color primaryColor = Color(0xFFE3D5C5);
  static const Color accentColor = Color(0xFF6B4F4F);
  static const Color textColor = Color(0xFF4A3A3A);
  static const Color backgroundCard = Color(0xFFF8F4EF);
  static const Color borderColor = Color(0xFFD3C0B2);

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
      clientOrdersMap.clear();
      for (var clientDoc in clientsQuerySnapshot.docs) {
        String clientId = clientDoc.id;
        Map<String, dynamic> clientData = clientDoc.data();
        clientsList.add({
          "clientId": clientId,
          "name": clientData['name'] ?? 'Sin nombre',
          "address": clientData['address'] ?? 'Sin dirección',
        });
        clientOrdersMap[clientId] = [];
        // Productos
        QuerySnapshot<Map<String, dynamic>> productsQuerySnapshot = await _firebaseFirestore
            .collection("ventas")
            .doc(userId)
            .collection("clientes")
            .doc(clientId)
            .collection("productos")
            .get();

        for (var productDoc in productsQuerySnapshot.docs) {
          Map<String, dynamic> productData = productDoc.data();
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

          clientOrdersMap[clientId]!.add({
            "type": "product",
            "docId": productDoc.id,
            "name": productData['product']['name'],
            "qty": productData['product']['qty'],
            "status": productData['status'],
            "idventa": productData['idventa'],
            "payment": paymentMethod,
          });
        }
        // Servicios
        QuerySnapshot<Map<String, dynamic>> servicesQuerySnapshot = await _firebaseFirestore
            .collection("ventas")
            .doc(userId)
            .collection("clientes")
            .doc(clientId)
            .collection("servicios")
            .get();
        for (var serviceDoc in servicesQuerySnapshot.docs) {
          Map<String, dynamic> serviceData = serviceDoc.data();
          String? paymentMethod;

          QuerySnapshot<Map<String, dynamic>> paymentQuerySnapshot = await _firebaseFirestore
              .collection("userOrders")
              .doc(clientId)
              .collection("orders")
          // Para servicios en userOrders usamos el campo "idsolicitud"
              .where("idsolicitud", isEqualTo: serviceData['idventa'])
              .get();

          paymentMethod = paymentQuerySnapshot.docs.isNotEmpty
              ? paymentQuerySnapshot.docs.first.data()['payment']
              : "Solicitar servicio";

          clientOrdersMap[clientId]!.add({
            "type": "service",
            "docId": serviceDoc.id,
            "name": serviceData['service']['name'],
            "qty": 1,
            "status": serviceData['status'],
            "idventa": serviceData['idventa'],
            "payment": paymentMethod,
          });
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  // Ahora manejamos correctamente ambos casos
  void _updateOrderStatus(String clientId, String idVenta, String status, String type) async {
    try {
      WriteBatch batch = _firebaseFirestore.batch();
      String subcollection = (type == "product") ? "productos" : "servicios";

      // Actualizar en ventas
      QuerySnapshot ventasSnapshot = await _firebaseFirestore
          .collection("ventas")
          .doc(userId)
          .collection("clientes")
          .doc(clientId)
          .collection(subcollection)
          .where("idventa", isEqualTo: idVenta)
          .get();

      for (var doc in ventasSnapshot.docs) {
        batch.update(doc.reference, {"status": status});
      }

      // Actualizar en userOrders, usando el campo adecuado según tipo
      String orderField = (type == "product") ? "idventa" : "idsolicitud";
      QuerySnapshot userOrdersSnapshot = await _firebaseFirestore
          .collection("userOrders")
          .doc(clientId)
          .collection("orders")
          .where(orderField, isEqualTo: idVenta)
          .get();

      for (var doc in userOrdersSnapshot.docs) {
        batch.update(doc.reference, {"status": status});
      }

      await batch.commit();
      await getUserOrders();
    } catch (e) {
      print("Error actualizando estado: $e");
    }
  }

  void _deleteOrder(String clientId, String idVenta, String type) async {
    try {
      WriteBatch batch = _firebaseFirestore.batch();
      String subcollection = (type == "product") ? "productos" : "servicios";

      // Eliminar en ventas
      QuerySnapshot ventasSnapshot = await _firebaseFirestore
          .collection("ventas")
          .doc(userId)
          .collection("clientes")
          .doc(clientId)
          .collection(subcollection)
          .where("idventa", isEqualTo: idVenta)
          .get();

      for (var doc in ventasSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar en userOrders, usando el campo adecuado según tipo
      String orderField = (type == "product") ? "idventa" : "idsolicitud";
      QuerySnapshot userOrdersSnapshot = await _firebaseFirestore
          .collection("userOrders")
          .doc(clientId)
          .collection("orders")
          .where(orderField, isEqualTo: idVenta)
          .get();

      for (var doc in userOrdersSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      await getUserOrders();
    } catch (e) {
      print("Error eliminando orden: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Pedidos de Clientes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textColor,
            shadows: [
              Shadow(
                color: Colors.brown.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(color: accentColor),
      ),
      backgroundColor: Color(0xFFF5F0E6),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : ListView.builder(
        itemCount: clientsList.length,
        itemBuilder: (context, index) {
          var client = clientsList[index];
          String clientId = client['clientId'];
          String clientName = client['name'];
          String addressClient = client['address'];

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Card(
              color: backgroundCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 1.5),
              ),
              elevation: 0,
              child: ExpansionTile(
                leading: Icon(Icons.person, color: accentColor),
                title: Text(
                  clientName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  addressClient,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                childrenPadding: EdgeInsets.symmetric(horizontal: 15),
                children: clientOrdersMap[clientId]!.map((item) {
                  String type = item["type"];
                  String name = item["name"];
                  int qty = item["qty"] ?? 1;
                  String status = item["status"];
                  String idVenta = item["idventa"];
                  String paymentMethod = item["payment"] ?? 'No especificado';

                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: borderColor.withOpacity(0.3)),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cantidad: $qty',
                            style: TextStyle(color: textColor.withOpacity(0.8)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Método: $paymentMethod',
                            style: TextStyle(
                              color: accentColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () => _showOrderDialog(
                        context,
                        clientId: clientId,
                        idVenta: idVenta,
                        currentStatus: status,
                        type: type,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'aceptado':
        return Colors.green;
      case 'entregado':
        return Color(0xFF4A3A3A);
      case 'rechazado':
        return Colors.red;
      default:
        return accentColor;
    }
  }

  void _showOrderDialog(
      BuildContext context, {
        required String clientId,
        required String idVenta,
        required String currentStatus,
        required String type,
      }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        title: Text(
          'Actualizar pedido',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Cuál es el nuevo estado del pedido?',
          style: TextStyle(color: textColor.withOpacity(0.8)),
        ),
        actions: [
          if (currentStatus == 'pendiente') ...[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _deleteOrder(clientId, idVenta, type);
                Navigator.pop(context);
              },
              child: Text('Rechazar', style: TextStyle(color: Colors.red.shade800)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _updateOrderStatus(clientId, idVenta, 'aceptado', type);
                Navigator.pop(context);
              },
              child: Text('Aceptar', style: TextStyle(color: Colors.white)),
            ),
          ],
          if (currentStatus == 'aceptado') ...[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _deleteOrder(clientId, idVenta, type);
                Navigator.pop(context);
              },
              child: Text('Cancelar', style: TextStyle(color: Colors.orange.shade800)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A3A3A),
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _updateOrderStatus(clientId, idVenta, 'entregado', type);
                Navigator.pop(context);
              },
              child: Text('Entregado', style: TextStyle(color: Colors.white)),
            ),
          ],
          IconButton(
            icon: Icon(Icons.close, color: accentColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
