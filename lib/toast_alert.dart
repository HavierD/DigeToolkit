// TODO Implement this library.

import 'package:eyro_toast/eyro_toast.dart';
import 'package:flutter/cupertino.dart';

class ToastAlert{

  static Future<void> alert(String message)async{
    await showToaster(
      text: 'This is a centered Toaster',
      duration: ToastDuration.short,
      gravity: ToastGravity.bottom,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      backgroundColor: const Color(0xAA000000),
      fontColor: const Color(0xFFFFFFFF),
      textAlign: TextAlign.center,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: null,
    );
}
}