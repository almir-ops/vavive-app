import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:provider/provider.dart';
import '../strings.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/cards/card42button.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>  with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  bool _notify = true;
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);

    return Scaffold(
        backgroundColor: (theme.darkMode) ? Colors.black : Colors.white,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

            Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+150, left: 10, right: 10),
                child: ListView(
                  children: [

                    Center(child: Text(userAccountData.userName, style: theme.style14W800,)),
                    SizedBox(height: 30,),
                    // Row(
                    //   children: [
                    //     Expanded(child: button1s3(_mainModel.booking.length.toString(), strings.get(128))), /// "Total booking",
                    //     SizedBox(width: 10,),
                    //     Expanded(child: button1s3("\$8475", strings.get(129))), /// "Total spent",
                    //   ],
                    // ),
                    SizedBox(height: 30,),
                    button1s(strings.get(124), Icons.edit, "changeProfile", _route), /// "Change profile"
                    SizedBox(height: 10,),
                    button1s(strings.get(115), Icons.password, "changePassword", _route), /// "Change password"
                    SizedBox(height: 10,),
                    button1s(strings.get(125), Icons.account_circle, "changeAvatar", _route), /// "Change avatar"
                    SizedBox(height: 10,),
                    button1s2(strings.get(87), Icons.notifications, _notify, (bool val ){  /// "Notifications"
                      _notify = val;
                      _redraw();
                    }),
                    SizedBox(height: 200,),
                  ],
                )
            ),

            ClipPath(
                clipper: ClipPathClass23(20),
                child: Container(
                  width: windowWidth,
                  child: card42button(
                      strings.get(106), /// "My Profile",
                      strings.get(107), /// "Everything about you",
                      _mainModel,
                      windowWidth, (){}, userAccountData.userAvatar
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

  _route(String _route){
    if (_route == "changeAvatar")
      _mainModel.openDialog("avatar");
    else
      route(_route);
    _waits(false);
  }

}


