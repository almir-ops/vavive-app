import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

import '../ui/strings.dart';

needLogin(double windowWidth, Function() _login){
  List<Widget> list = [];
  list.add(SizedBox(height: 100,));
  list.add(Container(
      width: windowWidth*0.7,
      height: windowWidth*0.7,
      child: Image.asset("assets/needlogin.png", fit: BoxFit.contain)
  ));
  list.add(Center(child: Text(strings.get(85), /// "You are not authorized",
      style: theme.style14W800)));
  list.add(SizedBox(height: 20,));
  list.add(Container(
    margin: EdgeInsets.only(left: 10, right: 10),
    child: button2(strings.get(10), theme.mainColor, _login), /// "Sign In",
  ));

  list.add(SizedBox(height: 300,));

  return list;
}