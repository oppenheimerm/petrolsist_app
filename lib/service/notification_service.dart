import 'package:flutter/material.dart';

abstract class PSAppNotificationService {
  displaySnackBarMessage(String message, BuildContext context);
}

class PSNotificationService implements PSAppNotificationService {

  @override
  displaySnackBarMessage(String message, BuildContext context){
    var snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}