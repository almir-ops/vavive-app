import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/widgets/buttons/button202m.dart';
import 'package:provider/provider.dart';
import 'strings.dart';
import 'theme.dart';

class ProvidersAllScreen extends StatefulWidget {
  @override
  _ProvidersAllScreenState createState() => _ProvidersAllScreenState();
}

class _ProvidersAllScreenState extends State<ProvidersAllScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
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
    return Scaffold(
        backgroundColor: theme.darkMode ? Colors.black : mainColorGray,
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: [

            Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+20),
                child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  children: _body(),
                )
            ),

            appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
                strings.get(29), context, () {goBack();}), /// "Providers",

          ]),
        ));
  }

  _body(){
    List<Widget> list = [];

    list.add(SizedBox(height: 30,));

    for (var item in providers){
      list.add(Container(
          color: (theme.darkMode) ? Colors.black : Colors.white,
          padding: EdgeInsets.only(bottom: 5, top: 5),
          child: RepaintBoundary(
              key: item.dataKey,
              child: button202m(item, _mainModel, windowWidth*0.26)
          )));
      list.add(SizedBox(height: 2,));
    }
    list.add(SizedBox(height: 150,));
    return list;
  }
}

