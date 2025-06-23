import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:conexion/models/service_model/service_model.dart';
import 'package:conexion/provider/app_provider.dart';
import 'package:conexion/firebase_helper/firebase_firestore_helper/firebase_firestore.dart';
import 'package:provider/provider.dart';

class ServiceDetails extends StatefulWidget {
  final ServiceModel singleService;

  const ServiceDetails({Key? key, required this.singleService}) : super(key: key);

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  File? image;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.singleService.name;
    descriptionController.text = widget.singleService.description;
    priceController.text = widget.singleService.price.toString();
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

  void updateService(BuildContext context) async {
    try {
      String name = nameController.text;
      String description = descriptionController.text;
      double price = double.tryParse(priceController.text) ?? 0.0;
      await FirebaseFirestoreHelper.instance.updateService(
        widget.singleService.id,
        name,
        description,
        price,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servicio actualizado con éxito'),
        ),
      );
    } catch (e) {
      print('Error al actualizar el servicio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el servicio'),
        ),
      );
    }
  }

  void deleteService(BuildContext context) async {
    try {
      await FirebaseFirestoreHelper.instance.deleteService(widget.singleService.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servicio eliminado con éxito'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error al eliminar el servicio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar el servicio'),
        ),
      );
    }
  }

  void applyDiscount(BuildContext context) async {
    try {
      double discount = double.tryParse(discountController.text) ?? 0.0;
      double originalPrice = double.tryParse(priceController.text) ?? 0.0;
      double discountedPrice = originalPrice - (originalPrice * discount / 100);

      await FirebaseFirestoreHelper.instance.updateService(
        widget.singleService.id,
        nameController.text,
        descriptionController.text,
        originalPrice, // Precio original
        isOnPromotion: true, // Indica que el servicio está en promoción
        discountedPrice: discountedPrice, // Guarda el precio descontado
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promoción aplicada con éxito'),
        ),
      );
    } catch (e) {
      print('Error al aplicar la promoción: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al aplicar la promoción'),
        ),
      );
    }
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
        labelStyle: const TextStyle(color: Color(0xFF6B4F4F)),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        shadowColor: Colors.brown.withOpacity(0.3),
      ),
      onPressed: onPressed,
    );
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
          "Editar Servicio",
          style: TextStyle(
            color: Color(0xFF4A3A3A),
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.brown,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF6B4F4F)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: updatePicture,
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
                                if (widget.singleService.image.isNotEmpty && image == null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      widget.singleService.image,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const Align(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Color(0xFF6B4F4F),
                                    size: 50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      _buildInputField(
                        controller: nameController,
                        label: 'Nombre del Servicio',
                        icon: Icons.work,
                      ),
                      const SizedBox(height: 18.0),
                      _buildInputField(
                        controller: descriptionController,
                        label: 'Descripción',
                        icon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 18.0),
                      _buildInputField(
                        controller: priceController,
                        label: 'Precio',
                        icon: Icons.attach_money,
                        inputType: TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 18.0),
                      _buildInputField(
                        controller: discountController,
                        label: 'Descuento (%)',
                        icon: Icons.percent,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 20.0),
                      Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: 85.0,
                        runSpacing: 10.0,
                        children: [
                          _buildActionButton(
                            text: 'Editar',
                            color: const Color(0xFF8F6645),
                            icon: Icons.edit,
                            onPressed: () => updateService(context),
                          ),
                          _buildActionButton(
                            text: 'Eliminar',
                            color: Colors.red,
                            icon: Icons.delete,
                            onPressed: () => deleteService(context),
                          ),
                          _buildActionButton(
                            text: 'Aplicar promoción',
                            color: Colors.green,
                            icon: Icons.local_offer,
                            onPressed: () => applyDiscount(context),
                          ),
                        ],
                      ),

                      // Espacio extra para asegurar que el contenido final sea visible
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
