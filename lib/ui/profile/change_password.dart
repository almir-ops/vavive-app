import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:provider/provider.dart';
import '../strings.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/cards/card42button.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword>  with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _editControllerPassword1 = TextEditingController();
  final _editControllerPassword2 = TextEditingController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  void dispose() {
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
        backgroundColor: theme.darkMode ? Colors.black : Colors.white,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+150, left: 20, right: 20),
              child: ListView(
                children: [

                    Column(
                      children: [
                        Text(strings.get(115), /// "Change password",
                          style: theme.style16W800,),

                        SizedBox(height: 20,),

                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: (theme.darkMode) ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(strings.get(116), style: theme.style12W400,), /// "New password",
                                SizedBox(height: 5,),
                                Edit43V2(
                                    controller: _editControllerPassword1,
                                    hint: strings.get(117), /// "123456",
                                ),
                                SizedBox(height: 10,),

                                Text(strings.get(118), style: theme.style12W400,), /// "Confirm New password",
                                SizedBox(height: 5,),
                                Edit43V2(
                                    controller: _editControllerPassword2,
                                    hint: strings.get(117), /// "123456",
                                ),

                                SizedBox(height: 40,),

                                button2(strings.get(119), theme.mainColor, _changePassword), /// "CHANGE PASSWORD",

                          ]),
                    ),
                  ]),

                  SizedBox(height: 120,),
                ],
              ),
            ),

            ClipPath(
                clipper: ClipPathClass23(20),
                child: Container(
                    //margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    width: windowWidth,
                    child: card42button(
                        strings.get(106), /// "My Profile",
                        strings.get(115), /// "Change password",
                        _mainModel, windowWidth,
                        (){}, userAccountData.userAvatar
                    )
                )),

            appbar1(Colors.transparent, Colors.white, "", context, () {
              goBack();
            }),

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

  _changePassword() async {
    if (_editControllerPassword1.text.isEmpty)
      return messageError(context, strings.get(120)); /// "Enter Password"
    if (_editControllerPassword2.text.isEmpty)
      return messageError(context, strings.get(121)); /// "Enter Confirm Password"
    if (_editControllerPassword1.text != _editControllerPassword2.text)
      return messageError(context, strings.get(122)); /// "Passwords are not equal",

    _waits(true);
    var ret = await changePassword(_editControllerPassword1.text);
    _waits(false);
    if (ret != null)
      messageError(context, ret);
    else
      messageOk(context, strings.get(201)); /// "Password changed",
  }

}


