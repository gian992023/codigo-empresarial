import 'package:conexion/constants/routes.dart';
import 'package:conexion/firebase_helper/firebase_auth_helper/firebase_auth_helper.dart';
import 'package:conexion/screens/change_password/change_password.dart';
import 'package:conexion/screens/edit_profile/edit_profile.dart';
import 'package:conexion/screens/inventory_screen/inventory_screen.dart';
import 'package:conexion/screens/order_screen/order_screen.dart';
import 'package:conexion/screens/promotions/promociones_productos.dart';
import 'package:conexion/screens/events/events_users.dart';
import 'package:conexion/maps/google_maps.dart';
import 'package:conexion/provider/app_provider.dart';
import 'package:conexion/widgets/primary_button/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../events/view_events.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.getUserInformation;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3D5C5),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          "Cuenta",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A3A3A),
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF6B4F4F)),
      ),
      body: Column(
        children: [
          // ─── Sección de perfil ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: const Color(0xFFF5F0E6),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Sólo ocupa lo que necesite
              children: [
                user.image == null
                    ? const Icon(
                  Icons.person_outline,
                  size: 120,
                  color: Colors.grey,
                )
                    : CircleAvatar(
                  backgroundImage: NetworkImage(user.image!),
                  radius: 70,
                ),
                const SizedBox(height: 8),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4C4C4C),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  (user.phone != null && user.phone!.isNotEmpty)
                      ? user.phone!
                      : 'No tiene número registrado',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 160,
                  height: 38,
                  child: PrimaryButton(
                    title: "Editar perfil",
                    onPressed: () {
                      Routes.instance.push(
                        widget: const EditProfile(),
                        context: context,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ─── Menú de opciones ──────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView(
                children: [
                  _buildMenuTile(
                    icon: Icons.shopping_bag_outlined,
                    title: "Órdenes",
                    onTap: () {
                      Routes.instance.push(widget: const OrdersScreen(), context: context);
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.inventory,
                    title: "Inventario",
                    onTap: () {
                      Routes.instance.push(widget: const InventoryScreen(), context: context);
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.map,
                    title: "Ver Mapa",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapPage()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.change_circle_outlined,
                    title: "Cambiar contraseña",
                    onTap: () {
                      Routes.instance.push(widget: const ChangePassword(), context: context);
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.event,
                    title: "Eventos",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ViewEvents()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.discount,
                    title: "Promociones",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Promotions()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.exit_to_app,
                    title: "Cerrar sesión",
                    onTap: () {
                      FirebaseAuthHelper.instance.signOut();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      "Versión 1.0",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tile del Menú (sin cambios) ────────────────────────────────────
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF6B4F4F)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4A3A3A),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
