import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../strings.dart';
import '../theme.dart';

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _editControllerCode = TextEditingController();

  @override
  void dispose() {
    _editControllerCode.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _out();
    super.deactivate();
  }

  bool _continuePress = false;

  _out() {
    if (!_continuePress)
      logout();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
        backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

            ListView(
              children: [

                SizedBox(height: windowWidth*0.25),
                Container(
                  width: windowWidth*0.5,
                  height: windowWidth*0.5,
                  child: Image.asset("assets/forgot.png", fit: BoxFit.contain)
                ),
                SizedBox(height: 50,),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Text(strings.get(197),  /// "We've sent 6 digit verification code.",
                    style: theme.style14W400, textAlign: TextAlign.center,),
                ),
                SizedBox(height: 20,),

                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.darkMode ? theme.blackColorTitleBkg : Colors.white,
                    borderRadius: BorderRadius.circular(theme.radius),
                    border: Border.all(color: Colors.grey.withAlpha(50)),
                    boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Edit43a(
                        prefixIcon: Icon(Icons.code, color: theme.darkMode ? Colors.white : Colors.black,),
                        controller: _editControllerCode,
                        hint: "123456",
                        type: TextInputType.number
                      ),
                  ],),
                ),

                SizedBox(height: 20,),

                Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                    child: Column(children: [

                    Row(
                      children: [
                        Expanded(
                          child: button2(strings.get(17), theme.mainColor, _next), /// "Next",
                        ),
                      ],
                    ),

                    SizedBox(height: 40,),

                  ],
                )),

                SizedBox(height: 150,),

              ],
            ),


            appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
                strings.get(196), context, () {goBack();}), /// "Phone verification",

            if (_wait)
              Center(child: Container(child: Loader7(color: theme.mainColor,))),

          ],
        )

    ));
  }

  bool _wait = false;
  _waits(bool value){
    _wait = value;
    _redraw();
  }
  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  _next() async {
    if (_editControllerCode.text.isEmpty)
      return messageError(context, strings.get(198)); /// "Please enter code",

    _waits(true);
    var ret = await otp(_editControllerCode.text, appSettings, strings.get(181)); /// Please enter valid code
    _waits(false);
    if (ret != null)
      return messageError(context, ret);

    _continuePress = true;
    goBack();
    goBack();
  }
}


