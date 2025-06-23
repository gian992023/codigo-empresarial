import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InventoryItemCard extends StatelessWidget {
  final bool isProduct; // Si es producto (true) o servicio (false)
  final String name;
  final String imageUrl;
  final String price; // Para productos, se muestra precio; para servicios se mostrará "Servicio"
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InventoryItemCard({
    Key? key,
    required this.isProduct,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EF),
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF5F0E6).withOpacity(0.8),
            const Color(0xFFE3D5C5).withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen pequeña del ítem
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            )
                : Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Información: Título y, si es producto, precio; si es servicio, muestra "Servicio"
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A3A3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isProduct ? price : "Servicio",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B4F4F),
                  ),
                ),
              ],
            ),
          ),
          // Botones de acción: Editar y Eliminar, con iconos representativos.
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Color(0xFF8F6645)),
                tooltip: "Editar",
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: "Eliminar",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
