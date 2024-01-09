import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

class Edit24 extends StatefulWidget {
  final String hint;
  final Function(String)? onChangeText;
  final TextEditingController controller;
  final TextInputType type;
  final Color color;
  final TextStyle style;
  final double radius;
  final double height;
  Edit24({this.hint = "", required this.controller, this.type = TextInputType.text, this.color = Colors.black, this.radius = 0,
    this.onChangeText, this.style = const TextStyle(), this.height = 40});

  @override
  _Edit24State createState() => _Edit24State();
}

class _Edit24State extends State<Edit24> {

  final bool _obscureText = false;

  @override
  Widget build(BuildContext context) {

    return Container(
        height: widget.height,
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: decor,
      child: Center(child: TextFormField(
        obscureText: _obscureText,
        cursorColor: widget.style.color,
        keyboardType: widget.type,
        controller: widget.controller,
        onChanged: (String value) async {
          if (widget.onChangeText != null)
            widget.onChangeText!(value);
        },
        textAlignVertical: TextAlignVertical.center,
        style: widget.style,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hint,
          hintStyle: widget.style,
      ),
    )));
  }
}