import 'dart:io';

import 'package:dige_pdf_to_excel/excel_operator.dart';
import 'package:dige_pdf_to_excel/toast_alert.dart';
import 'package:eyro_toast/eyro_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'data_grabber.dart';

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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _statementList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
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
                    onPressed: _chooseAFile,
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

  Future<void> _chooseAFile() async {
    _statementList.clear();
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    File file;
    if (result != null) {
      file = File(result.files.single.path!);
      final PdfDocument document = PdfDocument(inputBytes: file.readAsBytesSync());
      final whitespaceRE = RegExp(r"\s+");
      var charList = PdfTextExtractor(document)
          .extractText(layoutText: true)
          .replaceAll("\n", " ")
          .replaceAll(whitespaceRE, " ")
          .split("");

      var itemBuffer = StringBuffer();
      var openKeyBuffer = StringBuffer();
      var closeKeyBuffer = StringBuffer();

      var grabber = DataGrabber();
      final openKeyRegex = RegExp("[0-9][0-9]/[0-9][0-9]/[0-9][0-9]");
      final closeKeyRegex = RegExp(r"[0-9]\.[0-9][0-9]");
      //iterate char list to find the open key.
      for (var i = 0; i < charList.length; i++) {
        //if grabber is open, keep writing.
        if (grabber.isOpening) {
          itemBuffer.write(charList[i]);
          //find close key
          for (var j = 3; j > -1; j--) {
            closeKeyBuffer.write(charList[i - j]);
          }
          if (closeKeyRegex.hasMatch(closeKeyBuffer.toString())) {
            grabber.findOneCloseKey();
            if (itemBuffer.toString().contains("CLOSING BALANCE") ||
                itemBuffer.toString().contains("OPENING BALANCE")) {
              grabber.findOneCloseKey();
            }
            if (!grabber.isOpening) {
              _statementList.add(itemBuffer.toString());
              itemBuffer.clear();
            }
          }
          closeKeyBuffer.clear();
          continue;
        }
        //find open key
        if (i < charList.length - 8) {
          for (var j = 0; j < 8; j++) {
            openKeyBuffer.write(charList[i + j]);
          }
        }
        //check key
        if (openKeyRegex.hasMatch(openKeyBuffer.toString())) {
          grabber.open();
          openKeyBuffer.clear();
          itemBuffer.write(charList[i]);
        }
      }
      for (var element in _statementList) {
        print(element);
      }
      document.dispose();
      ExcelOperator.writeInExcel(_statementList);
    } else {
      ToastAlert.alert("User canceled choosing");
    }
  }
}
