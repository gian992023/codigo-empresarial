// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conexion/constants/constants.dart';
import 'package:conexion/models/user_model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Clase para manejar funciones de autenticación de usuario empresarial.
class FirebaseAuthHelper {
  static final FirebaseAuthHelper instance = FirebaseAuthHelper();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get getAuthChange => _auth.authStateChanges();

  // Función autenticación login
  Future<bool> login(
      String email,
      String password,
      BuildContext context,
      ) async {
    try {
      showLoaderDialog(context);
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.of(context).pop();
      return true;
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      showMessage(getMessageFromErrorCode(error.code));
      return false;
    } catch (e) {
      Navigator.of(context).pop();
      showMessage("Error inesperado: ${e.toString()}");
      return false;
    }
  }

  // Función autenticación sign-up con teléfono
  Future<bool> signUp(
      String name,
      String email,
      String password,
      String phone,
      BuildContext context,
      ) async {
    try {
      showLoaderDialog(context);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel userModel = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        image: null,
      );

      await _firestore
          .collection("businessusers")
          .doc(userModel.id)
          .set(userModel.toJson());

      Navigator.of(context).pop();
      return true;
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      showMessage(getMessageFromErrorCode(error.code));
      return false;
    } catch (e) {
      Navigator.of(context).pop();
      showMessage("Error inesperado: ${e.toString()}");
      return false;
    }
  }

  // Función desconexión sign-out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Función cambio de contraseña de usuario empresarial
  Future<bool> changePassword(
      String newPassword,
      BuildContext context,
      ) async {
    try {
      showLoaderDialog(context);
      await _auth.currentUser!.updatePassword(newPassword);
      Navigator.of(context, rootNavigator: true).pop();
      showMessage("Contraseña actualizada");
      return true;
    } on FirebaseAuthException catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      showMessage(getMessageFromErrorCode(error.code));
      return false;
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      showMessage("Error inesperado: ${e.toString()}");
      return false;
    }
  }
}