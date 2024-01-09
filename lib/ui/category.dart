import 'dart:math';
import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:provider/provider.dart';
import 'strings.dart';
import 'theme.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with TickerProviderStateMixin{

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
                    margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+40),
                    child: ListView(
                      padding: EdgeInsets.only(top: 0),
                      children: _body(),
                    )
                ),

                appbar1(Colors.transparent,
                    (theme.darkMode) ? Colors.white : Colors.black, strings.get(159), /// "Category",
                    context, () {goBack();}, style: theme.style14W400),

              ]),
        ));
  }

  _body(){
    List<Widget> list = [];

    List<Widget> list2 = [];
    for (var item in categories) {
      if (item.parent.isNotEmpty)
        continue;
      list2.add(Container(
        width: windowWidth * 0.33 - 13,
        height: windowWidth * 0.33,
        child: Stack(
          children: [
            buttonCategory(item, windowWidth < 400 ? windowWidth * 0.33*0.45 : windowWidth * 0.33*0.6, () {
              _mainModel.currentCategory = item;
              route("services");
            }, decor: decor),
            if (ifCategoryHaveSubcategories(item.id))
              Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.bottomCenter,
                child: FittedBox(child: Text(strings.get(233), style: theme.style12W600Grey,)), /// "Subcategory"
              )
          ],
        ),
      ));
    }

    list.add(Container(
      margin: EdgeInsets.all(10),
        child: Wrap(
        runSpacing: 10,
        spacing: 10,
        children: list2)
    ));

    list.add(SizedBox(height: 150,));
    return list;
  }


}
