import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const String _googleApiKey = 'AIzaSyDN6oYrSPCNj2rD5oa9GCqahkIpPXS33eI';
  LatLng? _currentPosition;
  String? _currentAddress;
  String? _userName;
  final TextEditingController _addressController = TextEditingController();
  bool _hasAddress = false;

  @override
  void initState() {
    super.initState();
    _checkAddressInDatabase();
  }

  Future<void> _checkAddressInDatabase() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('Usuario no registrado.');
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('mapas')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final address = data['address'] as String?;
        if (address != null && address.isNotEmpty) {
          setState(() {
            _currentAddress = address;
            _hasAddress = true;
          });
          await _getCoordinatesFromAddress(address);
        }
      }

      DocumentSnapshot businessUserDoc = await FirebaseFirestore.instance
          .collection('businessusers')
          .doc(currentUser.uid)
          .get();

      if (businessUserDoc.exists) {
        final businessData = businessUserDoc.data() as Map<String, dynamic>;
        setState(() {
          _userName = businessData['name'] ?? 'Usuario desconocido';
        });
      }
    } catch (e) {
      print('Error al verificar los datos en la base de datos: $e');
    }
  }

  Future<void> _saveAddress(String address) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('No hay usuario logueado.');
        return;
      }

      await FirebaseFirestore.instance
          .collection('mapas')
          .doc(currentUser.uid)
          .set({'address': address, 'name': _userName ?? 'Usuario desconocido'});

      setState(() {
        _currentAddress = address;
        _hasAddress = true;
      });

      await _getCoordinatesFromAddress(address);
    } catch (e) {
      print('Error al guardar la dirección: $e');
    }
  }

  Future<void> _getCoordinatesFromAddress(String address) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$_googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          setState(() {
            _currentPosition = LatLng(location['lat'], location['lng']);
          });
        } else {
          print('No se encontraron resultados para la dirección.');
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener coordenadas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicacion',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: _hasAddress
          ? (_currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('address_marker'),
            position: _currentPosition!,
            infoWindow: InfoWindow(
              title: _currentAddress,
              snippet: _userName != null ? '$_userName' : 'Ubicación registrada',
            ),
          ),
        },
      ))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Ingrese su dirección',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final address = _addressController.text.trim();
                if (address.isNotEmpty) {
                  _saveAddress(address);
                } else {
                  print('La dirección no puede estar vacía.');
                }
              },
              child: const Text('Crear dirección'),
            ),
          ],
        ),
      ),
    );
  }
}
