import 'dart:math';
import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:provider/provider.dart';
import '../strings.dart';
import '../theme.dart';

class AddAddressScreen extends StatefulWidget {
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
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
        backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: [

            Container(
              child: ListView(
                padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                children: _children(),
              ),
            ),

            appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
                strings.get(58), context, () {goBack();}), /// Set Location

          ]),
        ));
  }

  _children() {
    List<Widget> list = [];

    list.add(SizedBox(height: 100,));
    list.add(Container(
      width: windowWidth*0.5,
      height: windowWidth*0.5,
      child: Image.asset("assets/address2.png", fit: BoxFit.contain)
    ));
    list.add(SizedBox(height: 50,));
    list.add(Center(child: Text(strings.get(59), /// "Find services near your",
      style: theme.style25W400)));
    list.add(SizedBox(height: 10,));
    list.add(Center(child: Text(strings.get(60), /// "By allowing location access, you can search for services and providers near your.",
        style: theme.style12W600Grey, textAlign: TextAlign.center,)));
    list.add(SizedBox(height: 50,));
    list.add(Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.all(10),
      child: button2(strings.get(61), /// "Use currents location",
          theme.mainColor,
            (){
            _mainModel.account.addAddressByCurrentPosition();
          }),
    ));
    list.add(Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.only(left: 10, right: 10),
      child: button2outline(strings.get(62), /// "Set from map"
          theme.style14W800MainColor, theme.mainColor, theme.radius, (){route("map");}, true,
          theme.darkMode ? Colors.black : Colors.white
      ),
    ));
    list.add(SizedBox(height: 200,));
    return list;
  }

}

