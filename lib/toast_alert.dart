// TODO Implement this library.

import 'package:eyro_toast/eyro_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToastAlert{

  static Future<void> alert(String message)async{
    await showToaster(
      text: message,
      duration: ToastDuration.long,
      gravity: ToastGravity.bottom,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      backgroundColor: Colors.red,
      fontColor: const Color(0xFFFFFFFF),
      textAlign: TextAlign.center,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 30,
      ),
      border: null,
    );
}

  static Future<void> message(String message)async {
    await showToaster(
      text: message,
      duration: ToastDuration.long,
      gravity: ToastGravity.bottom,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      backgroundColor: const Color(0xAA000000),
      fontColor: const Color(0xFFFFFFFF),
      textAlign: TextAlign.center,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 30,
      ),
      border: null,
    );
  }
}