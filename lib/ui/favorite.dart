import 'package:abg_utils/abg_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/widgets/buttons/button202m.dart';
import 'package:ondemandservice/widgets/buttons/button202n2d.dart';
import 'package:ondemandservice/widgets/need_login.dart';
import 'package:provider/provider.dart';
import 'strings.dart';
import 'theme.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;
  TabController? _tabController1;
  final _controllerSearch = TextEditingController();
  String _searchText = "";
  var _tabIndex = 0;
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _tabController1 = TabController(vsync: this, length: 2);
    if (_tabController1 != null)
      _tabController1!.addListener(() {
        _tabIndex = _tabController1!.index;
        _redraw();
      });
    super.initState();
  }

  @override
  void dispose() {
    _tabController1?.dispose();
    _controllerSearch.dispose();
    super.dispose();
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
          )
        ]),
      ));
  }

  _body(){
    List<Widget> list = [];

    list.add(Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Edit26(
        hint: strings.get(33), /// "Search in favorites",
        color: theme.darkMode ? theme.blackColorTitleBkg : Colors.white,
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

    list.add(TabBar(
      indicatorColor: theme.mainColor,
      labelColor: theme.mainColor,
      tabs: [
        Text(strings.get(31), /// "Service",
            textAlign: TextAlign.center, style: _tabIndex == 0 ? theme.style11W800MainColor: theme.style12W600Grey),
        Text(strings.get(32), /// "Provider",
            textAlign: TextAlign.center, style: _tabIndex == 1 ? theme.style11W800MainColor: theme.style12W600Grey),
      ],
      controller: _tabController1,
    ));

    list.add(SizedBox(height: 10,));
    list.add(Container(
      width: windowWidth,
        height: windowHeight,
        //margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+70),
        child: TabBarView(
          controller: _tabController1,
          children: <Widget>[
            _tabService(),
            _tabProvider(),
          ],
        )));

    list.add(SizedBox(height: 150,));
    return list;
  }

  _tabService(){
    List<Widget> list = [];

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return ListView(
        padding: EdgeInsets.only(top: 0),
        children: needLogin(windowWidth, (){route("login");}),
      );

    var _count = 0;
    for (var item in product){
      if (!userAccountData.userFavorites.contains(item.id))
        continue;
      if (!getTextByLocale(item.name, strings.locale).toUpperCase().contains(_searchText.toUpperCase()))
        continue;
      _count++;
      list.add(
          Container(
              // height: windowSize*0.23,
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
    return ListView(
        padding: EdgeInsets.only(top: 0),
        children: list,
      );
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  _tabProvider(){
    List<Widget> list = [];

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return ListView(
        padding: EdgeInsets.only(top: 0),
        children: needLogin(windowWidth, (){route("login");}),
      );

    var _count = 0;
    for (var item in providers){
      if (!userAccountData.userFavoritesProviders.contains(item.id))
        continue;
      if (!getTextByLocale(item.name, strings.locale).toUpperCase().contains(_searchText.toUpperCase()))
        continue;
      _count++;
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          padding: EdgeInsets.only(bottom: 5, top: 5),
          decoration: BoxDecoration(
            color: (theme.darkMode) ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(theme.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: button202m(item, _mainModel, windowWidth*0.26)
      )
      );
      list.add(SizedBox(height: 1,));
    }
    if (_count == 0){
      list.add(SizedBox(height: 100,));
      list.add(Container(
          width: windowWidth*0.5,
          height: windowWidth*0.5,
          child: Image.asset("assets/notfound.png", fit: BoxFit.contain)
      ));
      list.add(SizedBox(height: 50,));
      list.add(Center(child: Text(strings.get(84), /// "Providers not found",
          style: theme.style14W800)));
    }
    return Container (
      child: ListView(
        padding: EdgeInsets.only(top: 0),
        children: list,
      ),);
  }
}
