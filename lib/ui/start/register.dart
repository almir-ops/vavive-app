import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../strings.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  
  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _editControllerName = TextEditingController();
  final _editControllerEmail = TextEditingController();
  final _editControllerPassword1 = TextEditingController();
  final _editControllerPassword2 = TextEditingController();
  var _agree = false;

  @override
  void dispose() {
    _editControllerName.dispose();
    _editControllerEmail.dispose();
    _editControllerPassword1.dispose();
    _editControllerPassword2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
        backgroundColor: (theme.darkMode) ? Colors.black : mainColorGray,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

        ListView(
          children: [
            SizedBox(height: 50,),
            Container(
                width: windowWidth*0.3,
                height: windowWidth*0.3,
                child: localSettings.logo.isEmpty ? Image.asset("assets/logo.png", fit: BoxFit.contain)
                    : showImage(localSettings.logo),
                // CachedNetworkImage(
                //   imageUrl: localSettings.logo,
                //   imageBuilder: (context, imageProvider) =>
                //       Container(
                //           decoration: BoxDecoration(
                //             image: DecorationImage(
                //               image: imageProvider,
                //               fit: BoxFit.contain,
                //             ),
                //           )
                //       ),)
            ),
            SizedBox(height: 20,),
            Center(child: Text(strings.get(1), /// "SIGN UP",
                style: theme.style25W400)),
            SizedBox(height: 50,),

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
                      prefixIcon: Icon(Icons.account_circle, color: theme.darkMode ? Colors.white : Colors.black,),
                      controller: _editControllerName,
                      hint: strings.get(16), /// "Enter your Name",
                      type: TextInputType.text
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Colors.grey),
                  ),
                  Edit43a(
                      prefixIcon: Icon(Icons.email, color: theme.darkMode ? Colors.white : Colors.black,),
                      controller: _editControllerEmail,
                      hint: strings.get(4), /// "Enter your Email",
                      type: TextInputType.emailAddress
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Colors.grey),
                  ),
                  Edit43V2(
                      needDecoration: false,
                      prefixIcon: Icon(Icons.vpn_key_rounded, color: theme.darkMode ? Colors.white : Colors.black,),
                      controller: _editControllerPassword1,
                      hint: strings.get(3), /// "Enter your Password",
                      type: TextInputType.visiblePassword
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Colors.grey),
                  ),
                  Edit43V2(
                      needDecoration: false,
                      prefixIcon: Icon(Icons.vpn_key_rounded, color: theme.darkMode ? Colors.white : Colors.black,),
                      controller: _editControllerPassword2,
                      hint: strings.get(15), /// "Confirm Password",
                      type: TextInputType.visiblePassword
                  ),

                ],),
            ),

            SizedBox(height: 30,),

            Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CheckBox12((){return _agree;}, (bool val){
                          _agree = val;
                          _redraw();
                        }, color: theme.mainColor),
                        SizedBox(width: 10,),
                        Text(strings.get(7), style: theme.style12W400), /// I agree with
                        SizedBox(width: 5,),
                        Expanded(child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: button134(strings.get(8), (){
                              route("terms");
                            }, style: theme.style14W800MainColor) /// "Terms and Conditions",
                        ))
                      ],
                    ),

                    SizedBox(height: 40,),
                    Row(
                      children: [
                        Expanded(
                          child: button134(strings.get(10), (){
                            goBack();
                          }, style: theme.style14W800MainColor) /// "Sign In",
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: button2(strings.get(9), /// "Sign Up",
                              theme.mainColor, _continue, enable: _agree),
                        ),
                      ],
                    ),

                  ],
                )
            ),

            SizedBox(height: 150,),
          ]
        ),


            appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
                "", context, () {goBack();}),

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

  _continue() async {
    if (_editControllerEmail.text.isEmpty)
      return messageError(context, strings.get(54)); /// "Please Enter Email",
    if (_editControllerPassword1.text.isEmpty || _editControllerPassword2.text.isEmpty)
      return messageError(context, strings.get(55)); /// "Please enter password",
    if (_editControllerPassword1.text != _editControllerPassword2.text)
      return messageError(context, strings.get(56)); /// "Passwords are not equal",
    if (!validateEmail(_editControllerEmail.text))
      return messageError(context, strings.get(57)); /// "Email are wrong",

    _waits(true);
    var ret = await register(_editControllerEmail.text,
        _editControllerPassword1.text, _editControllerName.text, strings.get(182)); /// User don't create
    _waits(false);
    if (ret != null)
      return messageError(context, ret);

    goBack();
    goBack();
  }
}


