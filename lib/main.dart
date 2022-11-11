import 'dart:io';

import 'package:dige_pdf_to_excel/pdfToExcel/excel_operator.dart';
import 'package:dige_pdf_to_excel/pdfToExcel/pdf_chooser.dart';
import 'package:dige_pdf_to_excel/toast_alert.dart';
import 'package:eyro_toast/eyro_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'pdfToExcel/data_grabber_locker.dart';

void main() {
  EyroToastSetup.shared.navigatorKey = GlobalKey<NavigatorState>();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: EyroToastSetup.shared.navigatorKey,
      title: 'AndyToolkit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Dige\'s tailor-made toolkit from Zhige'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    '   Extract statement table from PDF (Westpac PDF bank statement '
                        'only)   ',
                  ),
                  CupertinoButton(
                    onPressed: (){
                      final pdfChooser = PdfChooser();
                      pdfChooser.chooseAFile();
                    },
                    child: const Text("Choose a Westpac statement PDF"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
