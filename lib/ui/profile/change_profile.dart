import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:provider/provider.dart';
import '../strings.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/cards/card42button.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';

class ChangeProfileScreen extends StatefulWidget {
  @override
  _ChangeProfileScreenState createState() => _ChangeProfileScreenState();
}

class _ChangeProfileScreenState extends State<ChangeProfileScreen>  with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _editControllerName = TextEditingController();
  final _editControllerEmail = TextEditingController();
  final _editControllerPhone = TextEditingController();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _editControllerEmail.text = userAccountData.userEmail;
    _editControllerName.text = userAccountData.userName;
    _editControllerPhone.text = userAccountData.userPhone;
    super.initState();
  }

  @override
  void dispose() {
    _editControllerName.dispose();
    _editControllerEmail.dispose();
    _editControllerPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);

    bool _enablePhoneEdit = true;
    if (appSettings.isOtpEnable())
      _enablePhoneEdit = false;
    if (userAccountData.userSocialLogin.isNotEmpty)
      _enablePhoneEdit = true;

    return Scaffold(
        backgroundColor: (theme.darkMode) ? Colors.black : Colors.white,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+150, left: 20, right: 20),
              child: ListView(
                children: [

                  Container(
                    decoration: BoxDecoration(
                      color: (theme.darkMode) ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        edit42V2(strings.get(108), /// "Name",
                            _editControllerName,
                            strings.get(109), /// "Enter your name",
                            ),

                        SizedBox(height: 20,),

                        edit42V2(strings.get(110), /// "Email",
                            _editControllerEmail,
                            strings.get(111), /// "main@gmail.com",
                            type: TextInputType.emailAddress),

                        SizedBox(height: 20,),

                        edit42V2(strings.get(112), /// "Phone number",
                            _editControllerPhone,
                            strings.get(113), /// "+69091234566789",
                            enable: _enablePhoneEdit, type: TextInputType.phone
                        ),
                        if (!_enablePhoneEdit)
                          SizedBox(height: 5,),
                        if (!_enablePhoneEdit)
                          Text(strings.get(199), style: theme.style12W600Orange,), /// Your phone number verified. You can't edit phone number

                        SizedBox(height: 40,),

                        button2(strings.get(114), theme.mainColor, _changeInfo), /// "SAVE"
                      ],
                    ),
                  ),

                  SizedBox(height: 120,),
                ],
              ),
            ),

            ClipPath(
                clipper: ClipPathClass23(20),
                child: Container(
                    width: windowWidth,
                    child: card42button(
                        strings.get(106), /// "My Profile",
                        strings.get(107), /// "Everything about you",
                        _mainModel, windowWidth, (){}, userAccountData.userAvatar
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

  _changeInfo() async {
    if (_editControllerName.text.isEmpty)
      return messageError(context, strings.get(123)); /// "Please Enter name"
    if (_editControllerEmail.text.isEmpty)
      return messageError(context, strings.get(12)); /// "Please Enter email"
    if (_editControllerPhone.text.isEmpty)
      return messageError(context, strings.get(176)); /// "Please Enter phone"

    _waits(true);
    var ret = await changeInfo(_editControllerName.text,
        _editControllerEmail.text, _editControllerPhone.text);
    _waits(false);
    if (ret != null)
      messageError(context, ret);
    else
      messageOk(context, strings.get(200)); /// "Data saved",
  }
}


