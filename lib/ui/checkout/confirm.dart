import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import '../strings.dart';
import '../theme.dart';

class ConfirmScreen extends StatefulWidget {
  @override
  _ConfirmScreenState createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;

  @override
  void initState() {
    callbackStackRemovePenultimate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
      body: Directionality(
      textDirection: strings.direction,
      child: Stack(
        children: [
          Center(
            //margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+40, bottom: 60),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 0),
                children: _body(),
              )
          ),

          appbar1(Colors.transparent,
              (theme.darkMode) ? Colors.white : Colors.black, "",
              context, () {goBack();}, style: theme.style14W400),

        ]),
      ));
  }

  _body(){
    List<Widget> list = [];

    list.add(Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: windowWidth*0.6,
              height: windowWidth*0.6,
              child: Image.asset("assets/orderplaced.png", fit: BoxFit.contain,)),
          Center(child: Text(strings.get(172), style: theme.style14W800,),), /// "You Place to Booking Successfully"
          SizedBox(height: 10,),
          Center(child: Text(strings.get(173), /// "Your Booking is placed successfully. We start our work process and you will receive your service soon."
            style: theme.style12W400, textAlign: TextAlign.center,),),
          SizedBox(height: 20,),
          Center(child: Text("${strings.get(218)}: $cartLastAddedId", /// "Booking ID",
            style: theme.style12W400, textAlign: TextAlign.center,),),

          SizedBox(height: 20,),
          button2(strings.get(171), /// "Back to Home"
              theme.mainColor, (){
                route("home");
              }),
        ],
      ),
    ));


    list.add(SizedBox(height: 150,));
    return list;
  }

}

