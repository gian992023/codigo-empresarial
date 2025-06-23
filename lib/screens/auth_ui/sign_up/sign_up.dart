// ignore_for_file: use_build_context_synchronously

import 'package:conexion/firebase_helper/firebase_auth_helper/firebase_auth_helper.dart';
import 'package:conexion/constants/constants.dart';
import 'package:conexion/screens/auth_ui/login/login.dart';
import 'package:conexion/screens/custom_bottom_bar/custom_bottom_bar.dart';
import 'package:conexion/widgets/primary_button/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants/routes.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isShowPassword = true;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFFAE0C3);
    final Color textColor = const Color(0xFF5D4037);
    final Color buttonColor = const Color(0xFF8B4513);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Crear usuario Vendedor",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: buttonColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Haz parte de Casanare Vende",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),

            _buildTextField(nameController, "Nombre", Icons.person_outlined),
            const SizedBox(height: 12),
            _buildTextField(emailController, "E-mail", Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildTextField(phoneController, "Teléfono", Icons.phone_android_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildPasswordField(passwordController, "Contraseña"),
            const SizedBox(height: 12),
            _buildPasswordField(confirmPasswordController, "Confirmar contraseña"),
            const SizedBox(height: 36),

            PrimaryButton(
              title: "Crear cuenta",
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final phone = phoneController.text.trim();
                final password = passwordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                // Validación básica de formato de email
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(email)) {
                  showMessage("Correo electrónico no válido");
                  return;
                }

                // Validación de campos (incluye confirmPassword)
                bool isValidated = signUpValidation(
                  email, password, confirmPassword, name, phone,
                );
                if (!isValidated) return;

                // Llamada al helper CORRECTA (minúscula 'signUp')
                bool isSignedUp = await FirebaseAuthHelper.instance.signUp(
                  name, email, password, phone, context,
                );
                if (isSignedUp) {
                  Routes.instance.pushAndRemoveUntil(
                    widget: const CustomBottomBar(),
                    context: context,
                  );
                }
              },
            ),
            const SizedBox(height: 26),
            Center(
              child: Text(
                "Ya tengo una cuenta",
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Iniciar sesión",
                  style: TextStyle(
                    color: buttonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hintText,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller,
      String hintText,
      ) {
    return TextField(
      controller: controller,
      obscureText: isShowPassword,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isShowPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade700,
          ),
          onPressed: () => setState(() => isShowPassword = !isShowPassword),
        ),
      ),
    );
  }
}
