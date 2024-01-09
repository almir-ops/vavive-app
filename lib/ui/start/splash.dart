import 'package:abg_utils/abg_utils.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:provider/provider.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  late MainModel _mainModel;

  _startNextScreen(){
    if (_loaded) {
      if (!_startLoaded) {
        _startLoaded = true;
        Navigator.pop(context);
        // if (localSettings.locale.isEmpty) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => LanguageScreen(openFromSplash: true),
        //     ),
        //   );
        // }else
        if (localSettings.showOnBoard) {
          localSettings.setShowOnBoard(false);
          Navigator.pushNamed(context, "/onboard");
        }else
          Navigator.pushNamed(context, "/main");
      }
    }

    //
  }

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
    _load();
    startTime();
  }

  bool _loaded = false;
  bool _startLoaded = false;

  _load() async {
    var ret = await _mainModel.init(context);
    if (ret != null) {
      messageError(context, ret);
      _loaded = true;
      return startTime();
    }
    dprint("SplashScreen");
    _loaded = true;
    _startNextScreen();
  }

  startTime() async {
    var duration = Duration(seconds: 3);
    return Timer(duration, _startNextScreen);
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
        backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
        body: Stack(
          children: <Widget>[

            Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: windowWidth*0.3,
                    height: windowWidth*0.3,
                    child: localSettings.logo.isEmpty ? Image.asset("assets/logo.png", fit: BoxFit.contain)
                        :showImage(localSettings.logo),
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
                Loader7(color: theme.mainColor)

              ],
            ))

          ]
      ));
  }

}


