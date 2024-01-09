import 'package:flutter/material.dart';
import 'package:ondemandservice/ui/theme.dart';

button1s4(String text, String text2, IconData icon, bool select, Function() callback) {
  return InkWell(
      onTap: (){
        callback();
      },
      child: Container(
          // margin: EdgeInsets.only(left: 10, right: 10),
          padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
          decoration: decor,
          child: Row(
            children: [
              Icon(icon, color: theme.darkMode ? Colors.white: Colors.black,),
              SizedBox(width: 10,),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: theme.style14W400,),
                  Text(text2, style: theme.style10W400,),
                ],
              )),
              if (select)
                Icon(Icons.verified, color: Colors.green,)
            ],
          ))
  );
}

button1s5(String image, bool select, Function() callback) {
  return InkWell(
      onTap: (){
        callback();
      },
      child: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
          decoration: select ? decorMainColor : decor,
          child: Center(child: Image.asset(image))
      )
  );
}

