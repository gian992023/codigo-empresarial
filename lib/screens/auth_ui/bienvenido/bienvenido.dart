import 'package:conexion/constants/asset_images.dart';
import 'package:conexion/constants/routes.dart';
import 'package:conexion/screens/auth_ui/sign_up/sign_up.dart';
import 'package:flutter/material.dart';

import '../login/login.dart';
import '../../../widgets/primary_button/primary_button.dart';

class Bienvenido extends StatelessWidget {
  const Bienvenido({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              Text(
                "Bienvenido a Compy",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              // Subtítulo
              Text(
                "Comprar cualquier producto desde cualquier lugar",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              // Logo
              Image.asset(
                AssetsImages.instance.compy,
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 10),
              // Botón de Google
              GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  padding: EdgeInsets.all(12),

                ),
              ),
              const SizedBox(height: 10),
              // Botón de Iniciar Sesión
              PrimaryButton(
                title: "Iniciar sesión",
                onPressed: () {
                  Routes.instance.push(widget: const Login(), context: context);
                },
              ),
              const SizedBox(height: 20),
              // Botón de Registrarse
              PrimaryButton(
                title: "Registrarse",
                onPressed: () {
                  Routes.instance.push(widget: const SignUp(), context: context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}