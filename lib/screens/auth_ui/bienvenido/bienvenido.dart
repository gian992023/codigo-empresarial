import 'dart:async';
import 'package:conexion/constants/asset_images.dart';
import 'package:conexion/constants/routes.dart';
import 'package:conexion/screens/auth_ui/sign_up/sign_up.dart';
import 'package:flutter/material.dart';

import '../login/login.dart';
import '../../../widgets/primary_button/primary_button.dart';

class AutoScrollingText extends StatefulWidget {
  final List<String> phrases;
  final Duration interval;
  final TextStyle textStyle;

  const AutoScrollingText({
    Key? key,
    required this.phrases,
    this.interval = const Duration(seconds: 3),
    required this.textStyle,
  }) : super(key: key);

  @override
  _AutoScrollingTextState createState() => _AutoScrollingTextState();
}

class _AutoScrollingTextState extends State<AutoScrollingText> {
  late PageController _pageController;
  int currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(widget.interval, (timer) {
      currentPage = (currentPage + 1) % widget.phrases.length;
      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.phrases.length,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              widget.phrases[index],
              style: widget.textStyle,
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}

class Bienvenido extends StatelessWidget {
  const Bienvenido({super.key});

  @override
  Widget build(BuildContext context) {
    // Paleta de colores maderosos suaves
    final Color backgroundColor = const Color(0xFFDEB887); // Beige claro
    final Color titleColor = const Color(0xFF8B4513); // Marrón oscuro elegante
    final Color subtitleColor = const Color(0xFF5D4037); // Marrón suave

    // Frases para el carrusel
    final List<String> frases = [
      "Impulsa tu negocio con nosotros.",
      "Gestiona y vende en todo lugar.",
      "Conecta con más clientes hoy.",
      "Sé parte de la revolución digital."
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Carrusel de frases motivadoras
              AutoScrollingText(
                phrases: frases,
                textStyle: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 18),
              // Subtítulo inspirador
              Text(
                "Únete a nosotros y expande tu negocio de forma sencilla y moderna.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              // Imagen alusiva al e-commerce, combinada con la estética maderosa suave
              Image.asset(
                AssetsImages.instance.Casanarev,
                width: 500,
                height: 300,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 15),
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
