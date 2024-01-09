import 'dart:math';
import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:provider/provider.dart';
import 'strings.dart';
import 'theme.dart';

class LanguageScreen extends StatefulWidget {
  final bool openLogin;
  final Function()? redraw;
  final Function(String) callback;

  const LanguageScreen({Key? key, this.openLogin = true, this.redraw, required this.callback}) : super(key: key);
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {

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
                "", context, () {widget.callback("home");}),

          ]),
        ));
  }

  _children() {
    List<Widget> list = [];

    list.add(SizedBox(height: 50,));
    list.add(Container(
      width: windowWidth*0.3,
      height: windowWidth*0.3,
      child: localSettings.logo.isEmpty ? Image.asset("assets/logo.png", fit: BoxFit.contain)
          :showImage(localSettings.logo),
        //   : CachedNetworkImage(
        // imageUrl: localSettings.logo,
        // imageBuilder: (context, imageProvider) =>
        //     Container(
        //         decoration: BoxDecoration(
        //           image: DecorationImage(
        //             image: imageProvider,
        //             fit: BoxFit.contain,
        //           ),
        //         )
        //     ),)
    ));
    list.add(SizedBox(height: 20,));
    list.add(Center(child: Text(strings.get(52), /// "Select Language",
      style: theme.style25W400)));
    list.add(SizedBox(height: 50,));
    list.add(_radioGroup());
    list.add(SizedBox(height: 50,));
    list.add(Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.all(10),
      child: button2(strings.get(53), /// "SUBMIT",
          theme.mainColor, (){
        _submit();
      }),
    ));
    list.add(SizedBox(height: 200,));
    return list;
  }

  _radioGroup(){
    List<Widget> list = [];

    for (var item in _mainModel.appLangs)
      list.add(ListTile(
          title: Text(
            item.name, style: theme.style14W800,
          ),
          leading: Radio(
            value: item.locale,
            groupValue: strings.locale,
            activeColor: theme.mainColor,
            onChanged: (String? value) {
              if (value == null)
                return;
              _set = true;
              strings.locale = value;
              _mainModel.lang.setLang(value, context);
              setState(() {
              });
            },
          )));

    return Theme(
        data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.grey
    ),
    child: Column(
      children: list
    ));
  }

  var _set = false;

  _submit() async {
    if (!_set)
      _mainModel.lang.setLang("en", context);
    if (!widget.openLogin) {
      widget.callback("home");
    }else {
      Navigator.pop(context);
      Navigator.pushNamed(context, "/main");
    }
    if (widget.redraw != null)
      widget.redraw!();
  }
}

