import 'dart:io';

import 'package:dige_pdf_to_excel/toast_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExcelOperator {
  static Future<void> writeInExcel(List<String> list) async {
    final originalListLength = list.length;
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    final firstLine = list.firstWhere((element) => element.contains("STATEMENT OPENING BALANCE"));
    final finalLine = list.firstWhere((element) => element.contains("CLOSING BALANCE"));
    var currentBalance = firstLine.split(" ").reversed.firstWhere((element) => element.contains
      (RegExp(r"[0-9]\.[0-9][0-9]")));
    list = list.where((element) => ! element.contains("STATEMENT OPENING BALANCE")).toList();
    list = list.where((element) => ! element.contains("CLOSING BALANCE")).toList();
    //titles
    sheet.getRangeByIndex(1, 1).setText("DATE");
    sheet.getRangeByIndex(1, 2).setText("TRANSACTION DESCRIPTION");
    sheet.getRangeByIndex(1, 3).setText("DEBIT");
    sheet.getRangeByIndex(1, 4).setText("CREDIT");
    sheet.getRangeByIndex(1, 5).setText("BALANCE");
    //open statement
    sheet.getRangeByIndex(2, 1).setText(firstLine.substring(0, 8));
    sheet.getRangeByIndex(2, 2).setText(firstLine.replaceAll(RegExp(r"[^\s\w]"), "")
        .replaceAll(RegExp(r"[\d]"), ""));
    sheet.getRangeByIndex(2, 5).setText(firstLine.substring(8).replaceAll(" ", "")
        .replaceAll(RegExp(r"[A-Z]"), ""));
    //populate statements
   for(var i = 3; i < list.length + 3; i++){
     var element = list[i-3];
     sheet.getRangeByIndex(i, 1).setText(element.substring(0, 8));
     sheet.getRangeByIndex(i, 2).setText(element.replaceAll(RegExp(r"[^\s\w]"), "")
         .replaceAll(RegExp(r"[\d]"), ""));
     var blc = element.split(" ").reversed
         .firstWhere((element) => element.contains(RegExp(r"[0-9]\.[0-9][0-9]")));
      sheet.getRangeByIndex(i, 5).setText(blc.toString());
     var middleNumber = element.split(" ").firstWhere((element) => element.contains
       (RegExp(r"[0-9]\.[0-9][0-9]")));
     if (leftIsBigger(currentBalance, blc) ) {
       currentBalance = blc;
       sheet.getRangeByIndex(i, 3).setText(middleNumber);
     }else{
       currentBalance = blc;
       sheet.getRangeByIndex(i, 4).setText(middleNumber);
     }
   }
   //close statement
    sheet.getRangeByIndex(originalListLength + 1, 1).setText(finalLine.substring(0, 8));
    sheet.getRangeByIndex(originalListLength + 1, 2).setText(finalLine.replaceAll(RegExp
      (r"[^\s\w]"), "")
        .replaceAll(RegExp(r"[\d]"), ""));
    sheet.getRangeByIndex(originalListLength + 1, 5).setText(finalLine.substring(8)
        .replaceAll(" ", "")
        .replaceAll(RegExp(r"[A-Z]"), ""));
    //autofit columns
    for(var i = 1; i < 6; i++){
      sheet.autoFitColumn(i);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      ToastAlert.alert("not support web version. ExcelOperator.writeInExcel()");
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName =
          // Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
          Platform.isWindows ? '\\Outputt.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  }

  static bool leftIsBigger(String firstString, String secondString) {
    if(firstString.length > secondString.length){
      return true;
    }
    if(firstString.length < secondString.length){
      return false;
    }
    var firstList = firstString.split("");
    var secondList = secondString.split("");
    for(var i = 0; i < firstList.length; i++){
      try {
        if (int.parse(firstList[i]) > int.parse(secondList[i])) {
          return true;
        }
        if (int.parse(firstList[i]) < int.parse(secondList[i])) {
          return false;
        }
        continue;
      } catch (_) {
        continue;
      }
    }
    return false;
  }
}
