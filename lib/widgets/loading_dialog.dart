import 'package:flutter/material.dart';
import '../core/constant/color.dart';
import '../core/constant/divider.dart';

Future<void> loadingDialog({required BuildContext context}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(kDefault * 2),
              width: MediaQuery.of(context).size.width * .18,
              height: MediaQuery.of(context).size.height * .11,
              decoration: const BoxDecoration(
                color: kDarked,
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                backgroundColor: kDark,
                color: kDarked,
              ),
            ),
          ),
          onWillPop: () => Future.value(false));
    },
  );
}
