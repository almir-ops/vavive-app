import 'dart:math';
import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/widgets/buttons/button202n2d.dart';
import 'package:provider/provider.dart';
import 'strings.dart';
import 'theme.dart';

class ServicesScreen extends StatefulWidget {
  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final _controllerSearch = TextEditingController();
  String _searchText = "";
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    super.initState();
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    _mainModel.showTopTrends = false;
    _mainModel.showTopRating = false;
    super.dispose();
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
                    (theme.darkMode) ? Colors.white : Colors.black, getTextByLocale(_mainModel.currentCategory.name, strings.locale),
                    context, () {goBack();}, style: theme.style14W400),

              ]),
        ));
  }

  _body(){
    List<Widget> list = [];

    list.add(Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Edit26(
          hint: strings.get(24), /// "Search",
          color: (theme.darkMode) ? Colors.black : Colors.white,
          style: theme.style14W400,
          decor: decor,
          useAlpha: false,
          icon: Icons.search,
          controller: _controllerSearch,
          suffixIcon: Icons.cancel,
          onChangeText: (String val){
            _searchText = val;
            _redraw();
          },
          onSuffixIconPress: (){
            _searchText = "";
            _controllerSearch.text = "";
            _redraw();
          }
      ),),
    );

    list.add(SizedBox(height: 10,));

    //
    // subcategory
    //
    if (ifCategoryHaveSubcategories(_mainModel.currentCategory.id)){
      list.add(Container(
        padding: EdgeInsets.all(10),
        child: Text(strings.get(233), style: theme.style14W800) /// "Subcategory",
      ));

      List<Widget> list2 = [];
      for (var item in categories) {
        if (item.parent != _mainModel.currentCategory.id)
          continue;
        list2.add(Container(
          width: windowWidth * 0.33 - 13,
          height: windowWidth * 0.33,
          child: Stack(
            children: [
              buttonCategory(item, windowWidth < 400 ? windowWidth * 0.33*0.35 : windowWidth * 0.33*0.55, () {
                _mainModel.currentCategory = item;
                route("services");
              }),
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
      list.add(SizedBox(height: 10,));
    }

    var _count = 0;
    for (var item in _mainModel.showTopRating ? _mainModel.topRating : product){
      if (!_mainModel.showTopRating) {
        if (_mainModel.showTopTrends) {
          if (!appSettings.inMainScreenServices.contains(item.id))
            continue;
        } else if (!item.category.contains(_mainModel.currentCategory.id))
          continue;
      }

      if (!getTextByLocale(item.name, strings.locale).toUpperCase().contains(_searchText.toUpperCase()))
        continue;
      _count++;
      list.add(
          Container(
              height: windowSize*0.23,
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Stack(
                  children: [
                    button202n2d(item, _mainModel, windowWidth, true)
                  ]
              )));
      list.add(SizedBox(height: 10,));
    }

    if (_count == 0){
      list.add(SizedBox(height: 100,));
      list.add(Container(
          width: windowWidth*0.5,
          height: windowWidth*0.5,
          child: Image.asset("assets/notfound.png", fit: BoxFit.contain)
      ));
      list.add(SizedBox(height: 50,));
      list.add(Center(child: Text(strings.get(83), /// "Services not found",
          style: theme.style14W800)));
    }


    list.add(SizedBox(height: 150,));
    return list;
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

}
