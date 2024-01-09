import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'strings.dart';
import 'theme.dart';

class DocumentsScreen extends StatefulWidget {
  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {

  String _title = "";

  @override
  void initState() {
    if (state == "terms")
      _title = strings.get(8); /// "Terms and Conditions",
    if (state == "about")
      _title = strings.get(47); /// "About Us",
    if (state == "policy")
      _title = strings.get(46); /// "Privacy Policy",
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: (theme.darkMode) ? Colors.black : Colors.white,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: [

            Container(
              width: windowWidth,
              height: windowHeight,
              child: SingleChildScrollView(child: _body(),),
            ),

            appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
                _title, context, () {goBack();}),

          ]),
        ));
  }

  _body(){
    var _data = "";
    if (state == "policy")
      _data = appSettings.policy;
    if (state == "about")
      _data = appSettings.about;
    if (state == "terms")
      _data = appSettings.terms;

    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 40+MediaQuery.of(context).padding.top,),
      child: Html(
        data: "<body>$_data",
        style: {
          "body": Style(
            backgroundColor: (theme.darkMode) ? Colors.black : Colors.white,
            color: (theme.darkMode) ? Colors.white : Colors.black
          ),
           }
      ),
    );
  }
}

