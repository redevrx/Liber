import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constant/color.dart';
import '../core/constant/divider.dart';
import '../core/constant/font.dart';
import '../utils/utils.dart';

class EditText extends StatelessWidget {
  const EditText({
    Key? key,
    required this.width,
    required this.height,
    required this.onTextChange,
    this.label,
    this.inputType,
    this.formatter,
    this.isPassword = false,
    this.error,
    this.message,
    this.icon,
    this.iconTab,
    this.validator,
  }) : super(key: key);

  final String? label;
  final double width;
  final double height;
  final VoidCallbackString onTextChange;
  final TextInputType? inputType;
  final List<TextInputFormatter>? formatter;
  final bool isPassword;
  final String? error;
  final String? message;
  final Icon? icon;
  final VoidCallback? iconTab;
  final StringCallback? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: kDefault * 1.2),
      padding: const EdgeInsets.symmetric(
          horizontal: kDefault, vertical: kDefault / 4),
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: kDark,
          borderRadius: BorderRadius.circular(kDefault * 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(kOpacity),
                blurRadius: 5.0,
                offset: const Offset(0, 5.0)),
          ]),
      child: TextFormField(
        obscureText: isPassword,
        keyboardType: inputType,
        inputFormatters: formatter,
        onChanged: onTextChange,
        validator: validator,
        decoration: InputDecoration(
            errorText: error,
            errorBorder: InputBorder.none,
            hintText: label,
            hintStyle: kFontMedium(context)
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            suffixIcon: icon == null
                ? null
                : InkWell(
                    onTap: iconTab,
                    child: icon,
                  )),
        cursorColor: Colors.white,
        style: kFontMedium(context)
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
