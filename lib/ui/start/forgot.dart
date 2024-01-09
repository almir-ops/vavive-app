import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../strings.dart';
import '../theme.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _editControllerEmail = TextEditingController();

  @override
  void dispose() {
    _editControllerEmail.dispose();
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
                  child: Text(strings.get(18), style: theme.style14W400, textAlign: TextAlign.center,), /// "Please enter Your registered email so that we can help you to recover Your password."
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
                        prefixIcon: Icon(Icons.email, color: theme.darkMode ? Colors.white : Colors.black,),
                        controller: _editControllerEmail,
                        hint: strings.get(111), /// "main@gmail.com",
                        type: TextInputType.emailAddress
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
                          child: button2(strings.get(17), theme.mainColor, _reset), /// "Next",
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
                strings.get(6), context, () {goBack();}), /// "Forgot password?",

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

  _reset() async {
    if (_editControllerEmail.text.isEmpty)
      return messageError(context, strings.get(12)); /// "Please Enter Email",

    _waits(true);
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _editControllerEmail.text);
    }catch(ex) {
      _waits(false);
      return messageError(context, ex.toString());
    }
    _waits(false);
    messageOk(context, strings.get(175)); /// "Reset password email sent. Please check your mail."
  }
}


