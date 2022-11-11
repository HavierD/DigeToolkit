import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../toast_alert.dart';
import 'data_grabber_locker.dart';
import 'excel_operator.dart';

class PdfChooser{

  final List<String> _statementList = [];

  Future<void> chooseAFile() async {
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

      var grabber = DataGrabberLocker();
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
      ToastAlert.message("User canceled choosing");
    }
  }
}