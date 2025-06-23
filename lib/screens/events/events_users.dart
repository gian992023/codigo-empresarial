import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EventStorageHelper {
  Future<String> uploadEventImage(File image) async {
    try {
      final String fileName =
          'eventos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef =
      FirebaseStorage.instance.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }
}

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
  TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  DateTime? _selectedDate;
  File? _image;

  // Permitir al usuario elegir imagen del evento
  void updatePicture() async {
    XFile? picked =
    await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _submitForm() async {
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final String duration = _durationController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        _selectedDate == null ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    try {
      // 1) Subir la imagen a Firebase Storage
      final String imageUrl = await EventStorageHelper().uploadEventImage(_image!);

      // 2) Obtenemos el UID del usuario empresarial actual
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      // 3) Recuperamos el "name" desde la colección "businessusers/{userId}"
      final DocumentSnapshot bizSnap = await FirebaseFirestore.instance
          .collection("businessusers")
          .doc(userId)
          .get();

      String businessName = "Negocio Desconocido";
      if (bizSnap.exists) {
        final data = bizSnap.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey("name")) {
          businessName = data["name"] as String;
        }
      }

      // 4) Nos aseguramos de que en "eventos/{userId}" exista el campo "name"
      //    y guardamos/actualizamos solo ese campo (merge: true).
      final DocumentReference parentRef = FirebaseFirestore.instance
          .collection("eventos")
          .doc(userId);

      await parentRef.set(
        {
          "name": businessName,
        },
        SetOptions(merge: true),
      );

      // 5) Ahora creamos el documento en la subcolección "mis_eventos"
      final DocumentReference docRef = parentRef
          .collection("mis_eventos")
          .doc(); // ID autogenerado

      await docRef.set({
        "title": title,
        "description": description,
        "date": _selectedDate!.toIso8601String(),
        "duration": duration,
        "image_url": imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento creado exitosamente.')),
      );

      // 6) Limpiar formularios
      _titleController.clear();
      _descriptionController.clear();
      _durationController.clear();
      setState(() {
        _selectedDate = null;
        _image = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear el evento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Eventos',
          style: TextStyle(
            fontSize: 24, // Tamaño más grande
            fontWeight: FontWeight.bold, // Negrita
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del Evento
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del Evento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Descripción
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),

            // Duración en horas
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duración (horas)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),

            // Selección de fecha
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Fecha no seleccionada'
                        : 'Fecha: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  child: const Text('Seleccionar Fecha'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Selector de imagen
            GestureDetector(
              onTap: updatePicture,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _image == null
                    ? const Center(child: Text('Seleccionar Imagen'))
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Botón para enviar el formulario
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Crear Evento'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
