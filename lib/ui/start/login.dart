import 'package:abg_utils/abg_utils.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../strings.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _editControllerEmail = TextEditingController();
  final _editControllerPhone = TextEditingController();
  final _editControllerPassword = TextEditingController();
  var _remember = true;
  var _agree = false;

  @override
  void dispose() {
    _editControllerPhone.dispose();
    _editControllerEmail.dispose();
    _editControllerPassword.dispose();
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
                Center(child: Text(strings.get(1), /// "SIGN IN",
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
                        prefixIcon: Icon(Icons.email, color: theme.darkMode ? Colors.white : Colors.black,),
                        controller: _editControllerEmail,
                        hint: strings.get(4), /// "Enter your Email",
                        type: TextInputType.emailAddress,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: Divider(color: Colors.grey),
                      ),
                      Edit43V2(
                        prefixIcon: Icon(Icons.vpn_key_rounded, color: theme.darkMode ? Colors.white : Colors.black,),
                        needDecoration: false,
                        controller: _editControllerPassword,
                        hint: strings.get(3), /// "Enter your Password",
                        type: TextInputType.visiblePassword
                      ),

                  ],),
                ),

                SizedBox(height: 20,),

                Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CheckBox12((){return _remember;}, (bool val){
                          _remember = val;
                          _redraw();
                        }, color: theme.mainColor),
                        SizedBox(width: 5,),
                        Text(strings.get(5), style: theme.style12W400), /// Remember me
                        SizedBox(width: 8,),
                        Expanded(child: Container(
                          alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                                child: button134(strings.get(6), (){
                              route("forgot");
                            }, style: theme.style14W800MainColor))) /// "Forgot password?"
                        )
                      ],
                    ),

                    SizedBox(height: 30,),
                    Row(
                      children: [
                        CheckBox12((){return _agree;}, (bool val){
                          _agree = val;
                          _redraw();
                        }, color: theme.mainColor),
                        SizedBox(width: 5,),
                        Text(strings.get(7), style: theme.style12W400), /// I agree with
                        SizedBox(width: 5,),
                        Expanded(child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: button134(strings.get(8), (){
                          route("terms");
                        }, style: theme.style14W800MainColor)) /// "Terms and Conditions",
                        )
                      ],
                    ),

                    SizedBox(height: 20,),
                    Row(
                      children: [
                        Expanded(child: button134(strings.get(9), (){
                          route("register");
                        }, style: theme.style14W800)), /// "Sign Up",
                        SizedBox(width: 10,),
                        Expanded(
                          child: button2(strings.get(10), /// "Sign In",
                              theme.mainColor, _login, enable: _agree),
                        ),
                      ],
                    ),

                    SizedBox(height: 40,),

                    Center(
                      child: Text(strings.get(11), /// "or continue with",
                          style: theme.style14W400),
                    ),

                    SizedBox(height: 40,),

                    if (Platform.isIOS)
                      SizedBox(height: 10,),
                    if (Platform.isIOS)
                      buttonIOS("assets/apple.png", _appleLogin, windowWidth * 0.9, "Sign in with Apple"),
                    if (Platform.isIOS)
                      SizedBox(height: 20,),

                    Row(
                      children: [
                        Expanded(child: Container(
                          child: button2("Facebook", theme.mainColor, _facebookLogin),
                        )),
                        SizedBox(width: 10,),
                        Expanded(child: Container(
                          child: button2("Google", theme.mainColor, _googleLogin),
                        )),
                      ],
                    ),

                  ],
                )),

                SizedBox(height: 150,),

              ],
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

  _login() async {
    if (_editControllerEmail.text.isEmpty)
      return messageError(context, strings.get(12)); /// "Please Enter Email",

    if (_editControllerPassword.text.isEmpty)
      return messageError(context, strings.get(13)); /// "Please Enter Password",

    if (getProviderByEmail(_editControllerEmail.text) != null)
      return messageError(context, strings.get(273)); /// "Provider can't enter to customer app. Please use another credentials.",
    _waits(true);
    var ret = await login(_editControllerEmail.text, _editControllerPassword.text, _remember,
        strings.get(177), /// User not found
        strings.get(178)  /// "User is disabled. Connect to Administrator for more information.",

    );
    _waits(false);
    if (ret != null)
      return messageError(context, ret);

    goBack();
  }

  _googleLogin() async {
    _waits(true);
    var ret = await googleLogin();
    _waits(false);
    if (ret != null)
      return messageError(context, ret);
    goBack();
  }

  _facebookLogin() async {
    _waits(true);
    var ret = await facebookLogin();
    _waits(false);
    if (ret != null)
      return messageError(context, ret);
    goBack();
  }

  //
  // Appleс
  //
  _appleLogin() async {
    _waits(true);
    var ret = await appleLogin();
    _waits(false);
    if (ret != null)
      return messageError(context, ret);
    goBack();
  }
}


