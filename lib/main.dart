import 'dart:io';

import 'package:dige_pdf_to_excel/excel_operator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'data_grabber.dart';

void main() {
  runApp(const MyApp());
  //test
  ExcelOperator.createExcel();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  String _extractedTxt = "";
  final List<String> _statementList = [];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              _extractedTxt,
            ),
            CupertinoButton(
              child: Text("button"),
              onPressed: _chooseAFile,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _incrementCounter();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  // void _extractTxt() {
  //   final PdfDocument document =
  //       PdfDocument(inputBytes: File('23.pdf').readAsBytesSync());
  //   setState(() {
  //     _extractedTxt = PdfTextExtractor(document).extractText().substring(0, 10);
  //   });
  //   document.dispose();
  // }

  Future<void> _chooseAFile() async {
    _statementList.clear();
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    File file;
    if (result != null) {
      file = File(result.files.single.path!);
      final PdfDocument document = PdfDocument(inputBytes: file.readAsBytesSync());
      setState(() {
        _extractedTxt = PdfTextExtractor(document).extractText().substring(0, 10);
      });
      final _whitespaceRE = RegExp(r"\s+");
      var charList = PdfTextExtractor(document).extractText(layoutText: true)
          .replaceAll("\n", " ").replaceAll(_whitespaceRE, " ") .split
        ("");

      var itemBuffer = StringBuffer();
      var openKeyBuffer = StringBuffer();
      var closeKeyBuffer = StringBuffer();

      var grabber = DataGrabber();
      final openKeyRegex = RegExp("[0-9][0-9]/[0-9][0-9]/[0-9][0-9]");
      final closeKeyRegex = RegExp(r"[0-9]\.[0-9][0-9]");
      //iterate char list to find the open key.
      for (var i = 0; i < charList.length; i++) {

        //if grabber is open, keep writing.
        if(grabber.isOpening){
          itemBuffer.write(charList[i]);
          //find close key
          for(var j = 3; j > -1; j--){
            closeKeyBuffer.write(charList[i-j]);
          }
          if(closeKeyRegex.hasMatch(closeKeyBuffer.toString())){
            grabber.findOneCloseKey();
            if(itemBuffer.toString().contains("CLOSING BALANCE") || itemBuffer.toString
              ().contains("OPENING BALANCE")){
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
          for(var j = 0; j < 8; j++){
                    openKeyBuffer.write(charList[i+j]);
                  }
        }
        //check key
        if(openKeyRegex.hasMatch(openKeyBuffer.toString())){
          grabber.open();
          openKeyBuffer.clear();
          itemBuffer.write(charList[i]);
        }
      }



      for (var element in _statementList) {print(element);}
      document.dispose();
      ExcelOperator.createExcel();
      ExcelOperator.writeInExcel();
    } else {
      // User canceled the picker
    }
  }




}

