import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';

class MyUpdateTextFormField extends StatelessWidget {
  final String hintText;
  final int? maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final String? initialValue;
  final bool isDense;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  const MyUpdateTextFormField({
    super.key,
    required this.hintText,
    this.maxLines,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.initialValue,
    this.isDense = true,
    required this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: TextStyle(color: MColors.textNormal),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: MColors.textAlternative),
        isDense: isDense,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: MColors.lineNormal),
        ),
        contentPadding: EdgeInsets.all(15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: MColors.primaryStrong,
            width: 2,
          ), // kLine.normal
        ),
      ),
      onChanged: onChanged,
      onTap: onTap,
    );
  }
}
