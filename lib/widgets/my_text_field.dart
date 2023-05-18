import'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyTextField extends StatelessWidget {
  final Function(String) onChanged;
  final String hintText;
  final int max;
  final controller;
  final  number;

  const MyTextField({
    Key? key,
    this.max=1,
    required this.onChanged,
    this.controller,
    this.number=false,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: number?TextInputType.number:null,
      inputFormatters:number? [
        FilteringTextInputFormatter
            .digitsOnly
      ]:null,
      maxLines: max,
      controller: controller,
      onChanged: onChanged,
      style:  TextStyle(
        color: Colors.black,
        fontSize: 25.sp,
      ),
      decoration: InputDecoration(

        contentPadding: EdgeInsets.all(10.0.r),
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
