import 'package:abg_utils/abg_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'strings.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/cards/card41.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  String _searchText = "";
  double windowSize = 0;
  final _controllerSearch = TextEditingController();

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    var ret = await clearChatCount();
    if (ret != null)
      messageError(context, ret);
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
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
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+50),
              child: ListView(
                children: _body(),
              )
          ),
          appbar1(Colors.transparent, (theme.darkMode) ? Colors.white : Colors.black,
              strings.get(138), context, () {goBack();}), /// Chat
        ]
      ),
      ));
  }

  _body(){
    List<Widget> list = [];

    // ignore: unnecessary_statements
    // context.watch<MainModel>().chat.customersChat;

    list.add(Container(
      margin: EdgeInsets.only(left: 15, right: 15),
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
          }
      ),
    ));

    list.add(SizedBox(height: 20,));
    int _count = 0;

    for (var item in users){
      var _name = item.name;
      UserData? _user;
      for (var pr in providers)
        if (item.email == pr.login) {
          _name = getTextByLocale(pr.name, strings.locale);
          _user = UserData(
            id: item.id,
            name: getTextByLocale(pr.name, strings.locale),
            logoServerPath: pr.logoServerPath, address: [],
          );
        }
      if (item.role == "owner" && _name.isEmpty)
        _name = strings.get(256); //  "Administrator",
          
      if (_searchText.isNotEmpty)
        if (!item.name.toUpperCase().contains(_searchText.toUpperCase()))
            continue;
      if (_user == null)
        continue;
      list.add(InkWell(
        onTap: (){
          setChat2Data(_user!);
          route("chat2");
        },
          child: Container(
              child: Card41(
                all: item.all,
                unread: item.unread,
                image: item.logoServerPath,
                text1: _name,
                text2: item.lastMessage,
                text3: item.lastMessageTime != null
                    ? appSettings.getDateTimeString(item.lastMessageTime!)
                    : "",
          )
      )));
      list.add(SizedBox(height: 2,));
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

    list.add(SizedBox(height: 150,));
    return list;
  }
}




