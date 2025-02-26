import 'package:conexion/constants/routes.dart';
import 'package:conexion/firebase_helper/firebase_auth_helper/firebase_auth_helper.dart';
import 'package:conexion/screens/change_password/change_password.dart';
import 'package:conexion/screens/edit_profile/edit_profile.dart';
import 'package:conexion/screens/favourite_screen/favourite_screen.dart';
import 'package:conexion/screens/order_screen/order_screen.dart';
import 'package:conexion/widgets/primary_button/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../maps/google_maps.dart';
import '../../provider/app_provider.dart';
import '../events/events_users.dart';
import '../promotions/promociones_productos.dart';
//Clase, creacion del estado de accountScreen
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}
//Clase Account Screen
class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(
      context,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            "Cuenta",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [ appProvider.getUserInformation.image == null
                  ? const Icon(
                Icons.person_outline,
                size: 120,
              )
                  : CircleAvatar(
                  backgroundImage:
                  NetworkImage(appProvider.getUserInformation.image!),
                  radius: 70),
                Text(
                  appProvider.getUserInformation.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  appProvider.getUserInformation.email,
                ),
                SizedBox(
                  height: 8.9,
                ),

                SizedBox(
                  height: 8.9,
                ),
                SizedBox(
                    width: 140,
                    height: 30,
                    child: PrimaryButton(
                      title: "Editar perfil",
                      onPressed: () {
                        Routes.instance.push(
                            widget: const EditProfile(), context: context);
                      },
                    ))
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      Routes.instance
                          .push(widget: const OrdersScreen(), context: context);
                    },
                    leading: Icon(Icons.shopping_bag_outlined),
                    title: Text("Ordenes"),
                  ),
                  ListTile(
                    onTap: () {
                      Routes.instance.push(
                          widget: const FavouriteScreen(), context: context);
                    },
                    leading: Icon(Icons.favorite_outline),
                    title: Text("Favoritos"),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapPage()),
                      );
                    },
                    leading: const Icon(Icons.map),
                    title: const Text("Ver Mapa"),
                  ),

                  ListTile(
                    onTap: () {
                      Routes.instance.push(
                          widget: const ChangePassword(), context: context);
                    },
                    leading: Icon(Icons.change_circle_outlined),
                    title: Text("Cambiar contraseña"),
                  ),
                  ListTile(
                    onTap: () {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
                    );
                    },
                    leading: Icon(Icons.event),
                    title: Text("Eventos"),
                  ),ListTile(
                    onTap: () {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  Promotions()),
                    );
                    },
                    leading: Icon(Icons.discount),
                    title: Text("Promociones"),
                  ),
                  ListTile(
                    onTap: () {
                      FirebaseAuthHelper.instance.signOut();
                      setState(() {});
                    },
                    leading: Icon(Icons.exit_to_app),
                    title: Text("Cerrar sesion"),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text("Version 1.0")
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
