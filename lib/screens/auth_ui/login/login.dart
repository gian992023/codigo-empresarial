// ignore_for_file: use_build_context_synchronously

import 'package:conexion/constants/constants.dart';
import 'package:conexion/constants/routes.dart';
import 'package:conexion/firebase_helper/firebase_auth_helper/firebase_auth_helper.dart';
import 'package:conexion/screens/auth_ui/sign_up/sign_up.dart';
import 'package:conexion/widgets/primary_button/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../custom_bottom_bar/custom_bottom_bar.dart';



class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isShowPassword = true;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF5E9D7);
    final Color textColor = const Color(0xFF5D4037);
    final Color buttonColor = const Color(0xFF8B4513);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título con estilo elegante
              Text(
                "Iniciar sesión",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Bienvenido de nuevo a Casanare Vende",
                style: TextStyle(fontSize: 18, color: textColor.withOpacity(0.8)),
              ),
              const SizedBox(height: 40),

              // Tarjeta para campos de entrada
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Campo de E-mail
                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        hintText: "E-mail",
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.brown),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Campo de Contraseña
                    TextField(
                      controller: password,
                      obscureText: isShowPassword,
                      decoration: InputDecoration(
                        hintText: "Contraseña",
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.brown),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isShowPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () {
                            setState(() {
                              isShowPassword = !isShowPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Login estilizado
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  title: "Iniciar sesión",
                  onPressed: () async {
                    bool isValidated = loginValidation(email.text, password.text);
                    if (isValidated) {
                      bool isLogined = await FirebaseAuthHelper.instance
                          .login(email.text, password.text, context);
                      if (isLogined) {
                        Routes.instance.pushAndRemoveUntil(
                          widget: const CustomBottomBar(),
                          context: context,
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Texto y botón de registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿No tienes una cuenta?",
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Routes.instance.push(widget: const SignUp(), context: context);
                    },
                    child: Text(
                      "Crea una cuenta",
                      style: TextStyle(
                        color: buttonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
