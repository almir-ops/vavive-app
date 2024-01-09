import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../strings.dart';
import '../theme.dart';

class PhoneScreen extends StatefulWidget {
  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _editControllerPhone = TextEditingController();

  @override
  void dispose() {
    _editControllerPhone.dispose();
    super.dispose();
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
                  child: Text(strings.get(195),  /// "Enter your Phone number. We'll sent verification code.",
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
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 6),
                            child: Text(appSettings.otpPrefix, style: theme.style16W800),
                          ),
                          SizedBox(width: 10,),
                          Expanded(child: Edit43a(
                              //prefixIcon: Icon(Icons.phone, color: theme.darkMode ? Colors.white : Colors.black,),
                              controller: _editControllerPhone,
                              hint: strings.get(113), /// "9091234566789",
                              type: TextInputType.phone
                          ),)
                        ],
                      )
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

  bool _continuePress = false;

  @override
  void deactivate() {
    _out();
    super.deactivate();
  }

  _out() {
    if (!_continuePress)
      logout();
  }

  _next() async {
    if (_editControllerPhone.text.isEmpty)
      return messageError(context, strings.get(2)); /// "Enter your phone number",

    _continuePress = true;

    login(){
      goBack();
    }

    _goToCode(){
      route("otp");
    }

    _waits(true);
    var ret = await sendOTPCode(_editControllerPhone.text, context, login,
        _goToCode, appSettings, strings.get(179)); /// Code sent. Please check your phone for the verification code.
    _waits(false);
    if (ret != null)
      messageError(context, ret);
  }
}


