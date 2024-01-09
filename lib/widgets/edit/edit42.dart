import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

// 01.11.2021
edit42V2(String text, TextEditingController _controller,
    String _hint, {TextInputType? type, bool enable = true}){
  bool _obscure = false;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text, style: theme.style14W600Grey),
      Container(
        height: 40,
        margin: EdgeInsets.only(top: 5),
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: decor,
        child: TextField(
          controller: _controller,
          onChanged: (String value) async {
          },
          cursorColor: Colors.black,
          style: theme.style14W400,
          enabled: enable,
          cursorWidth: 1,
          keyboardType: type ?? TextInputType.text,
          obscureText: _obscure,
          textAlign: TextAlign.left,
          maxLines: 1,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: _hint,
            hintStyle: theme.style12W600Grey,
          ),
        ),
      )
    ],
  );
}

edit42Listener(String text, TextStyle _extStyle, TextEditingController _controller,
    String _hint, TextStyle _editStyle, Color color, Function(String) _callback){
  bool _obscure = false;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text, style: _extStyle),
      Container(
        height: 40,
        child: TextField(
          controller: _controller,
          onChanged: (String value) async {
            _callback(value);
          },
          cursorColor: Colors.black,
          style: _editStyle,
          cursorWidth: 1,
          obscureText: _obscure,
          textAlign: TextAlign.left,
          maxLines: 1,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            hintText: _hint,
            hintStyle: _editStyle,
          ),
        ),
      )
    ],
  );
}

edit42Numbers(String text, TextStyle _extStyle, TextEditingController _controller,
    String _hint, TextStyle _editStyle, Color color){
  bool _obscure = false;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text, style: _extStyle),
      Container(
        height: 40,
        child: TextField(
          controller: _controller,
          onChanged: (String value) async {
          },
          cursorColor: Colors.black,
          style: _editStyle,
          keyboardType: TextInputType.number,
          cursorWidth: 1,
          obscureText: _obscure,
          textAlign: TextAlign.left,
          maxLines: 1,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            hintText: _hint,
            hintStyle: _editStyle,
          ),
        ),
      )
    ],
  );
}

