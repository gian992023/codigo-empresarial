import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:conexion/models/product_model/product_model.dart';
import 'package:conexion/models/service_model/service_model.dart';
import '../product_detail/product_details.dart';
import '../service_details/service_details.dart';

class Promotions extends StatefulWidget {
  @override
  _PromotionsState createState() => _PromotionsState();
}

class _PromotionsState extends State<Promotions> {
  String searchQuery = "";
  User? user = FirebaseAuth.instance.currentUser;

  // Eliminar promoción de producto
  Future<void> _removePromotion(String categoryId, String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection("userProducts")
          .doc(user?.uid)
          .collection("categories")
          .doc(categoryId)
          .collection("products")
          .doc(productId)
          .update({
        "discountedPrice": FieldValue.delete(),
        "isOnPromotion": FieldValue.delete(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Promoción eliminada correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar promoción: $e")),
      );
    }
  }

  // Eliminar promoción de servicio
  Future<void> _removeServicePromotion(String categoryId, String serviceId) async {
    try {
      await FirebaseFirestore.instance
          .collection("userServices")
          .doc(user?.uid)
          .collection("categories")
          .doc(categoryId)
          .collection("services")
          .doc(serviceId)
          .update({
        "discountedPrice": FieldValue.delete(),
        "isOnPromotion": FieldValue.delete(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Promoción del servicio eliminada correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar promoción del servicio: $e")),
      );
    }
  }

  // Construye la vista de promociones para productos
  Widget buildProductsPromotions() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("userProducts")
          .doc(user?.uid)
          .collection("categories")
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No tienes categorías con productos"));
        }

        var categories = snapshot.data!.docs;

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            var category = categories[index];
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("userProducts")
                  .doc(user?.uid)
                  .collection("categories")
                  .doc(category.id)
                  .collection("products")
                  .where("isOnPromotion", isEqualTo: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> productSnapshot) {
                if (productSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
                  return const SizedBox();
                }

                var products = productSnapshot.data!.docs.map((doc) {
                  return ProductModel.fromJson(doc.data() as Map<String, dynamic>);
                }).toList();

                var filteredProducts = products.where((product) {
                  return product.name.toLowerCase().contains(searchQuery);
                }).toList();

                return Column(
                  children: filteredProducts.map((product) {
                    return ListTile(
                      leading: Image.network(
                        product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        "${product.discountedPrice} \$ (Descuento aplicado)",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removePromotion(category.id, product.id);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetails(singleProduct: product),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  // Construye la vista de promociones para servicios
  Widget buildServicesPromotions() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("userServices")
          .doc(user?.uid)
          .collection("categories")
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }
        if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
          return const Center(child: Text("No tienes categorías con servicios"));
        }
        var categories = snapshot.data!.docs;

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            var category = categories[index];
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("userServices")
                  .doc(user?.uid)
                  .collection("categories")
                  .doc(category.id)
                  .collection("services")
                  .where("isOnPromotion", isEqualTo: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> serviceSnapshot) {
                if(serviceSnapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }
                if(!serviceSnapshot.hasData || serviceSnapshot.data!.docs.isEmpty){
                  return const SizedBox();
                }
                var services = serviceSnapshot.data!.docs.map((doc) {
                  return ServiceModel.fromJson(doc.data() as Map<String, dynamic>);
                }).toList();

                var filteredServices = services.where((service) {
                  return service.name.toLowerCase().contains(searchQuery);
                }).toList();

                return Column(
                  children: filteredServices.map((service) {
                    return ListTile(
                      leading: Image.network(
                        service.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(service.name),
                      subtitle: Text(
                        "${service.discountedPrice} \$ (Descuento aplicado)",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removeServicePromotion(category.id, service.id);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetails(singleService: service),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Promociones",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent, // Color del indicador (cuando está seleccionado)
            labelColor: Colors.black45, // Color del texto seleccionado
            unselectedLabelColor: Colors.black, // Color del texto cuando no está seleccionado
            tabs: [
              Tab(
                child: Text(
                  "Productos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  "Servicios",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Buscar",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  buildProductsPromotions(),
                  buildServicesPromotions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
