import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Función para mostrar un mensaje tipo toast
void showMessage(String message) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

/// Función para mostrar un loader dialog (cargando...)
void showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Builder(
      builder: (context) {
        return SizedBox(
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xffe16555),
              ),
              const SizedBox(height: 18),
              Container(
                margin: const EdgeInsets.only(left: 7),
                child: const Text("Cargando..."),
              ),
            ],
          ),
        );
      },
    ),
  );

  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

/// Función que devuelve un mensaje personalizado según el código de error
String getMessageFromErrorCode(String errorCode) {
  switch (errorCode) {
    case "ERROR_EMAIL_ALREADY_IN_USE":
    case "account-exist-with-different-credential":
    case "email-already-in-use":
      return "Correo electrónico ya fue usado. Ir a la página de inicio de sesión";
    case "ERROR_WRONG_PASSWORD":
    case "wrong-password":
      return "Contraseña incorrecta";
    case "ERROR_USER_NOT_FOUND":
    case "user-not-found":
      return "Ningún usuario encontrado con este correo";
    case "ERROR_USER_DISABLED":
    case "user-disabled":
      return "Usuario deshabilitado";
    case "ERROR_TOO_MANY_REQUESTS":
    case "operation-not-allowed":
    case "ERROR_OPERATION_NOT_ALLOWED":
      return "Demasiadas solicitudes para iniciar sesión en esta cuenta";
    case "ERROR_INVALID_EMAIL":
    case "invalid_email":
      return "Correo electrónico inválido";
    default:
      return "Inicio de sesión falló, por favor intente nuevamente";
  }
}

/// Función de validación de login
bool loginValidation(String email, String password) {
  if (email.isEmpty && password.isEmpty) {
    showMessage("Ambos espacios están vacíos");
    return false;
  } else if (email.isEmpty) {
    showMessage("Correo electrónico vacío");
    return false;
  } else if (password.isEmpty) {
    showMessage("Contraseña vacía");
    return false;
  } else {
    return true;
  }
}

/// Validación de registro (SignUp) con email, contraseña, confirmación, nombre y teléfono
bool signUpValidation(
    String email,
    String password,
    String confirmPassword,
    String name,
    String phone,
    ) {
  // Todos los campos vacíos
  if (email.isEmpty &&
      password.isEmpty &&
      confirmPassword.isEmpty &&
      name.isEmpty &&
      phone.isEmpty) {
    showMessage("Todos los campos están vacíos");
    return false;
  }

  // Email vacío
  if (email.isEmpty) {
    showMessage("Correo electrónico vacío");
    return false;
  }
  // Formato básico de email
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(email)) {
    showMessage("Correo electrónico inválido");
    return false;
  }

  // Contraseña vacía
  if (password.isEmpty) {
    showMessage("Contraseña vacía");
    return false;
  }
  // Longitud mínima de contraseña
  if (password.length < 6) {
    showMessage("La contraseña debe tener al menos 6 caracteres");
    return false;
  }

  // Confirmar contraseña vacía
  if (confirmPassword.isEmpty) {
    showMessage("Confirmar contraseña vacía");
    return false;
  }
  // Coincidencia de contraseñas
  if (password != confirmPassword) {
    showMessage("Las contraseñas no coinciden");
    return false;
  }

  // Nombre vacío
  if (name.isEmpty) {
    showMessage("Nombre vacío");
    return false;
  }

  // Teléfono vacío
  if (phone.isEmpty) {
    showMessage("Número telefónico vacío");
    return false;
  }
  // Formato básico de teléfono (solo dígitos, entre 7 y 15 caracteres)
  final phoneRegex = RegExp(r'^\d{7,15}$');
  if (!phoneRegex.hasMatch(phone)) {
    showMessage("Número telefónico inválido");
    return false;
  }

  return true;
}

