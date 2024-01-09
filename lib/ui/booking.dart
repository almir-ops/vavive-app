import 'package:abg_utils/abg_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/widgets/buttons/button202m2.dart';
import 'package:ondemandservice/widgets/need_login.dart';
import 'strings.dart';
import 'theme.dart';

int _lastPage = 0;

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with TickerProviderStateMixin{

  double windowWidth = 0;
  double windowHeight = 0;
  TabController? _tabController;
  var _tabIndex = 0;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: appSettings.statuses.length);
    if (_tabController != null)
      _tabController!.addListener(() {
        _tabIndex = _tabController!.index;
        _lastPage = _tabController!.index;
        _redraw();
      });
    _tabController!.animateTo(_lastPage);
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
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
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+10),
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

    list.add(Text(strings.get(91), /// "My Booking",
        textAlign: TextAlign.center, style: theme.style14W400),);

    list.add(SizedBox(height: 20,));

    list.add(TabBar(
      indicatorColor: theme.mainColor,
      labelColor: theme.mainColor,
      isScrollable: true,
      tabs: _tabHeaders(),
      controller: _tabController,
    ));

    list.add(SizedBox(height: 10,));
    list.add(Container(
        width: windowWidth,
        height: windowHeight,
        child: TabBarView(
          controller: _tabController,
          children: _tabBody(),
        )));

    list.add(SizedBox(height: 150,));
    return list;
  }

  _tabHeaders(){
    List<Widget> list = [];
    var _index = 0;
    for (var item in appSettings.statuses){
      list.add(Text(getTextByLocale(item.name, strings.locale),
          textAlign: TextAlign.center, style: _tabIndex == _index ? theme.style11W800MainColor: theme.style12W600Grey));
      _index++;
    }
    return list;
  }

  _tabBody(){
    List<Widget> list = [];
    for (var item in appSettings.statuses)
      list.add(_tabRunning(item.id, getTextByLocale(item.name, strings.locale)));
    return list;
  }

  _tabRunning(String sort, String _text){
    List<Widget> list = [];

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null)
      return ListView(
        padding: EdgeInsets.only(top: 0),
        children: needLogin(windowWidth, (){route("login");}),
      );

    var _count = 0;
    for (var item in ordersDataCache){
      if (item.status != sort)
        continue;
      list.add(Container(
          color: (theme.darkMode) ? Colors.black : Colors.white,
          padding: EdgeInsets.only(bottom: 5, top: 5),
          child: button202m2("${strings.get(145)} ${item.id}", /// "Order ID:",
            appSettings.getDateTimeString(item.time),
            item.providerImage,
            windowWidth*0.22, () async {
                waitInMainWindow(true);
                var ret = await bookingGetItem(item);
                waitInMainWindow(false);
                if (ret != null)
                  return messageError(context, ret);
                route("pending");
              },
          strings.get(140), ///  "Pending"
      ))
      );
      list.add(SizedBox(height: 1,));
      _count++;
    }

    if (_count == 0){
      list.add(SizedBox(height: 100,));
      list.add(Container(
          width: windowWidth*0.5,
          height: windowWidth*0.5,
          child: Image.asset("assets/notfound.png", fit: BoxFit.contain)
      ));
      list.add(SizedBox(height: 50,));
      list.add(Center(child: Text(strings.get(143), /// "Booking not found",
          style: theme.style14W800)));
    }

    list.add(SizedBox(height: 200));

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
}
