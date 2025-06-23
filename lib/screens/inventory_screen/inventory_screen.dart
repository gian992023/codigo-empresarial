import 'package:conexion/firebase_helper/firebase_firestore_helper/firebase_firestore.dart';
import 'package:conexion/models/product_model/product_model.dart';
import 'package:conexion/models/service_model/service_model.dart';
import 'package:conexion/screens/product_detail/product_details.dart';
import 'package:conexion/screens/service_details/service_details.dart';
import 'package:conexion/constants/routes.dart';
import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<dynamic>> _inventoryFuture;

  // Se obtienen los productos y servicios del usuario empresarial
  Future<List<dynamic>> _fetchInventory() async {
    List<ProductModel> products = await FirebaseFirestoreHelper.instance.getUserProducts();
    List<ServiceModel> services = await FirebaseFirestoreHelper.instance.getUserServices();
    // Combina ambas listas. Puedes agregar lógica de ordenamiento si lo deseas.
    return [...products, ...services];
  }

  @override
  void initState() {
    super.initState();
    _inventoryFuture = _fetchInventory();
  }

  // Funciones para manejar la edición y eliminación según el tipo
  void _editItem(dynamic item) {
    if (item is ProductModel) {
      Routes.instance.push(widget: ProductDetails(singleProduct: item), context: context);
    } else if (item is ServiceModel) {
      Routes.instance.push(widget: ServiceDetails(singleService: item), context: context);
    }
  }

  void _deleteItem(dynamic item) async {
    try {
      if (item is ProductModel) {
        await FirebaseFirestoreHelper.instance.deleteProduct(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Producto eliminado con éxito")),
        );
      } else if (item is ServiceModel) {
        await FirebaseFirestoreHelper.instance.deleteService(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Servicio eliminado con éxito")),
        );
      }
      // Recarga el inventario actualizando el Future
      setState(() {
        _inventoryFuture = _fetchInventory();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar el item")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3D5C5),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          "Inventario",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A3A3A),
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF6B4F4F)),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _inventoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B4F4F)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No hay items en el inventario",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final List<dynamic> inventory = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final dynamic item = inventory[index];
              return InventoryItemCard(
                id: item.id,
                imageUrl: item.image,
                title: item.name,
                onEdit: () => _editItem(item),
                onDelete: () => _deleteItem(item),
              );
            },
          );
        },
      ),
    );
  }
}

class InventoryItemCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InventoryItemCard({
    Key? key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EF),
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF5F0E6).withOpacity(0.8),
            const Color(0xFFE3D5C5).withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen pequeña del item; si no existe, muestra un contenedor de placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            )
                : Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          // Título del item
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A3A3A),
              ),
            ),
          ),
          // Botones de acción: Editar y Eliminar
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: Color(0xFF8F6645)),
            tooltip: "Editar",
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: "Eliminar",
          ),
        ],
      ),
    );
  }
}
