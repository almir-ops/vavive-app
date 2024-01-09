import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'strings.dart';
import 'theme.dart';

class NotifyScreen extends StatefulWidget {
  @override
  _NotifyScreenState createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  String _searchText = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final _controllerSearch = TextEditingController();

  @override
  void initState() {
    updateNotifyPage = _loadMessages;
    _loadMessages();
    userNotificationsSetToRead();
    super.initState();
  }

  _loadMessages() async {
    _waits(true);
    var ret = await loadMessages();
    if (ret != null)
      messageError(context, ret);
    _waits(false);
    setNumberOfUnreadMessages(0);
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

  @override
  void dispose() {
    _controllerSearch.dispose();
    updateNotifyPage = null;
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
                RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: (){return _loadMessages();},
                    child: Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+20),
                      child: ListView(
                        children: _body(),
                      ),
                    )),

                if (_wait)
                  Center(child: Container(child: Loader7(color: theme.mainColor,))),

                appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
                    strings.get(87), context, () {goBack();}) /// Notifications

              ]),
        ));
  }

  _body(){
    List<Widget> list = [];

    list.add(Container(
      margin: EdgeInsets.all(10),
        child: Edit26(
        hint: strings.get(24), /// "Search",
        color: (theme.darkMode) ? Colors.black : Colors.white,
        style: theme.style14W400,
        decor: decor,
        icon: Icons.search,
        useAlpha: false,
        controller: _controllerSearch,
        onChangeText: (String value){
          _searchText = value;
          setState(() {
          });
        },
        suffixIcon: Icons.cancel,
        onSuffixIconPress: (){
          _searchText = "";
          _controllerSearch.text = "";
          _redraw();
        }
    )));

    list.add(SizedBox(height: 10,));

    //
    //
    //
    int _count = 0;
    var _now = DateFormat('dd MMMM').format(DateTime.now());

    for (var item in messages){
      if (_searchText.isNotEmpty)
        if (!item.title.toUpperCase().contains(_searchText.toUpperCase()))
          if (!item.body.toUpperCase().contains(_searchText.toUpperCase()))
            continue;
        // if (!item.show)
        //   continue;
        var time = DateFormat('dd MMMM').format(item.time);
        if (time == _now)
          time = strings.get(88); /// Today
        list.add(
            Stack(
              children: [
                Positioned.fill(child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.delete, color: Colors.red, size: 30,),
                )),
              Dismissible(key: Key(item.id),
              onDismissed: (DismissDirection _direction) async {
                await deleteMessage(item);
                _redraw();
              },
              confirmDismiss: (DismissDirection _direction) async {
                if (_direction == DismissDirection.startToEnd)
                  return false;
                return true;
              },
              child: Card48(
                text: item.body,
                text2: time,
                text3: item.title,
                callback: () async {
                  await deleteMessage(item);
                  _redraw();
                },
          ),)
        ],
      ));
      list.add(SizedBox(height: 1,));
      _count++;
    }

    if (_count == 0) {
      list.add(SizedBox(height: 50,));
      list.add(Center(child:
        Container(
          width: windowWidth*0.7,
          height: windowWidth*0.7,
          child: Image.asset("assets/notfound.png", fit: BoxFit.contain)
        ),
      ));
      list.add(Center(child: Text(strings.get(86), style: theme.style14W800,),)); /// "Not found ...",
    }

    list.add(SizedBox(height: 120,));

    return list;
  }
}

