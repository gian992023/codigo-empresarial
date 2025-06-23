import 'package:flutter/material.dart';
import '../register_products/register_products.dart';
import '../services_view/register_services.dart';

class RegisterSelection extends StatelessWidget {
  const RegisterSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E6), // Beige claro base
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTitle(),
              const SizedBox(height: 40),
              _buildButtonCard(
                context: context,
                title: "Servicio",
                subtitle: "Registrar nuevo servicio",
                icon: Icons.build_rounded,
                color: const Color(0xFFA78B7D), // Marrón claro
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterService()),
                ),
              ),
              const SizedBox(height: 25),
              _buildButtonCard(
                context: context,
                title: "Producto",
                subtitle: "Registrar nuevo producto",
                icon: Icons.inventory_rounded,
                color: const Color(0xFF8F6645), // Marrón oscuro
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterProduct()),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
      Text(
      "¿Qué deseas registrar?",
      style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A3A3A), // Marrón oscuro
          letterSpacing: 1.2,
          shadows: [
      Shadow(
      color: Colors.brown.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(2, 2),)
      ],
    ),
    ),
    const SizedBox(height: 10),
    Container(
    height: 3,
    width: 100,
    decoration: BoxDecoration(
    color: const Color(0xFFD3C0B2), // Marrón claro
    borderRadius: BorderRadius.circular(2),
    ),
    ),
    ],
    );
    }

  Widget _buildButtonCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(15),
        shadowColor: Colors.brown.withOpacity(0.2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.95),
                  color.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}