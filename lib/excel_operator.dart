import 'dart:io';

import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExcelOperator{


  static void createExcel() {


    try {
      final Workbook workbook = Workbook();
//Accessing worksheet via index.
      workbook.worksheets[0];
// Save the document.
      final List<int> bytes = workbook.saveAsStream();
      File('CreateExcel.xlsx').writeAsBytes(bytes);
//Dispose the workbook.
      workbook.dispose();
      print("herre?");
    } on Exception catch (e) {
      print(e);
    }


  }

  static void writeInExcel() {

  }
}