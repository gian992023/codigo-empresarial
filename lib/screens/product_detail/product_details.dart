import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:conexion/models/product_model/product_model.dart';
import 'package:conexion/provider/app_provider.dart';
import 'package:conexion/firebase_helper/firebase_firestore_helper/firebase_firestore.dart';
import 'package:provider/provider.dart';

class ProductDetails extends StatefulWidget {
  final ProductModel singleProduct;

  const ProductDetails({Key? key, required this.singleProduct}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  File? image;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.singleProduct.name;
    descriptionController.text = widget.singleProduct.description;
    qtyController.text = widget.singleProduct.qty.toString();
    priceController.text = widget.singleProduct.price.toString();
  }

  void updatePicture() async {
    XFile? value = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    if (value != null) {
      setState(() {
        image = File(value.path);
      });
    }
  }

  void updateProduct(BuildContext context) async {
    try {
      String name = nameController.text;
      String description = descriptionController.text;
      int qty = int.tryParse(qtyController.text) ?? 0;
      double price = double.tryParse(priceController.text) ?? 0.0;

      await FirebaseFirestoreHelper.instance.updateProduct(
        widget.singleProduct.id,
        name,
        description,
        qty,
        price,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto actualizado con éxito'),
        ),
      );
    } catch (e) {
      print('Error al actualizar el producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el producto'),
        ),
      );
    }
  }

  void deleteProduct(BuildContext context) async {
    try {
      await FirebaseFirestoreHelper.instance.deleteProduct(widget.singleProduct.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado con éxito'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error al eliminar el producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar el producto'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Producto"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: updatePicture,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      if (image != null)
                        Image.file(
                          image!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      if (widget.singleProduct.image.isNotEmpty)
                        Image.network(
                          widget.singleProduct.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Producto',
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: qtyController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Precio',
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => updateProduct(context),
                  child: const Text('Editar'),
                ),
                ElevatedButton(
                  onPressed: () => deleteProduct(context),
                  child: const Text('Eliminar'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
