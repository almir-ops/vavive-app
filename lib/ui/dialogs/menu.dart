import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'package:abg_utils/abg_utils.dart';
import '../strings.dart';
import 'package:share/share.dart';

getBodyMenuDialog(MainModel _mainModel, Function() _redraw, Function() _close,
    double windowWidth, Function(String) _route, BuildContext context){
  double _size = windowWidth*0.2;
  User? user = FirebaseAuth.instance.currentUser;

  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(child: button126(strings.get(45), /// "Profile",
              "assets/profile.png", _size, _size, (){_route("profile");}, enable: user != null)),
            SizedBox(width: 10,),
            Expanded(child: button126(strings.get(49), /// "My Address",
                "assets/address.png", _size, _size, (){_route("address_list");}, enable: user != null)),
            SizedBox(width: 10,),
            Expanded(child: button126(strings.get(50), /// "Language",
                "assets/lang.png", _size, _size, (){_route("language");})),
            SizedBox(width: 10,),
            if (user != null)
            Expanded(child: button126(strings.get(51), /// "Sign Out",
                "assets/out.png", _size, _size,
                    (){
                      logout();
                      route("login");
                      _close();
                })),
            if (user == null)
              Expanded(child: button126(strings.get(10), /// "Sign In",
                  "assets/login.png", _size, _size, (){_route("login");})),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(child: button126(strings.get(46), /// "Privacy Policy",
                "assets/policy.png", _size, _size, (){_route("policy");})),
            SizedBox(width: 10,),
            Expanded(child: button126(strings.get(47), /// "About Us",
                "assets/about.png", _size, _size, (){_route("about");})),
            SizedBox(width: 10,),
            Expanded(child: button126(strings.get(8), /// "Terms & Conditions",
                "assets/terms.png", _size, _size, (){_route("terms");})),
            SizedBox(width: 10,),
            Expanded(child: button126(strings.get(234), /// "Share this App",
                "assets/about.png", _size, _size, () async {
                  var code = "";
                  if (Platform.isAndroid)
                    code = appSettings.googlePlayLink;
                  if(Platform.isIOS)
                    code = appSettings.appStoreLink;
                  await Share.share(code,
                      subject: strings.get(234), // Share This App,
                      sharePositionOrigin: null);
                }))
          ],
        ),
        SizedBox(height: 10,),
        if (user != null)
          Row(children: [
            Expanded(
              flex: 3,
              child: button144(strings.get(230), /// "Near by",
                "assets/map.jpg", 60,  (){
                    _route("nearby");
                  },
                  shadow: false,
                  color: theme.darkMode ? Colors.grey.withAlpha(50) : Colors.grey.withAlpha(10),
                  crossAxisAlignment: CrossAxisAlignment.center,
                style: theme.style14W800,
              ),
            ),

          ],),

        SizedBox(height: 10,),
        Row(
          children: [
            if (user != null)
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CheckBox12((){return userAccountData.enableNotify;}, (bool val) async {
                    var ret = await setEnableDisableNotify(val);
                    if (ret != null)
                      messageError(context, ret);
                    else
                      userAccountData.enableNotify = val;
                    _redraw();
                  }, color: theme.mainColor),
                  Text(strings.get(236), style: theme.style10W400, textAlign: TextAlign.center,), /// "Enable Notify",
                ],)
              ),
            SizedBox(width: 10,),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CheckBox12((){return theme.darkMode;}, (bool val){
                  theme = AppTheme(val);
                  localSettings.setDarkMode(val);
                  _redraw();
                }, color: theme.mainColor),
                Text(strings.get(48), style: theme.style10W400, textAlign: TextAlign.center,), /// "Dark Mode",
              ],)
            ),
          ],
        )

      ],
    );

}