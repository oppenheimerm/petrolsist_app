import 'dart:math';
import 'package:flutter/material.dart';
import '';
import '../resources/colours.dart';

class Utils {

  static double? getRandomHeight() {
    //  Use final when you need variables that cannot be reassigned
    //  but can be computed at runtime. Use const for values that are
    //  known at compile time to enhance performance and ensure
    //  immutability.
    final random = Random();
    const minHeight = 300;
    const maxHeight = 550;
    const heightDifference = 100;
    final randomHeight =
        random.nextInt(maxHeight - minHeight - heightDifference + 1) +
            minHeight;
    return randomHeight.toDouble();
  }

  //want to group widgets together in a group so that they are traversed in a particular order

  /// Manages focus traversal to the scoped controls of this [context],
  /// also takes a [current] and [nextFocus] parameter.
  static void fieldFocusChange(
      BuildContext context,
      FocusNode current,
      FocusNode nextFocus
      ) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static void changeFocusNode(
      BuildContext context,
      {required FocusNode current, required FocusNode next}) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  /// App wide snack bar helper.  Displays a [message]
  /// with on [context].
  static snackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: AppColours.whiteColour,
          ),
        ),
        showCloseIcon: true,
        backgroundColor: AppColours.buttonOKColour,
        elevation: 2,
      ),
    );
  }

}