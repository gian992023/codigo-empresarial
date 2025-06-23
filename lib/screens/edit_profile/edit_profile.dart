import 'dart:io';

import 'package:conexion/constants/constants.dart';
import 'package:conexion/firebase_helper/firebase_storage_helper/firebase_storage_helper.dart';
import 'package:conexion/models/user_model/user_model.dart';
import 'package:conexion/widgets/primary_button/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../provider/app_provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? image;

  void takePicture() async {
    XFile? value = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (value != null) {
      setState(() {
        image = File(value.path);
      });
    }
  }

  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    final currentUser = appProvider.getUserInformation;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Editar perfil",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Center(
            child: image == null
                ? GestureDetector(
              onTap: takePicture,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.camera_alt,
                    size: 32, color: Colors.white),
              ),
            )
                : GestureDetector(
              onTap: takePicture,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: FileImage(image!),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Nombre de usuario",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF4C4C4C),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: textEditingController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                // Mostramos el nombre actual en hint, pero no lo sobreescribimos si el usuario no escribe nada:
                hintText: currentUser.name,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            title: "Guardar cambios",
            onPressed: () async {
              // Si el campo de texto está vacío, mantenemos el nombre original:
              final newName = textEditingController.text.trim().isNotEmpty
                  ? textEditingController.text.trim()
                  : currentUser.name;

              final updatedUser = currentUser.copyWith(name: newName);

              // Llamamos al método de actualización, pasando la posible nueva imagen
               appProvider.updateUserInfoFirebase(
                context,
                updatedUser,
                image,
              );
            },
          ),
        ],
      ),
    );
  }
}
