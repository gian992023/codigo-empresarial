import 'dart:io';
import 'package:conexion/firebase_helper/firebase_firestore_helper/firebase_firestore.dart';
import 'package:conexion/models/create_product_model/create_producto_model.dart';
import 'package:conexion/screens/home/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/routes.dart';
import '../../constants/constants.dart';
import '../../firebase_helper/firebase_storage_helper/firebase_storage_helper.dart';
import '../../models/category_model/category_model.dart';

class RegisterProduct extends StatefulWidget {
  const RegisterProduct({super.key});

  @override
  State<RegisterProduct> createState() => _RegisterProductState();
}

class _RegisterProductState extends State<RegisterProduct> {
  String? selectedCategoryId;
  CategoryModel? selectedCategory;
  late Future<List<CategoryModel>> categories;
  File? image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
  TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection("categories")
          .get();
      return querySnapshot.docs
          .map((e) => CategoryModel.fromJson(e.data()))
          .toList();
    } catch (e) {
      showMessage(e.toString());
      return [];
    }
  }

  void takePicture() async {
    XFile? value = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (value != null) {
      setState(() => image = File(value.path));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3D5C5),
        elevation: 4,
        centerTitle: true,
        title: Text(
          "Registro de Productos",
          style: TextStyle(
            color: const Color(0xFF4A3A3A),
            fontWeight: FontWeight.w600,
            fontSize: 22,
            shadows: [
              Shadow(
                color: Colors.brown.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF6B4F4F)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Evita que el botón quede oculto detrás de la barra de navegación inferior
          padding: const EdgeInsets.only(bottom: 100),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CupertinoButton(
                    onPressed: takePicture,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD3C0B2)),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF5F0E6).withOpacity(0.8),
                            const Color(0xFFE3D5C5).withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (image != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                image!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.camera_alt,
                              color: const Color(0xFF6B4F4F).withOpacity(0.7),
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildInputField(
                  controller: _nameController,
                  label: 'Nombre del Producto',
                  icon: Icons.shopping_cart,
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<CategoryModel>>(
                  future: getCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: const Color(0xFF6B4F4F)));
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}',
                          style: TextStyle(color: const Color(0xFF6B4F4F)));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Text('No hay categorías disponibles',
                          style: TextStyle(color: const Color(0xFF6B4F4F)));
                    }
                    List<CategoryModel> categoriesList = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      onChanged: (String? newValue) =>
                          setState(() => selectedCategoryId = newValue),
                      items: categoriesList.map((CategoryModel category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name,
                              style:
                              TextStyle(color: const Color(0xFF4A3A3A))),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon:
                        Icon(Icons.category, color: const Color(0xFF6B4F4F)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                          const BorderSide(color: Color(0xFFD3C0B2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                          const BorderSide(color: Color(0xFF6B4F4F)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F4EF),
                        labelStyle: TextStyle(color: const Color(0xFF6B4F4F)),
                      ),
                      dropdownColor: const Color(0xFFF8F4EF),
                      style: TextStyle(color: const Color(0xFF4A3A3A)),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _qtyController,
                  label: 'Cantidad',
                  icon: Icons.format_list_numbered,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _priceController,
                  label: 'Precio',
                  icon: Icons.attach_money,
                  inputType:
                  TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        text: 'Agregar Producto',
                        color: const Color(0xFF8F6645),
                        icon: Icons.add_circle_outline,
                        onPressed: _submitForm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF6B4F4F)),
        prefixIcon: Icon(icon, color: const Color(0xFF6B4F4F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD3C0B2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6B4F4F)),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F4EF),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 22, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        shadowColor: Colors.brown.withOpacity(0.3),
      ),
      onPressed: onPressed,
    );
  }

  void _submitForm() async {
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Subir imagen a Firebase Storage
      String imageUrl =
      await FirebaseStorageHelper().uploadProductImage(image!);

      // Crear modelo de producto
      CreateProductModel product = CreateProductModel(
        image: imageUrl,
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        description: _descriptionController.text,
        qty: int.tryParse(_qtyController.text) ?? 0,
      );

      // Guardar en Firestore (ahora con la lógica de "guardar name" bajo userProducts/{userId})
      bool success = await FirebaseFirestoreHelper()
          .createProductFirebase(
          product, context, selectedCategoryId ?? "Otra Categoría");

      // Antes de navegar, cerrar siempre el diálogo de carga
      Navigator.of(context).pop();

      if (success) {
        showMessage("Producto agregado exitosamente");

        // Limpiar campos
        setState(() {
          image = null;
          _nameController.clear();
          _descriptionController.clear();
          _qtyController.clear();
          _priceController.clear();
          selectedCategoryId = null;
        });

        // Redirigir a Home y actualizar la vista
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } catch (e) {
      // Si ocurre un error, cerrar el diálogo de carga
      Navigator.of(context).pop();
      showMessage("Error: ${e.toString()}");
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6B4F4F),
      ),
    );
  }
}
