import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as crypt;
import 'Colors.dart';

void showTopSnackBar(BuildContext context,IconData Icons,String title,String msg) => Flushbar(
  icon: Icon(
    Icons,
    size: 42,
    color: Colors.white,
  ),
  duration: const Duration(seconds: 2),
  shouldIconPulse: false,
  padding: const EdgeInsets.all(24),
  margin: const EdgeInsets.fromLTRB(8, 30, 8, 0),
  borderRadius: const BorderRadius.all(Radius.circular(25)),
  title: title,
  message: msg,
  flushbarPosition: FlushbarPosition.TOP,
  borderColor: Colors.white70,
  backgroundGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      Color.fromARGB(255, 81, 70, 171),
    ],
  ),
)..show(context);

void showTopTitleSnackBar(BuildContext context,IconData Icons,String title) => Flushbar(
  icon: Icon(
    Icons,
    size: 42,
    color: Colors.white,
  ),
  duration: const Duration(seconds: 2),
  shouldIconPulse: false,
  padding: const EdgeInsets.all(24),
  margin: const EdgeInsets.fromLTRB(8, 30, 8, 0),
  borderRadius: const BorderRadius.all(Radius.circular(10)),
  message: title,
  flushbarPosition: FlushbarPosition.TOP,
  borderColor: Colors.white70,
  backgroundGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      Color.fromARGB(255, 81, 70, 171),
    ],
  ),
)..show(context);

// Encryption function
String encryptData(String data, String keyString) {
  final key = crypt.Key.fromUtf8(keyString);
  final iv = crypt.IV.fromUtf8(keyString.substring(0, 16));
  final encrypter = crypt.Encrypter(crypt.AES(key, mode: crypt.AESMode.cbc));
  final encrypted = encrypter.encrypt(data, iv: iv);
  return base64.encode(encrypted.bytes);
}

// Decryption function
String decryptData(String encryptedData, String keyString) {
  final key = crypt.Key.fromUtf8(keyString);
  final iv = crypt.IV.fromUtf8(keyString.substring(0, 16));
  final encrypter = crypt.Encrypter(crypt.AES(key, mode: crypt.AESMode.cbc));
  final encrypted = crypt.Encrypted(base64.decode(encryptedData));
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  return decrypted;
}

void clearAllFocus(BuildContext context) {
  final FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    currentFocus.focusedChild!.unfocus();
  }
  FocusManager.instance.primaryFocus?.unfocus();
}

class MyUser {
  static bool _isOnline = false;

  static void init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _updateOnlineStatus(true);
      } else {
        _updateOnlineStatus(false);
      }
    });
  }

  static void _updateOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'status': isOnline});
  }

  static bool get isOnline => _isOnline;
}