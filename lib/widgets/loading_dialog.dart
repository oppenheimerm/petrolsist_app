import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String loadingMessage;
  final Color backgroundColour;
  //black87
  final Color progressIndicationColour;

  const LoadingDialog({
    super.key, required this.loadingMessage,
    required this.backgroundColour, required this.progressIndicationColour
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: backgroundColour,
      child: Container(
        margin: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColour,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 4,),

              CircularProgressIndicator(
                // white default
                valueColor: AlwaysStoppedAnimation<Color>(progressIndicationColour),
              ),

              const SizedBox(width: 4,),

              Text(
                  loadingMessage,
                style: const TextStyle(
                  fontSize: 16
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
